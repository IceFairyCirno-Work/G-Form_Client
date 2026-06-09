import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/form_model.dart';
import '../models/question_model.dart';
import '../services/google_auth_service.dart';
import '../services/google_forms_service.dart';
import 'form_editor_screen.dart';
import 'settings_screen.dart';

class FormCardData {
  final String id;
  final String name;
  final String modifiedTime;
  final String lastOpenedTime;
  final FormModel? formData;
  final String thumbnailLink;
  late final String highResThumbnail;

  FormCardData({
    required this.id,
    required this.name,
    required this.modifiedTime,
    this.lastOpenedTime = '',
    this.formData,
    this.thumbnailLink = '',
  }) {
    highResThumbnail = _toHighRes(thumbnailLink);
  }

  static final _sizeRegex = RegExp(r'=[shw]\d+$');
  static String _toHighRes(String url) {
    if (url.isEmpty) return '';
    if (_sizeRegex.hasMatch(url)) {
      return url.replaceFirst(_sizeRegex, '=s800');
    }
    return url;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GoogleAuthService _authService = GoogleAuthService();
  final GoogleFormsService _formsService = GoogleFormsService();
  List<FormCardData> _recentForms = [];
  List<FormCardData> _cachedFilteredForms = [];
  bool _isLoadingForms = false;
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _templateCategory = 'all';
  String _sortBy = 'modified'; // 'modified', 'opened', 'title'
  String _ownershipFilter = 'anyone'; // 'anyone', 'me', 'not_me'
  late final TabController _tabController;

  static const double _templateCardWidth = 168;
  static const double _templateCardHeight = 200;

  // ── List view layout tuning knobs ──
  // Recent forms header row corners
  static const double _headerTopRadius = 12.0; // ← adjust here
  static const double _headerBottomRadius = 4.0; // ← adjust here

  // List item card corners
  static const double _itemTopRadius = 4.0; // ← adjust here
  static const double _itemBottomRadius = 4.0; // ← adjust here

  // Heights
  static const double _headerHeight =
      64.0; // ← adjust here (Recent forms row height)
  static const double _itemHeight =
      56.0; // ← adjust here (list item card height)

  // Horizontal padding (controls effective width from screen edge)
  static const double _headerHorizontalPadding =
      8.0; // ← adjust here (header row side padding)
  static const double _itemHorizontalPadding =
      8.0; // ← adjust here (list item side padding)

  // Spacing
  static const double _itemSpacing =
      2.0; // ← adjust here (gap between list items)
  static const double _headerToItemGap =
      2.0; // ← adjust here (gap between header row and first list item)

  static const List<({String id, String label})> _templateCategoryOptions = [
    (id: 'all', label: 'All'),
    (id: 'personal', label: 'Personal'),
    (id: 'work', label: 'Work'),
    (id: 'education', label: 'Education'),
  ];

  void _updateFilteredForms() {
    if (_searchQuery.isEmpty) {
      _cachedFilteredForms = _recentForms;
    } else {
      _cachedFilteredForms = _recentForms
          .where((f) => f.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _dismissKeyboard();
      _searchController.clear();
      setState(() {
        _searchQuery = '';
      });
      _updateFilteredForms();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addObserver(this);
    _loadRecentForms();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<_TemplateData> get _allTemplates => const [
    _TemplateData(
      icon: Icons.event_note,
      iconColor: Color(0xFF1565C0),
      name: 'Event registration',
      description: 'Collect RSVPs for an event',
      formId: '1ALfhPnwCOjbDirEcDx-uGDibMY4ZaNaewbsY3M7TYig',
      category: 'personal',
    ),
    _TemplateData(
      icon: Icons.local_offer,
      iconColor: Color(0xFFE65100),
      name: 'Contact information',
      description: 'Gather contact details',
      formId: '13YjRD3LSnrhjRV3OtNzSqcaIA4DvzLI7D8HWbZyy6ys',
      category: 'personal',
    ),
    _TemplateData(
      icon: Icons.celebration,
      iconColor: Color(0xFFAD1457),
      name: 'Party invitation',
      description: 'Invite people to a party',
      formId: '1kftKykKAh4iRiABU8nKRebH5LPy63nE0iuKKovj05as',
      category: 'personal',
    ),
    _TemplateData(
      icon: Icons.assignment,
      iconColor: Color(0xFF2E7D32),
      name: 'Order form',
      description: 'Collect product or service orders',
      formId: '',
      category: 'work',
    ),
    _TemplateData(
      icon: Icons.feedback,
      iconColor: Color(0xFF4527A0),
      name: 'Feedback form',
      description: 'Gather customer feedback',
      formId: '',
      category: 'work',
    ),
    _TemplateData(
      icon: Icons.videocam,
      iconColor: Color(0xFF00695C),
      name: 'Time off request',
      description: 'Submit and track time off requests',
      formId: '',
      category: 'work',
    ),
    _TemplateData(
      icon: Icons.quiz,
      iconColor: Color(0xFFBF360C),
      name: 'Assessment',
      description: 'Evaluate student knowledge',
      formId: '',
      category: 'education',
    ),
    _TemplateData(
      icon: Icons.exit_to_app,
      iconColor: Color(0xFF0277BD),
      name: 'Exit ticket',
      description: 'Quick check for understanding',
      formId: '',
      category: 'education',
    ),
    _TemplateData(
      icon: Icons.group,
      iconColor: Color(0xFF795548),
      name: 'Course evaluation',
      description: 'Get feedback on a course',
      formId: '',
      category: 'education',
    ),
  ];

  List<_TemplateData> get _filteredTemplates {
    var templates = _allTemplates;
    if (_templateCategory != 'all') {
      templates = templates
          .where((t) => t.category == _templateCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty && _tabController.index == 1) {
      templates = templates
          .where(
            (t) =>
                t.name.toLowerCase().contains(_searchQuery) ||
                t.description.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }
    return templates;
  }

  bool get _showTemplateCategoryRows =>
      (_searchQuery.isEmpty || _tabController.index == 0) &&
      _templateCategory == 'all';

  String _templateCategoryLabel(String category) {
    return switch (category) {
      'personal' => 'Personal',
      'work' => 'Work',
      'education' => 'Education',
      _ => category,
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadRecentForms();
    }
  }

  Future<void> _loadRecentForms() async {
    setState(() => _isLoadingForms = true);
    final orderBy = switch (_sortBy) {
      'opened' => 'viewedByMeTime desc',
      'title' => 'name',
      _ => 'modifiedByMeTime desc',
    };
    final forms = await _formsService.listRecentForms(
      orderBy: orderBy,
      ownershipFilter: _ownershipFilter,
    );

    // Create card data without form details first
    final cardData = forms
        .map(
          (f) => FormCardData(
            id: f['id'] ?? '',
            name: f['name'] ?? 'Untitled',
            modifiedTime: f['modifiedTime'] ?? '',
            lastOpenedTime: f['lastOpenedTime'] ?? '',
            thumbnailLink: f['thumbnailLink'] ?? '',
          ),
        )
        .toList();

    if (mounted) {
      setState(() {
        _recentForms = cardData;
        _isLoadingForms = false;
      });
      _updateFilteredForms();
    }

    // Fetch actual form data for each form in background
    _fetchFormDetails(cardData);
  }

  Future<void> _fetchFormDetails(List<FormCardData> cards) async {
    const batchSize = 5;
    for (int i = 0; i < cards.length; i += batchSize) {
      final batch = cards.sublist(
        i,
        i + batchSize > cards.length ? cards.length : i + batchSize,
      );
      final futures = batch.map((card) async {
        final form = await _formsService.getForm(card.id);
        return MapEntry(card.id, form);
      }).toList();

      final results = await Future.wait(futures);

      if (!mounted) return;
      setState(() {
        for (final entry in results) {
          final idx = _recentForms.indexWhere((f) => f.id == entry.key);
          if (idx != -1) {
            _recentForms[idx] = FormCardData(
              id: _recentForms[idx].id,
              name: _recentForms[idx].name,
              modifiedTime: _recentForms[idx].modifiedTime,
              lastOpenedTime: _recentForms[idx].lastOpenedTime,
              thumbnailLink: _recentForms[idx].thumbnailLink,
              formData: entry.value,
            );
          }
        }
      });
      _updateFilteredForms();
    }
  }

  void _navigateToFormEditor({String? formId}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => FormEditorScreen(formId: formId),
          ),
        )
        .then((_) => _loadRecentForms());
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      if (isToday) {
        // Show only time in xx:xx AM/PM format
        int hour = date.hour;
        final amPm = hour >= 12 ? 'PM' : 'AM';
        hour = hour % 12;
        if (hour == 0) hour = 12;
        final mm = date.minute.toString().padLeft(2, '0');
        return '$hour:$mm $amPm';
      } else {
        // Show only date like "Jun 3, 2022"
        const months = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[date.month]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  String _getDisplayDate(FormCardData form) {
    if (_sortBy == 'opened' && form.lastOpenedTime.isNotEmpty) {
      return _formatDate(form.lastOpenedTime);
    }
    return _formatDate(form.modifiedTime);
  }

  Future<void> _shareForm(String formId) async {
    final link = 'https://docs.google.com/forms/d/e/$formId/viewform';
    final form = await _formsService.getForm(formId);
    final uri = form?.responderUri ?? link;
    Clipboard.setData(ClipboardData(text: uri));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteForm(String formId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete form?'),
        content: const Text('This form will be moved to trash.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await _formsService.deleteForm(formId);
    if (mounted) {
      if (success) {
        setState(() {
          _recentForms.removeAt(index);
        });
        _updateFilteredForms();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form moved to trash'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete form'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _duplicateForm(String formId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Duplicating form...'),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
    final result = await _formsService.duplicateForm(formId);
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (result != null) {
        _loadRecentForms();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form duplicated!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to duplicate form'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F1F3),
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(width: 48),
        leadingWidth: 48,
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
            if (_tabController.index == 0) {
              _updateFilteredForms();
            }
          },
          decoration: InputDecoration(
            hintText: _tabController.index == 0
                ? 'Search your forms'
                : 'Search templates',
            hintStyle: const TextStyle(color: Color(0xFF080808), fontSize: 15),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade600,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      _updateFilteredForms();
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFCCCCCE),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(
                color: const Color(0xFF673AB7).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          if (user != null)
            IconButton(
              onPressed: () {
                _searchFocusNode.unfocus();
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    )
                    .then((_) => setState(() {}));
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF5F6368),
                size: 24,
              ),
              tooltip: 'Settings',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          labelColor: const Color(0xFF673AB7),
          unselectedLabelColor: const Color(0xFF5F6368),
          indicatorColor: const Color(0xFF673AB7),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'My forms'),
            Tab(text: 'Templates'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _searchFocusNode.unfocus();
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const FormEditorScreen(),
                ),
              )
              .then((_) => _loadRecentForms());
        },
        backgroundColor: const Color(0xFF673AB7),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My forms
          GestureDetector(
            onTap: () {
              if (_searchFocusNode.hasFocus) {
                _searchFocusNode.unfocus();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: _isGridView
                ? _buildMyFormsGridView()
                : _buildMyFormsListView(),
          ),

          // Tab 2: Templates
          _buildTemplatesTab(),
        ],
      ),
    );
  }

  Future<void> _previewAndUseTemplate(_TemplateData template) async {
    if (template.formId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template coming soon!'),
          backgroundColor: Color(0xFF9E9E9E),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Step 1: Show loading and fetch template data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Loading template...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    final formData = await _formsService.getForm(template.formId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (formData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load template. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Step 2: Show preview dialog
    final shouldUse = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: template.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(template.icon, color: template.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formData.title,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (formData.description.isNotEmpty) ...[
                  Text(
                    formData.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                ],
                Text(
                  '${formData.questions.length} question${formData.questions.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5F6368),
                  ),
                ),
                const SizedBox(height: 12),
                ...formData.questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final q = entry.value;
                  final typeLabel = _questionTypeLabel(q.type);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.questionText.isNotEmpty
                                    ? q.questionText
                                    : 'Untitled question',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                typeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (q.isRequired)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Use this template'),
            ),
          ],
        );
      },
    );

    if (shouldUse != true || !mounted) return;

    // Step 3: Copy template to user's Drive
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Creating your form from template...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    final copyResult = await _formsService.duplicateForm(
      template.formId,
      name: formData.title,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (copyResult != null) {
      // Step 4: Navigate to form editor
      final newFormId = copyResult['id']!;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template copied! Opening editor...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => FormEditorScreen(formId: newFormId),
            ),
          )
          .then((_) => _loadRecentForms());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to copy template. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _questionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple choice';
      case QuestionType.checkbox:
        return 'Checkboxes';
      case QuestionType.shortAnswer:
        return 'Short answer';
      case QuestionType.paragraph:
        return 'Paragraph';
      case QuestionType.dropdown:
        return 'Dropdown';
      case QuestionType.linearScale:
        return 'Linear scale';
      case QuestionType.multipleChoiceGrid:
        return 'Multiple choice grid';
      case QuestionType.checkboxGrid:
        return 'Checkbox grid';
      case QuestionType.date:
        return 'Date';
      case QuestionType.time:
        return 'Time';
      case QuestionType.image:
        return 'Image';
      case QuestionType.video:
        return 'Video';
      case QuestionType.info:
        return 'Title & description';
      case QuestionType.section:
        return 'Section';
    }
  }

  /// My Forms tab — Grid view wrapped in a white container (like Templates tab).
  Widget _buildMyFormsGridView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_headerTopRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_headerTopRadius),
        child: RefreshIndicator(
          onRefresh: _loadRecentForms,
          child: CustomScrollView(
            slivers: [
              // Recent Forms Header row
              SliverToBoxAdapter(
                child: Container(
                  height: _headerHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent forms',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF202124),
                          ),
                        ),
                      ),
                      _buildFilterButton(),
                      const SizedBox(width: 4),
                      _buildSortButton(),
                      const SizedBox(width: 4),
                      _buildAppBarViewToggle(),
                    ],
                  ),
                ),
              ),

              // Loading / Empty / Filtered states
              if (_isLoadingForms)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF673AB7),
                      ),
                    ),
                  ),
                )
              else if (_recentForms.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Color(0xFFDADCE0),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recent forms',
                            style: TextStyle(
                              color: Color(0xFF80868B),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_cachedFilteredForms.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No forms matching "$_searchQuery"',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  key: ValueKey('grid_$_sortBy'),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    delegate: SliverChildBuilderDelegate((
                      context,
                      index,
                    ) {
                      final form = _cachedFilteredForms[index];
                      return RepaintBoundary(
                        child: _buildFormCard(form, index),
                      );
                    }, childCount: _cachedFilteredForms.length),
                  ),
                ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 80),
                  child: Center(
                    child: Text(
                      '-This is the end-',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF80868B),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// My Forms tab — List view with the original layout (unchanged).
  Widget _buildMyFormsListView() {
    return RefreshIndicator(
      onRefresh: _loadRecentForms,
      child: CustomScrollView(
        slivers: [
          // Recent Forms Header — list-item style card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _headerHorizontalPadding,
                0,
                _headerHorizontalPadding,
                _headerToItemGap,
              ),
              child: Container(
                height: _headerHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_headerTopRadius),
                    topRight: Radius.circular(_headerTopRadius),
                    bottomLeft: Radius.circular(_headerBottomRadius),
                    bottomRight: Radius.circular(_headerBottomRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent forms',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF202124),
                        ),
                      ),
                    ),
                    _buildFilterButton(),
                    const SizedBox(width: 4),
                    _buildSortButton(),
                    const SizedBox(width: 4),
                    _buildAppBarViewToggle(),
                  ],
                ),
              ),
            ),
          ),

          // Loading / Empty / Filtered states
          if (_isLoadingForms)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF673AB7),
                  ),
                ),
              ),
            )
          else if (_recentForms.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Color(0xFFDADCE0),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No recent forms',
                        style: TextStyle(
                          color: Color(0xFF80868B),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_cachedFilteredForms.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No forms matching "$_searchQuery"',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              key: ValueKey('list_$_sortBy'),
              delegate: SliverChildBuilderDelegate((context, index) {
                final form = _cachedFilteredForms[index];
                return RepaintBoundary(
                  child: _buildFormListCard(form, index),
                );
              }, childCount: _cachedFilteredForms.length),
            ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 24, bottom: 80),
              child: Center(
                child: Text(
                  '-This is the end-',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF80868B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_headerTopRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_headerTopRadius),
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 80),
            children: [
              _buildTemplateCategoryChips(),
              const SizedBox(height: 16),
              if (_showTemplateCategoryRows)
                ..._buildAllCategoriesView()
              else if (_searchQuery.isNotEmpty && _filteredTemplates.isEmpty)
                _buildTemplateSearchEmptyState()
              else
                _buildTemplateGridView(),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  '-This is the end-',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF80868B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _templateCategoryOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _templateCategoryOptions[index];
          final isSelected = _templateCategory == option.id;
          return FilterChip(
            label: Text(option.label),
            selected: isSelected,
            onSelected: (_) {
              _dismissKeyboard();
              setState(() {
                _templateCategory = option.id;
              });
            },
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF673AB7)
                  : const Color(0xFF5F6368),
            ),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF673AB7).withValues(alpha: 0.12),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF673AB7).withValues(alpha: 0.4)
                  : const Color(0xFFDADCE0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  Widget _buildFormPreviewMockup(_TemplateData template) {
    final isComingSoon = template.formId.isEmpty;
    return Opacity(
      opacity: isComingSoon ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: template.iconColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 8,
              width: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF202124).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF80868B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              width: 96,
              decoration: BoxDecoration(
                color: const Color(0xFF80868B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              width: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF80868B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(_TemplateData template, {bool fixedSize = false}) {
    final isComingSoon = template.formId.isEmpty;

    final card = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _previewAndUseTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDADCE0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildFormPreviewMockup(template)),
                  SizedBox(
                    height: 58,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 16,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                template.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                  color: Color(0xFF202124),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: 28,
                            child: Text(
                              template.description,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.17,
                                color: Color(0xFF80868B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isComingSoon)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDADCE0)),
                    ),
                    child: const Text(
                      'Soon',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (fixedSize) {
      return SizedBox(
        width: _templateCardWidth,
        height: _templateCardHeight,
        child: card,
      );
    }
    return card;
  }

  Widget _buildTemplateSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F6368),
            ),
          ),
          Text(
            '$count template${count == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF80868B)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllCategoriesView() {
    const categories = ['personal', 'work', 'education'];
    return [
      for (var i = 0; i < categories.length; i++) ...[
        if (i > 0) const SizedBox(height: 24),
        _buildTemplateSection(
          title: _templateCategoryLabel(categories[i]),
          category: categories[i],
        ),
      ],
    ];
  }

  Widget _buildTemplateSection({
    required String title,
    required String category,
  }) {
    final templates = _allTemplates
        .where((t) => t.category == category)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTemplateSectionHeader(title, templates.length),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              return _buildTemplateCard(templates[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateGridView() {
    final templates = _filteredTemplates;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          return _buildTemplateCard(templates[index]);
        },
      ),
    );
  }

  Widget _buildTemplateSearchEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No templates matching "$_searchQuery"',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or category',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    const filterOptions = {
      'anyone': ('Owned by anyone', Icons.people_outline),
      'me': ('Owned by me', Icons.person_outline),
      'not_me': ('Not owned by me', Icons.person_off_outlined),
    };

    return PopupMenuButton<String>(
      onSelected: (value) {
        _searchFocusNode.unfocus();
        if (value != _ownershipFilter) {
          setState(() {
            _ownershipFilter = value;
          });
          _loadRecentForms();
        }
      },
      offset: const Offset(0, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: PopupMenuPosition.over,
      constraints: const BoxConstraints(minWidth: 180),
      itemBuilder: (ctx) => filterOptions.entries.map((entry) {
        final isSelected = entry.key == _ownershipFilter;
        return PopupMenuItem<String>(
          value: entry.key,
          height: 42,
          child: Row(
            children: [
              Icon(
                entry.value.$2,
                size: 18,
                color: isSelected
                    ? const Color(0xFF673AB7)
                    : const Color(0xFF5F6368),
              ),
              const SizedBox(width: 10),
              Text(
                entry.value.$1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF673AB7)
                      : const Color(0xFF202124),
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check, size: 18, color: Color(0xFF673AB7)),
            ],
          ),
        );
      }).toList(),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Icon(
            Icons.filter_alt_outlined,
            size: 18,
            color: const Color(0xFF5F6368),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    const sortOptions = {
      'modified': ('Last modified', Icons.schedule),
      'opened': ('Last opened', Icons.visibility_outlined),
      'title': ('Title (A\u2013Z)', Icons.sort_by_alpha),
    };

    return PopupMenuButton<String>(
      onSelected: (value) {
        _searchFocusNode.unfocus();
        if (value != _sortBy) {
          setState(() {
            _sortBy = value;
          });
          _loadRecentForms();
        }
      },
      offset: const Offset(0, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: PopupMenuPosition.over,
      constraints: const BoxConstraints(minWidth: 180),
      itemBuilder: (ctx) => sortOptions.entries.map((entry) {
        final isSelected = entry.key == _sortBy;
        return PopupMenuItem<String>(
          value: entry.key,
          height: 42,
          child: Row(
            children: [
              Icon(
                entry.value.$2,
                size: 18,
                color: isSelected
                    ? const Color(0xFF673AB7)
                    : const Color(0xFF5F6368),
              ),
              const SizedBox(width: 10),
              Text(
                entry.value.$1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF673AB7)
                      : const Color(0xFF202124),
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check, size: 18, color: Color(0xFF673AB7)),
            ],
          ),
        );
      }).toList(),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: const Icon(
            Icons.sort_by_alpha,
            size: 18,
            color: Color(0xFF5F6368),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarViewToggle() {
    final gridSelected = _isGridView;
    final listSelected = !_isGridView;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDADCE0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // List button (LEFT)
          GestureDetector(
            onTap: () {
              if (!listSelected) {
                _searchFocusNode.unfocus();
                setState(() => _isGridView = false);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: listSelected
                    ? const Color(0xFFE8DEF8)
                    : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.view_list,
                size: 18,
                color: listSelected
                    ? const Color(0xFF673AB7)
                    : const Color(0xFF5F6368),
              ),
            ),
          ),
          // Grid button (RIGHT)
          GestureDetector(
            onTap: () {
              if (!gridSelected) {
                _searchFocusNode.unfocus();
                setState(() => _isGridView = true);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: gridSelected
                    ? const Color(0xFFE8DEF8)
                    : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(18),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.grid_view,
                size: 18,
                color: gridSelected
                    ? const Color(0xFF673AB7)
                    : const Color(0xFF5F6368),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailFallback(FormCardData form) {
    return Container(
      color: const Color(0xFF673AB7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              color: Colors.white70,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              form.name.isNotEmpty ? form.name : 'Untitled',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(FormCardData form, int index) {
    return GestureDetector(
      onTap: () => _navigateToFormEditor(formId: form.id),
      onLongPress: () => _showFormContextMenu(context, form, index),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              flex: 3,
              child: form.highResThumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: form.highResThumbnail,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      placeholder: (context, url) => Container(
                        color: const Color(0x14673AB7),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0x66673AB7),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildThumbnailFallback(form),
                    )
                  : _buildThumbnailFallback(form),
            ),
            // Bottom info area with title + menu
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            form.name.isNotEmpty ? form.name : 'Untitled',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFF202124),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getDisplayDate(form),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF5F6368),
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: PopupMenuButton<String>(
                        onSelected: (action) {
                          switch (action) {
                            case 'share':
                              _shareForm(form.id);
                            case 'delete':
                              _deleteForm(form.id, index);
                            case 'duplicate':
                              _duplicateForm(form.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 20,
                                  color: Color(0xFF5F6368),
                                ),
                                SizedBox(width: 12),
                                Text('Share (copy link)'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.content_copy,
                                  size: 20,
                                  color: Color(0xFF5F6368),
                                ),
                                SizedBox(width: 12),
                                Text('Duplicate'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Icons.more_vert,
                          size: 16,
                          color: Color(0xFF080808),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormContextMenu(
    BuildContext context,
    FormCardData form,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link, color: Color(0xFF5F6368)),
              title: const Text('Share (copy link)'),
              onTap: () {
                Navigator.pop(context);
                _shareForm(form.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy, color: Color(0xFF5F6368)),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                _duplicateForm(form.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteForm(form.id, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormListCard(FormCardData form, int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _itemHorizontalPadding,
        index == 0 ? 0 : _itemSpacing / 2,
        _itemHorizontalPadding,
        _itemSpacing / 2,
      ),
      child: GestureDetector(
        onTap: () => _navigateToFormEditor(formId: form.id),
        onLongPress: () => _showFormContextMenu(context, form, index),
        child: Container(
          height: _itemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_itemTopRadius),
              topRight: Radius.circular(_itemTopRadius),
              bottomLeft: Radius.circular(_itemBottomRadius),
              bottomRight: Radius.circular(_itemBottomRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left icon — circular form icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFF673AB7),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Form info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      form.name.isNotEmpty ? form.name : 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF202124),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getDisplayDate(form),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ),
              // 3-dot menu
              PopupMenuButton<String>(
                onSelected: (action) {
                  switch (action) {
                    case 'share':
                      _shareForm(form.id);
                      break;
                    case 'delete':
                      _deleteForm(form.id, index);
                      break;
                    case 'duplicate':
                      _duplicateForm(form.id);
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 20, color: Color(0xFF5F6368)),
                        SizedBox(width: 12),
                        Text('Share (copy link)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(
                          Icons.content_copy,
                          size: 20,
                          color: Color(0xFF5F6368),
                        ),
                        SizedBox(width: 12),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF080808),
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateData {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String description;
  final String formId;
  final String category;

  const _TemplateData({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.description,
    required this.formId,
    required this.category,
  });
}
