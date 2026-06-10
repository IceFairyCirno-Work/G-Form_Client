import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/services.dart';
import 'package:googleform_client/l10n/app_localizations.dart';
import '../models/form_model.dart';
import '../services/google_auth_service.dart';
import '../services/google_forms_service.dart';
import '../utils/app_strings.dart';
import '../utils/responsive.dart';
import '../utils/template_manager.dart';
import '../widgets/rename_form_dialog.dart';
import '../widgets/safe_image.dart';
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
  bool _isLoadingMoreForms = false;
  bool _hasMoreForms = true;
  String? _nextPageToken;
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _templateCategory = 'all';
  String _sortBy = 'modified'; // 'modified', 'opened', 'title'
  String _ownershipFilter = 'anyone'; // 'anyone', 'me', 'not_me'
  late final TabController _tabController;
  final Map<String, String> _templateThumbnails = {};
  bool _isLoadingTemplateThumbnails = false;
  bool _isSearchFocused = false;

  static final _thumbnailSizeRegex = RegExp(r'=[shw]\d+$');
  static String _toHighResThumbnail(String url) {
    if (url.isEmpty) return '';
    if (_thumbnailSizeRegex.hasMatch(url)) {
      return url.replaceFirst(_thumbnailSizeRegex, '=s800');
    }
    return url;
  }

  static bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

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

  static final List<({String id, String label})> _templateCategoryOptions =
      TemplateManager.categoryOptions
          .map((o) => (id: o.id, label: o.id))
          .toList();

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

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _searchFocusNode.addListener(_onSearchFocusChange);
    WidgetsBinding.instance.addObserver(this);
    _loadRecentForms();
    _fetchTemplateThumbnails();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<TemplateData> get _allTemplates => TemplateManager.templates;

  List<TemplateData> get _filteredTemplates {
    final base = TemplateManager.filtered(
      category: _templateCategory,
    );
    if (_searchQuery.isEmpty || _tabController.index != 1) {
      return base;
    }
    return base.where((t) {
      final name =
          AppStrings.templateName(context, t.translationKey).toLowerCase();
      final desc = AppStrings.templateDescription(context, t.translationKey)
          .toLowerCase();
      return name.contains(_searchQuery) || desc.contains(_searchQuery);
    }).toList();
  }

  bool get _showTemplateCategoryRows =>
      (_searchQuery.isEmpty || _tabController.index == 0) &&
      _templateCategory == 'all';

  String _templateCategoryLabel(String category) =>
      AppStrings.categoryLabel(context, category);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadRecentForms();
    }
  }

  Future<void> _loadRecentForms() async {
    setState(() {
      _isLoadingForms = true;
      _nextPageToken = null;
      _hasMoreForms = true;
    });
    final orderBy = switch (_sortBy) {
      'opened' => 'viewedByMeTime desc',
      'title' => 'name',
      _ => 'modifiedByMeTime desc',
    };
    final result = await _formsService.listRecentForms(
      orderBy: orderBy,
      ownershipFilter: _ownershipFilter,
    );

    // Create card data without form details first
    final cardData = result.forms
        .map(
          (f) => FormCardData(
            id: f['id'] ?? '',
            name: f['name'] ?? AppLocalizations.of(context).untitled,
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
        _nextPageToken = result.nextPageToken;
        _hasMoreForms = result.nextPageToken != null;
      });
      _updateFilteredForms();
    }

    // Fetch actual form data for each form in background
    _fetchFormDetails(cardData);
  }

  Future<void> _loadMoreForms() async {
    if (_isLoadingMoreForms || !_hasMoreForms) return;
    setState(() => _isLoadingMoreForms = true);

    final orderBy = switch (_sortBy) {
      'opened' => 'viewedByMeTime desc',
      'title' => 'name',
      _ => 'modifiedByMeTime desc',
    };
    final result = await _formsService.listRecentForms(
      orderBy: orderBy,
      ownershipFilter: _ownershipFilter,
      pageToken: _nextPageToken,
    );

    final newCards = result.forms
        .map(
          (f) => FormCardData(
            id: f['id'] ?? '',
            name: f['name'] ?? AppLocalizations.of(context).untitled,
            modifiedTime: f['modifiedTime'] ?? '',
            lastOpenedTime: f['lastOpenedTime'] ?? '',
            thumbnailLink: f['thumbnailLink'] ?? '',
          ),
        )
        .toList();

    if (mounted) {
      setState(() {
        _recentForms.addAll(newCards);
        _isLoadingMoreForms = false;
        _nextPageToken = result.nextPageToken;
        _hasMoreForms = result.nextPageToken != null;
      });
      _updateFilteredForms();
    }

    // Fetch form details for new cards
    _fetchFormDetails(newCards);
  }

  Future<void> _fetchFormDetails(List<FormCardData> cards) async {
    const batchSize = 5;
    for (int i = 0; i < cards.length; i += batchSize) {
      final batch = cards.sublist(
        i,
        i + batchSize > cards.length ? cards.length : i + batchSize,
      );
      final futures = batch.map((card) async {
        try {
          final form = await _formsService.getForm(card.id);
          return MapEntry(card.id, form);
        } catch (e) {
          debugPrint('Fetch form detail error for ${card.id}: $e');
          return null;
        }
      }).toList();

      final results = await Future.wait(futures);

      if (!mounted) return;
      setState(() {
        for (final entry in results) {
          if (entry == null) continue;
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

  Future<void> _fetchTemplateThumbnails() async {
    if (_isLoadingTemplateThumbnails) return;

    final templatesWithIds = _allTemplates
        .where((t) => t.formId.isNotEmpty)
        .toList();
    if (templatesWithIds.isEmpty) return;

    setState(() => _isLoadingTemplateThumbnails = true);

    final results = await Future.wait(
      templatesWithIds.map((template) async {
        final link = await _formsService.getThumbnailLink(template.formId);
        return MapEntry(template.formId, link ?? '');
      }),
    );

    if (!mounted) return;

    setState(() {
      for (final entry in results) {
        if (entry.value.isNotEmpty) {
          _templateThumbnails[entry.key] = entry.value;
        }
      }
      _isLoadingTemplateThumbnails = false;
    });
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
        SnackBar(
          content: Text(AppLocalizations.of(context).linkCopiedToClipboard),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteForm(String formId, int index) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteFormTitle),
        content: Text(l10n.deleteFormContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
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
          SnackBar(
            content: Text(l10n.formMovedToTrash),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDeleteForm),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _renameForm(FormCardData form) async {
    final l10n = AppLocalizations.of(context);
    final newName = await RenameFormDialog.show(
      context,
      initialName: form.name.isNotEmpty ? form.name : '',
    );

    if (newName == null || !mounted) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == form.name) return;

    final error = await _formsService.renameDriveFile(form.id, trimmed);
    if (!mounted) return;

    if (error == null) {
      final recentIndex = _recentForms.indexWhere((f) => f.id == form.id);
      if (recentIndex >= 0) {
        final existing = _recentForms[recentIndex];
        setState(() {
          _recentForms[recentIndex] = FormCardData(
            id: existing.id,
            name: trimmed,
            modifiedTime: existing.modifiedTime,
            lastOpenedTime: existing.lastOpenedTime,
            formData: existing.formData,
            thumbnailLink: existing.thumbnailLink,
          );
        });
        _updateFilteredForms();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.formRenamed),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToRename),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _duplicateForm(String formId) async {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.duplicatingForm),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    final result = await _formsService.duplicateForm(formId);
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (result != null) {
        _loadRecentForms();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.formDuplicated),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDuplicateForm),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F1F3),
        elevation: 0,
        centerTitle: true,
        leadingWidth: 0,
        leading: null,
        titleSpacing: 0,
        title: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(left: _isSearchFocused ? 4 : 48),
          child: TextField(
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
                  ? l10n.searchForms
                  : l10n.searchTemplates,
              hintStyle: const TextStyle(color: Color(0xFF080808), fontSize: 15, letterSpacing: -0.5),
              prefixIcon: _isSearchFocused
                  ? IconButton(
                      icon: Icon(
                        Symbols.arrow_back,
                        color: Colors.grey.shade600,
                        size: 22,
                      ),
                      onPressed: () {
                        _dismissKeyboard();
                      },
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    )
                  : Icon(
                      Symbols.search,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Symbols.clear,
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
        ),
        actions: [
          if (user != null)
            ClipRect(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: _isSearchFocused ? 0 : 48,
                child: OverflowBox(
                  maxWidth: 48,
                  maxHeight: 48,
                  alignment: Alignment.center,
                  child: IgnorePointer(
                    ignoring: _isSearchFocused,
                    child: IconButton(
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
                        Symbols.settings,
                        color: Color(0xFF5F6368),
                        size: 24,
                      ),
                      tooltip: l10n.settings,
                    ),
                  ),
                ),
              ),
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
          tabs: [
            Tab(text: l10n.tabMyForms),
            Tab(text: l10n.tabTemplates),
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
        child: const Icon(Symbols.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
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
      ),
    );
  }

  Future<void> _previewAndUseTemplate(TemplateData template) async {
    final l10n = AppLocalizations.of(context);
    if (template.formId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.templateComingSoon),
          backgroundColor: const Color(0xFF9E9E9E),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.loadingTemplate),
          ],
        ),
        duration: const Duration(seconds: 10),
      ),
    );

    final formData = await _formsService.getForm(template.formId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (formData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToLoadTemplate),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormEditorScreen.templatePreview(
          previewFormData: formData,
          templateSourceFormId: template.formId,
          templateDisplayName:
              AppStrings.templateName(context, template.translationKey),
        ),
      ),
    );

    if (!mounted) return;
    _loadRecentForms();
  }

  /// My Forms tab — Grid view wrapped in a white container (like Templates tab).
  Widget _buildMyFormsGridView() {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_headerTopRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_headerTopRadius),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 200) {
              _loadMoreForms();
            }
            return false;
          },
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
                        Expanded(
                          child: Text(
                            l10n.recentForms,
                            style: const TextStyle(
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
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.getAdaptiveGridCount(
                          context,
                        ),
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const _SkeletonFormCard(),
                        childCount: 6,
                      ),
                    ),
                  )
                else if (_recentForms.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Symbols.description,
                              size: 64,
                              color: Color(0xFFDADCE0),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noRecentForms,
                              style: const TextStyle(
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
                              Symbols.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noFormsMatching(_searchQuery),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.tryDifferentSearch,
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
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.getAdaptiveGridCount(
                          context,
                        ),
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

                // Loading more indicator
                if (_isLoadingMoreForms)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF673AB7),
                          ),
                        ),
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 80),
                    child: Center(
                      child: Text(
                        _hasMoreForms
                            ? ''
                            : l10n.thisIsTheEnd,
                        style: const TextStyle(
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
      ),
    );
  }

  /// My Forms tab — List view with the original layout (unchanged).
  Widget _buildMyFormsListView() {
    final l10n = AppLocalizations.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          _loadMoreForms();
        }
        return false;
      },
      child: RefreshIndicator(
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
                      Expanded(
                        child: Text(
                          l10n.recentForms,
                          style: const TextStyle(
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
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: _itemHorizontalPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0 : _itemSpacing / 2,
                        bottom: _itemSpacing / 2,
                      ),
                      child: const _SkeletonFormListCard(),
                    ),
                    childCount: 10,
                  ),
                ),
              )
            else if (_recentForms.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Symbols.description,
                          size: 64,
                          color: Color(0xFFDADCE0),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noRecentForms,
                          style: const TextStyle(
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
                          Symbols.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noFormsMatching(_searchQuery),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tryDifferentSearch,
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

            // Loading more indicator
            if (_isLoadingMoreForms)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 80),
                child: Center(
                  child: Text(
                    _hasMoreForms
                        ? ''
                        : l10n.thisIsTheEnd,
                    style: const TextStyle(
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
    );
  }

  Widget _buildTemplatesTab() {
    final l10n = AppLocalizations.of(context);
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
              Center(
                child: Text(
                  l10n.thisIsTheEnd,
                  style: const TextStyle(
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
            label: Text(AppStrings.categoryLabel(context, option.id)),
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

  Widget _buildFormPreviewMockup(TemplateData template, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
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

  Widget _buildTemplateThumbnailFallback(TemplateData template) {
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
              AppStrings.templateName(context, template.translationKey),
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

  Widget _buildTemplateThumbnailArea(TemplateData template) {
    final isComingSoon = template.formId.isEmpty;

    if (isComingSoon) {
      return _buildFormPreviewMockup(template, opacity: 0.5);
    }

    final thumbnailLink = _templateThumbnails[template.formId];
    if (thumbnailLink == null || thumbnailLink.isEmpty) {
      return _buildFormPreviewMockup(template);
    }

    final highResUrl = _toHighResThumbnail(thumbnailLink);
    if (!_isValidImageUrl(highResUrl)) {
      return _buildFormPreviewMockup(template);
    }

    return SafeImageLoader(
      url: highResUrl,
      headers: const {'Accept': 'image/*'},
      fit: BoxFit.cover,
      cacheWidth: 400,
      fallback: _buildTemplateThumbnailFallback(template),
    );
  }

  Widget _buildTemplateCard(TemplateData template) {
    final l10n = AppLocalizations.of(context);
    final isComingSoon = template.formId.isEmpty;
    final templateName =
        AppStrings.templateName(context, template.translationKey);
    final templateDescription =
        AppStrings.templateDescription(context, template.translationKey);

    return GestureDetector(
      onTap: () => _previewAndUseTemplate(template),
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTemplateThumbnailArea(template),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          templateName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF202124),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          templateDescription,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF5F6368),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  child: Text(
                    l10n.soon,
                    style: const TextStyle(
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
    );
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
            AppLocalizations.of(context).templateCount(count),
            style: const TextStyle(fontSize: 12, color: Color(0xFF80868B)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllCategoriesView() {
    const categories = ['community', 'education', 'health', 'work'];
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.getAdaptiveGridCount(context),
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
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
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.getAdaptiveGridCount(context),
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          return _buildTemplateCard(templates[index]);
        },
      ),
    );
  }

  Widget _buildTemplateSearchEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Symbols.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.noTemplatesMatching(_searchQuery),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryDifferentSearchOrCategory,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    final l10n = AppLocalizations.of(context);
    final filterOptions = {
      'anyone': (l10n.ownedByAnyone, Symbols.people_outline),
      'me': (l10n.ownedByMe, Symbols.person_outline),
      'not_me': (l10n.notOwnedByMe, Symbols.person_off),
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
                const Icon(Symbols.check, size: 18, color: Color(0xFF673AB7)),
            ],
          ),
        );
      }).toList(),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Icon(
            Symbols.filter_alt,
            size: 18,
            color: const Color(0xFF5F6368),
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    final l10n = AppLocalizations.of(context);
    final sortOptions = {
      'modified': (l10n.lastModified, Symbols.schedule),
      'opened': (l10n.lastOpened, Symbols.visibility),
      'title': (l10n.titleAZ, Symbols.sort_by_alpha),
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
                const Icon(Symbols.check, size: 18, color: Color(0xFF673AB7)),
            ],
          ),
        );
      }).toList(),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: const Icon(
            Symbols.sort_by_alpha,
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
                Symbols.view_list,
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
                Symbols.grid_view,
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
    final l10n = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF673AB7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Symbols.description,
              color: Colors.white70,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              form.name.isNotEmpty ? form.name : l10n.untitled,
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
    final l10n = AppLocalizations.of(context);
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
              child: form.highResThumbnail.isNotEmpty &&
                      _isValidImageUrl(form.highResThumbnail)
                  ? SafeImageLoader(
                      url: form.highResThumbnail,
                      headers: const {'Accept': 'image/*'},
                      fit: BoxFit.cover,
                      cacheWidth: 400,
                      fallback: _buildThumbnailFallback(form),
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
                            form.name.isNotEmpty ? form.name : l10n.untitled,
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
                            case 'rename':
                              _renameForm(form);
                            case 'share':
                              _shareForm(form.id);
                            case 'delete':
                              _deleteForm(form.id, index);
                            case 'duplicate':
                              _duplicateForm(form.id);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                const Icon(
                                  Symbols.text_fields,
                                  size: 20,
                                  color: Color(0xFF5F6368),
                                ),
                                const SizedBox(width: 12),
                                Text(l10n.rename),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                const Icon(
                                  Symbols.link,
                                  size: 20,
                                  color: Color(0xFF5F6368),
                                ),
                                const SizedBox(width: 12),
                                Text(l10n.copyLink),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                const Icon(
                                  Symbols.content_copy,
                                  size: 20,
                                  color: Color(0xFF5F6368),
                                ),
                                const SizedBox(width: 12),
                                Text(l10n.duplicate),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Symbols.delete_outline,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Symbols.more_vert,
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
    final l10n = AppLocalizations.of(context);
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
              leading: const Icon(
                Symbols.text_fields,
                color: Color(0xFF5F6368),
              ),
              title: Text(l10n.rename),
              onTap: () {
                Navigator.pop(context);
                _renameForm(form);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.link, color: Color(0xFF5F6368)),
              title: Text(l10n.copyLink),
              onTap: () {
                Navigator.pop(context);
                _shareForm(form.id);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.content_copy, color: Color(0xFF5F6368)),
              title: Text(l10n.duplicate),
              onTap: () {
                Navigator.pop(context);
                _duplicateForm(form.id);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.delete_outline, color: Colors.red),
              title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
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
    final l10n = AppLocalizations.of(context);
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
                    Symbols.list_alt,
                    color: Color(0xFF673AB7),
                    size: 20,
                    fill: 1,
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
                      form.name.isNotEmpty ? form.name : l10n.untitled,
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
                    case 'rename':
                      _renameForm(form);
                      break;
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
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(
                          Symbols.text_fields,
                          size: 20,
                          color: Color(0xFF5F6368),
                        ),
                        const SizedBox(width: 12),
                        Text(l10n.rename),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        const Icon(Symbols.link, size: 20, color: Color(0xFF5F6368)),
                        const SizedBox(width: 12),
                        Text(l10n.copyLink),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        const Icon(
                          Symbols.content_copy,
                          size: 20,
                          color: Color(0xFF5F6368),
                        ),
                        const SizedBox(width: 12),
                        Text(l10n.duplicate),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Symbols.delete_outline, size: 20, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(
                  Symbols.more_vert,
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

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const _ShimmerBox({
    this.width,
    this.height = 14,
    this.radius = 4,
    this.color = const Color(0xFFE8EAED),
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: [
                widget.color,
                widget.color.withValues(alpha: 0.3),
                widget.color,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonFormCard extends StatelessWidget {
  const _SkeletonFormCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          const Expanded(
            flex: 3,
            child: ColoredBox(
              color: Color(0xFFE8EAED),
              child: Center(
                child: Icon(
                  Symbols.description,
                  color: Color(0xFFDADCE0),
                  size: 32,
                ),
              ),
            ),
          ),
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
                      children: const [
                        _ShimmerBox(height: 12, width: 80),
                        SizedBox(height: 6),
                        _ShimmerBox(height: 10, width: 60, color: Color(0xFFF1F3F4)),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: _ShimmerBox(width: 16, height: 16, radius: 2, color: Color(0xFFF1F3F4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonFormListCard extends StatelessWidget {
  const _SkeletonFormListCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
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
          const _ShimmerBox(width: 40, height: 40, radius: 8),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _ShimmerBox(height: 14, width: 160),
                SizedBox(height: 6),
                _ShimmerBox(height: 10, width: 90, color: Color(0xFFF1F3F4)),
              ],
            ),
          ),
          const _ShimmerBox(width: 20, height: 20, radius: 2, color: Color(0xFFF1F3F4)),
        ],
      ),
    );
  }
}
