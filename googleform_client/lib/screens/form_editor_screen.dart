import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:excel/excel.dart' as excel_lib;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/form_model.dart';
import '../models/question_model.dart';
import '../models/response_model.dart';
import '../services/apps_script_service.dart';
import '../services/google_auth_service.dart';
import '../services/google_forms_service.dart';
import '../utils/responsive.dart';

class FormEditorScreen extends StatefulWidget {
  final String? formId;

  const FormEditorScreen({super.key, this.formId});

  @override
  State<FormEditorScreen> createState() => _FormEditorScreenState();
}

class _FormEditorScreenState extends State<FormEditorScreen>
    with SingleTickerProviderStateMixin {
  final GoogleFormsService _formsService = GoogleFormsService();
  final AppsScriptService _appsScriptService = AppsScriptService();
  final GoogleAuthService _authService = GoogleAuthService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<QuestionItem> _questions = [];
  List<GlobalKey> _questionKeys = [];
  List<TextEditingController> _questionControllers = [];
  List<List<TextEditingController>> _optionControllers = [];
  List<TextEditingController> _videoUrlControllers = [];

  // Grid controllers (per question: list of row controllers, list of column controllers)
  List<List<TextEditingController>> _gridRowControllers = [];
  List<List<TextEditingController>> _gridColControllers = [];

  // Scale label controllers
  List<TextEditingController?> _scaleLowLabelControllers = [];
  List<TextEditingController?> _scaleHighLabelControllers = [];

  // Section description controllers (keyed by index, lazily created)
  final Map<int, TextEditingController> _sectionDescriptionControllers = {};

  bool _isSaving = false;
  bool _isLoading = false;
  bool _isDirty = false;

  // Drag-to-reorder state
  static const double _kReorderCollapsedCardHeight = 52.0;
  static const double _kReorderItemBottomPadding = 12.0;
  static const Duration _kReorderCollapseLeadTime = Duration(milliseconds: 550);
  int? _collapsedForReorderIndex;
  bool _reorderDragActive = false;
  Timer? _reorderHoldTimer;
  int? _pendingReorderHoldIndex;

  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  String? _responderUri;
  WebViewController? _webViewController;

  // Response tab state
  List<FormResponse> _responses = [];
  bool _isLoadingResponses = false;
  bool _hasLoadedResponses = false;
  int _responseOrderEpoch = 0;
  int _responseSubTab = 0; // 0=Summary, 1=Question, 2=Individual
  final PageController _responseSubTabController = PageController(initialPage: 0);
  int _selectedQuestionIndex = 0;
  int _selectedIndividualIndex = 0;

  // Settings state
  bool _isLoadingSettings = true;
  bool _isPublished = false;
  bool _isPublishing = false;
  bool _isAcceptingResponses = true;
  bool _collectEmail = false;
  String _emailCollectionType = 'none'; // 'none', 'verified', 'responder_input'
  bool _sendResponseCopy = false;
  bool _limitOneResponse = false;
  bool _editAfterSubmit = false;
  bool _showProgressBar = false;
  final TextEditingController _confirmationMessageController =
      TextEditingController(text: 'Your response has been recorded.');
  bool _shuffleQuestions = false;

  // Linked sheet state
  String? _linkedSheetId;
  String? _linkedSheetTitle;

  // Editors state
  List<FormEditor> _editors = [];
  FormEditor? _owner;
  bool _isLoadingEditors = false;

  bool get _isCurrentUserOwner {
    final currentEmail = _authService.currentUser?.email.toLowerCase();
    final ownerEmail = _owner?.email.toLowerCase();
    return currentEmail != null &&
        ownerEmail != null &&
        currentEmail == ownerEmail;
  }

  // Mutable form ID — tracks the current form after save operations
  // (unlike widget.formId which is immutable and becomes stale after save)
  String? _currentFormId;
  FormModel? _originalForm; // Original form data from API, used for diff detection

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Title updates handled by ListenableBuilder in AppBar to avoid full rebuilds
    _currentFormId = widget.formId;
    if (_currentFormId != null) {
      _loadExistingForm();
    } else {
      // New form — no settings to load
      _isLoadingSettings = false;
    }
  }

  Future<void> _loadExistingForm() async {
    setState(() => _isLoading = true);

    // Single API call: form data + publish settings + shuffle in one request
    final formData = await _formsService.getFormWithAllData(_currentFormId!);
    final form = formData['form'] as FormModel?;
    if (!mounted) return;

    if (form != null) {
      _originalForm = form;
      _titleController.text = form.title;
      _descriptionController.text = form.description;

      // Dispose old controllers
      for (var c in _questionControllers) {
        c.dispose();
      }
      for (var list in _optionControllers) {
        for (var c in list) {
          c.dispose();
        }
      }
      for (var c in _videoUrlControllers) {
        c.dispose();
      }
      for (var list in _gridRowControllers) {
        for (var c in list) {
          c.dispose();
        }
      }
      for (var list in _gridColControllers) {
        for (var c in list) {
          c.dispose();
        }
      }
      for (var c in _scaleLowLabelControllers) {
        c?.dispose();
      }
      for (var c in _scaleHighLabelControllers) {
        c?.dispose();
      }
      for (var c in _sectionDescriptionControllers.values) {
        c.dispose();
      }
      _sectionDescriptionControllers.clear();

      // Extract publish settings & shuffle from the same API response
      final isPublished = formData['isPublished'] as bool? ?? false;
      final isAcceptingResponses =
          formData['isAcceptingResponses'] as bool? ?? false;
      final shuffleQuestions = formData['shuffleQuestions'] as bool?;

      setState(() {
        _questions = form.questions;
        _questionKeys = form.questions.map((_) => GlobalKey()).toList();
        _questionControllers = form.questions
            .map((q) => TextEditingController(text: q.questionText))
            .toList();
        _optionControllers = form.questions
            .map(
              (q) =>
                  q.options.map((o) => TextEditingController(text: o)).toList(),
            )
            .toList();
        _videoUrlControllers = form.questions
            .map((q) => TextEditingController(text: q.mediaUrl ?? ''))
            .toList();
        _gridRowControllers = form.questions
            .map(
              (q) => q.gridRows
                  .map((r) => TextEditingController(text: r))
                  .toList(),
            )
            .toList();
        _gridColControllers = form.questions
            .map(
              (q) => q.gridColumns
                  .map((c) => TextEditingController(text: c))
                  .toList(),
            )
            .toList();
        _scaleLowLabelControllers = form.questions
            .map(
              (q) => q.scaleLowLabel != null
                  ? TextEditingController(text: q.scaleLowLabel)
                  : null,
            )
            .toList();
        _scaleHighLabelControllers = form.questions
            .map(
              (q) => q.scaleHighLabel != null
                  ? TextEditingController(text: q.scaleHighLabel)
                  : null,
            )
            .toList();
        for (int i = 0; i < form.questions.length; i++) {
          final q = form.questions[i];
          if (q.type == QuestionType.section && q.description != null) {
            _sectionDescriptionControllers[i] = TextEditingController(text: q.description);
          }
        }
        _responderUri = form.responderUri;
        _emailCollectionType = form.emailCollectionType;
        _collectEmail = _emailCollectionType != 'none';
        _linkedSheetId = form.linkedSheetId;
        // Apply publish settings from the same API call
        _isPublished = isPublished;
        _isAcceptingResponses = isAcceptingResponses;
        // Apply shuffle from the same API call (may be overridden by Apps Script)
        if (shuffleQuestions != null) {
          _shuffleQuestions = shuffleQuestions;
        }
        _isLoading = false;
      });

      // Run independent API calls in parallel
      final futures = <Future<void>>[];

      if (_appsScriptService.isConfigured && _currentFormId != null) {
        futures.add(_loadFormSettings());
      }

      futures.add(_loadEditors());

      if (_linkedSheetId != null) {
        futures.add(_loadLinkedSheetInfo());
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures);
        if (!mounted) return;
      }

      // All settings have finished loading
      if (mounted) {
        _safeSetState(() => _isLoadingSettings = false);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingSettings = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load form.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cancelReorderHoldTimer();
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _responseSubTabController.dispose();
    _confirmationMessageController.dispose();
    for (var c in _questionControllers) {
      c.dispose();
    }
    for (var list in _optionControllers) {
      for (var c in list) {
        c.dispose();
      }
    }
    for (var c in _videoUrlControllers) {
      c.dispose();
    }
    for (var list in _gridRowControllers) {
      for (var c in list) {
        c.dispose();
      }
    }
    for (var list in _gridColControllers) {
      for (var c in list) {
        c.dispose();
      }
    }
    for (var c in _scaleLowLabelControllers) {
      c?.dispose();
    }
    for (var c in _scaleHighLabelControllers) {
      c?.dispose();
    }
    for (var c in _sectionDescriptionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isNonOptionType(QuestionType type) {
    return type == QuestionType.shortAnswer ||
        type == QuestionType.paragraph ||
        type == QuestionType.image ||
        type == QuestionType.video ||
        type == QuestionType.linearScale ||
        type == QuestionType.multipleChoiceGrid ||
        type == QuestionType.checkboxGrid ||
        type == QuestionType.date ||
        type == QuestionType.time ||
        type == QuestionType.info ||
        type == QuestionType.section;
  }

  bool _isGridType(QuestionType type) {
    return type == QuestionType.multipleChoiceGrid ||
        type == QuestionType.checkboxGrid;
  }

  /// Returns the total number of sections (always at least 1 — the implicit first section).
  int _getSectionCount() {
    final explicitSections =
        _questions.where((q) => q.type == QuestionType.section).length;
    return explicitSections + 1;
  }

  /// Returns (sectionNumber, totalSections) for the item at [questionIndex].
  /// The form info card (before any section items) is section 1.
  /// Each section item starts a new section, so a section item at index i
  /// belongs to section (count of sections before i + 1).
  /// Non-section items belong to the section they appear after.
  (int, int) _getSectionInfo(int questionIndex) {
    int sectionNumber = 1;
    for (int i = 0; i < questionIndex; i++) {
      if (_questions[i].type == QuestionType.section) {
        sectionNumber++;
      }
    }
    // If this item itself is a section, it represents the start of a new section
    if (_questions[questionIndex].type == QuestionType.section) {
      sectionNumber++;
    }
    return (sectionNumber, _getSectionCount());
  }

  void _markDirty() {
    if (!_isDirty) _isDirty = true;
  }

  /// Unfocus any text field before *and after* calling setState so the keyboard
  /// does not re-appear after the user has explicitly dismissed it.
  /// The post-frame callback catches cases where a newly built TextField grabs
  /// focus during the rebuild (e.g. after adding a new question).
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(fn);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).unfocus();
    });
  }

  Future<void> _handleBackPress() async {
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text(
          'You have unsaved changes. Do you want to save before leaving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF673AB7)),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result == 'discard') {
      Navigator.of(context).pop();
    } else if (result == 'save') {
      await _saveForm();
      if (!mounted) return;
      // Only pop if save succeeded (not dirty anymore means save succeeded)
      if (!_isDirty) {
        Navigator.of(context).pop();
      }
    }
    // 'cancel' or null → do nothing, stay on the page
  }

  int _previousTabIndex = 0;

  Future<void> _handleTabChange() async {
    if (_tabController.indexIsChanging) {
      if (mounted) _safeSetState(() {});
      return;
    }

    final currentIndex = _tabController.index;

    // When switching to Preview tab with unsaved changes
    if (currentIndex == 1 && _isDirty) {
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unsaved changes'),
          content: const Text(
            'Save your form to see the latest preview of your changes.',
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'continue'),
              child: const Text(
                'Don\'t save',
                style: TextStyle(color: Color(0xFF5F6368)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF673AB7)),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (result == 'cancel' || result == null) {
        // Revert to previous tab
        _tabController.animateTo(_previousTabIndex);
        return;
      } else if (result == 'save') {
        await _saveForm();
        if (!mounted) return;
        if (_isDirty) {
          // Save failed, revert to previous tab
          _tabController.animateTo(_previousTabIndex);
          return;
        }
      }
      // 'continue' → proceed to Preview tab
    }

    // Load responses when switching to Responses tab
    if (currentIndex == 2 && _currentFormId != null) {
      _loadResponsesForTab();
    }

    _previousTabIndex = currentIndex;
  }

  void _addQuestion(QuestionType type) {
    _markDirty();
    _safeSetState(() {
      final q = QuestionItem();
      q.type = type;
      if (_isNonOptionType(type)) {
        q.options = [];
      }
      if (_isGridType(type)) {
        q.gridRows = [''];
        q.gridColumns = ['', ''];
      }
      // Info type defaults to showing description
      if (type == QuestionType.info) {
        q.showDescription = true;
      }
      // Section type defaults to showing description
      if (type == QuestionType.section) {
        q.showDescription = true;
      }
      _questions.add(q);
      _questionKeys.add(GlobalKey());
      _questionControllers.add(TextEditingController());
      if (_isNonOptionType(type)) {
        _optionControllers.add([]);
      } else {
        _optionControllers.add([TextEditingController()]);
      }
      _videoUrlControllers.add(TextEditingController());

      // Grid controllers
      if (_isGridType(type)) {
        _gridRowControllers.add([TextEditingController()]);
        _gridColControllers.add([
          TextEditingController(),
          TextEditingController(),
        ]);
      } else {
        _gridRowControllers.add([]);
        _gridColControllers.add([]);
      }

      // Scale controllers
      if (type == QuestionType.linearScale) {
        _scaleLowLabelControllers.add(null);
        _scaleHighLabelControllers.add(null);
      } else {
        _scaleLowLabelControllers.add(null);
        _scaleHighLabelControllers.add(null);
      }
    });
    // Scroll to the newly added question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _questionKeys.isEmpty || !_scrollController.hasClients) return;
      // Ensure keyboard stays dismissed after the new question card is built
      FocusScope.of(context).unfocus();
      final key = _questionKeys.last;
      final ctx = key.currentContext;
      if (ctx != null) {
        // Widget already in viewport, scroll directly
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      } else {
        // Widget not rendered yet (off-screen), jump to bottom first
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          FocusScope.of(context).unfocus();
          final ctx = key.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.0,
            );
          }
        });
      }
    });
  }

  void _showAddQuestionDialog() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADCE0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add question',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202124),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Question type blocks
                GridView.count(
                  crossAxisCount: Responsive.getQuestionTypeGridCount(ctx),
                  shrinkWrap: true,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.radio_button_checked,
                      label: 'Multiple\nchoice',
                      color: const Color(0xFF7B1FA2),
                      type: QuestionType.multipleChoice,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.check_box,
                      label: 'Checkboxes',
                      color: const Color(0xFF1565C0),
                      type: QuestionType.checkbox,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.arrow_drop_down_circle,
                      label: 'Dropdown',
                      color: const Color(0xFFAD1457),
                      type: QuestionType.dropdown,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.linear_scale,
                      label: 'Linear\nscale',
                      color: const Color(0xFF00695C),
                      type: QuestionType.linearScale,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.grid_on,
                      label: 'Multiple\nchoice grid',
                      color: const Color(0xFF4527A0),
                      type: QuestionType.multipleChoiceGrid,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.checklist_rtl,
                      label: 'Checkbox\ngrid',
                      color: const Color(0xFF1B5E20),
                      type: QuestionType.checkboxGrid,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.short_text,
                      label: 'Short\nanswer',
                      color: const Color(0xFF2E7D32),
                      type: QuestionType.shortAnswer,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.notes,
                      label: 'Paragraph',
                      color: const Color(0xFFE65100),
                      type: QuestionType.paragraph,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.calendar_today,
                      label: 'Date',
                      color: const Color(0xFF0277BD),
                      type: QuestionType.date,
                    ),
                    _buildQuestionTypeBlock(
                      ctx,
                      icon: Icons.access_time,
                      label: 'Time',
                      color: const Color(0xFFBF360C),
                      type: QuestionType.time,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionTypeBlock(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required Color color,
    required QuestionType type,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () {
              Navigator.pop(ctx);
              _addQuestion(type);
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: enabled ? 0.3 : 0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color.withValues(alpha: enabled ? 1.0 : 0.4),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: enabled ? 1.0 : 0.4),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeQuestion(int index) {
    if (_questions.isEmpty) return;
    _markDirty();
    // Remember the target question (the one above the deleted item, or first)
    final targetIndex = index > 0 ? index - 1 : 0;
    _safeSetState(() {
      _questions.removeAt(index);
      _questionKeys.removeAt(index);
      _questionControllers[index].dispose();
      _questionControllers.removeAt(index);
      for (var c in _optionControllers[index]) {
        c.dispose();
      }
      _optionControllers.removeAt(index);
      _videoUrlControllers[index].dispose();
      _videoUrlControllers.removeAt(index);
      for (var c in _gridRowControllers[index]) {
        c.dispose();
      }
      _gridRowControllers.removeAt(index);
      for (var c in _gridColControllers[index]) {
        c.dispose();
      }
      _gridColControllers.removeAt(index);
      _scaleLowLabelControllers[index]?.dispose();
      _scaleLowLabelControllers.removeAt(index);
      _scaleHighLabelControllers[index]?.dispose();
      _scaleHighLabelControllers.removeAt(index);
      // Rebuild section description controllers map with shifted indices
      final oldSectionDesc = Map<int, TextEditingController>.from(_sectionDescriptionControllers);
      _sectionDescriptionControllers.clear();
      _sectionDescriptionControllers[index]?.dispose();
      for (final entry in oldSectionDesc.entries) {
        if (entry.key < index) {
          _sectionDescriptionControllers[entry.key] = entry.value;
        } else if (entry.key > index) {
          _sectionDescriptionControllers[entry.key - 1] = entry.value;
        }
      }
    });

    // Scroll so the target question's top edge aligns with the tab bar.
    // When the last question is deleted, animate to the top instead.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      if (_questionKeys.isEmpty) {
        // Last question was deleted — animate to top of the list
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
        return;
      }
      final clamped = targetIndex.clamp(0, _questionKeys.length - 1);
      final key = _questionKeys[clamped];
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  void _duplicateQuestion(int index) {
    _markDirty();
    _safeSetState(() {
      final original = _questions[index];
      final dup = original.copyWith();
      _questions.insert(index + 1, dup);
      _questionKeys.insert(index + 1, GlobalKey());
      _questionControllers.insert(
        index + 1,
        TextEditingController(text: dup.questionText),
      );
      _optionControllers.insert(
        index + 1,
        dup.options.map((o) => TextEditingController(text: o)).toList(),
      );
      _videoUrlControllers.insert(
        index + 1,
        TextEditingController(text: dup.mediaUrl ?? ''),
      );
      _gridRowControllers.insert(
        index + 1,
        dup.gridRows.map((r) => TextEditingController(text: r)).toList(),
      );
      _gridColControllers.insert(
        index + 1,
        dup.gridColumns.map((c) => TextEditingController(text: c)).toList(),
      );
      _scaleLowLabelControllers.insert(
        index + 1,
        dup.scaleLowLabel != null
            ? TextEditingController(text: dup.scaleLowLabel)
            : null,
      );
      _scaleHighLabelControllers.insert(
        index + 1,
        dup.scaleHighLabel != null
            ? TextEditingController(text: dup.scaleHighLabel)
            : null,
      );
      // Rebuild section description controllers map with shifted indices
      if (dup.type == QuestionType.section && dup.description != null) {
        final oldSectionDesc = Map<int, TextEditingController>.from(_sectionDescriptionControllers);
        _sectionDescriptionControllers.clear();
        for (final entry in oldSectionDesc.entries) {
          if (entry.key <= index) {
            _sectionDescriptionControllers[entry.key] = entry.value;
          } else {
            _sectionDescriptionControllers[entry.key + 1] = entry.value;
          }
        }
        _sectionDescriptionControllers[index + 1] = TextEditingController(text: dup.description ?? '');
      } else {
        final oldSectionDesc = Map<int, TextEditingController>.from(_sectionDescriptionControllers);
        _sectionDescriptionControllers.clear();
        for (final entry in oldSectionDesc.entries) {
          if (entry.key <= index) {
            _sectionDescriptionControllers[entry.key] = entry.value;
          } else {
            _sectionDescriptionControllers[entry.key + 1] = entry.value;
          }
        }
      }
    });

    // Scroll so the duplicated question's top edge aligns with the tab bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      final key = _questionKeys[index + 1];
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  void _moveParallelLists(int oldIndex, int newIndex) {
    void moveItem<T>(List<T> list) {
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
    }

    moveItem(_questions);
    moveItem(_questionKeys);
    moveItem(_questionControllers);
    moveItem(_optionControllers);
    moveItem(_videoUrlControllers);
    moveItem(_gridRowControllers);
    moveItem(_gridColControllers);
    moveItem(_scaleLowLabelControllers);
    moveItem(_scaleHighLabelControllers);
    _remapSectionDescriptionControllersOnMove(oldIndex, newIndex);
  }

  void _remapSectionDescriptionControllersOnMove(int oldIndex, int newIndex) {
    final oldMap =
        Map<int, TextEditingController>.from(_sectionDescriptionControllers);
    _sectionDescriptionControllers.clear();

    int newKeyFor(int oldKey) {
      if (oldKey == oldIndex) return newIndex;
      if (oldIndex < newIndex) {
        if (oldKey > oldIndex && oldKey <= newIndex) return oldKey - 1;
      } else if (oldIndex > newIndex) {
        if (oldKey >= newIndex && oldKey < oldIndex) return oldKey + 1;
      }
      return oldKey;
    }

    for (final entry in oldMap.entries) {
      _sectionDescriptionControllers[newKeyFor(entry.key)] = entry.value;
    }
  }

  void _reorderQuestions(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _questions.length) return;
    if (newIndex < 0 || newIndex >= _questions.length) return;

    // Sections cannot be reordered
    if (_questions[oldIndex].type == QuestionType.section) return;

    HapticFeedback.selectionClick();
    _markDirty();
    _safeSetState(() {
      // onReorderItem provides newIndex already adjusted for removal.
      _moveParallelLists(oldIndex, newIndex);
      _responseOrderEpoch++;
    });
  }

  bool _isResponseExcludedType(QuestionType type) {
    return type == QuestionType.image ||
        type == QuestionType.video ||
        type == QuestionType.info ||
        type == QuestionType.section;
  }

  /// Indices into [_questions] for items shown in the Responses tab.
  List<int> _answerableQuestionIndices() {
    final indices = <int>[];
    for (int i = 0; i < _questions.length; i++) {
      if (!_isResponseExcludedType(_questions[i].type)) {
        indices.add(i);
      }
    }
    return indices;
  }

  int _displayNumberForQuestionIndex(int questionIndex) {
    final indices = _answerableQuestionIndices();
    final pos = indices.indexOf(questionIndex);
    return pos >= 0 ? pos + 1 : questionIndex + 1;
  }

  void _applyQuestionOrderPermutation(List<int> targetOrder) {
    if (targetOrder.length != _questions.length) return;

    final current = List<int>.generate(_questions.length, (i) => i);
    for (int pos = 0; pos < targetOrder.length; pos++) {
      final wantOriginalIdx = targetOrder[pos];
      final curPos = current.indexOf(wantOriginalIdx);
      if (curPos == pos) continue;
      _moveParallelLists(curPos, pos);
      final moved = current.removeAt(curPos);
      current.insert(pos, moved);
    }
  }

  /// Realign local editor lists with the server form order (by item id).
  void _syncQuestionsOrderFromSavedForm(FormModel savedForm) {
    if (savedForm.questions.isEmpty ||
        savedForm.questions.length != _questions.length) {
      return;
    }

    _syncAllFields();

    final localById = <String, int>{};
    for (int i = 0; i < _questions.length; i++) {
      final id = _questions[i].itemId;
      if (id.isNotEmpty) {
        localById[id] = i;
      }
    }

    final targetOrder = <int>[];
    final used = <int>{};
    for (final sq in savedForm.questions) {
      final id = sq.itemId;
      if (id.isNotEmpty && localById.containsKey(id)) {
        targetOrder.add(localById[id]!);
        used.add(localById[id]!);
      }
    }
    for (int i = 0; i < _questions.length; i++) {
      if (!used.contains(i)) {
        targetOrder.add(i);
      }
    }
    if (targetOrder.length != _questions.length) return;

    final identity = List<int>.generate(_questions.length, (i) => i);
    if (listEquals(targetOrder, identity)) return;

    _applyQuestionOrderPermutation(targetOrder);
    _responseOrderEpoch++;
  }

  void _cancelReorderHoldTimer() {
    _reorderHoldTimer?.cancel();
    _reorderHoldTimer = null;
  }

  void _onDragHandlePointerDown(int index) {
    _cancelReorderHoldTimer();
    _pendingReorderHoldIndex = index;
    _reorderHoldTimer = Timer(_kReorderCollapseLeadTime, () {
      if (!mounted || _pendingReorderHoldIndex != index) return;
      _prepareReorderCollapse(index);
    });
  }

  void _onDragHandlePointerUp() {
    _cancelReorderHoldTimer();
    _pendingReorderHoldIndex = null;
    _scheduleReorderExpandIfNeeded();
  }

  void _prepareReorderCollapse(int index) {
    if (_collapsedForReorderIndex == index && !_reorderDragActive) return;
    _safeSetState(() {
      _collapsedForReorderIndex = index;
      _reorderDragActive = false;
    });
  }

  void _onReorderDragStart(int index) {
    _safeSetState(() {
      _collapsedForReorderIndex = index;
      _reorderDragActive = true;
    });
  }

  void _onReorderDragEnd() {
    _safeSetState(() {
      _collapsedForReorderIndex = null;
      _reorderDragActive = false;
    });
  }

  void _scheduleReorderExpandIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final delay = _reorderDragActive
          ? const Duration(milliseconds: 350)
          : const Duration(milliseconds: 50);
      Future.delayed(delay, () {
        if (!mounted) return;
        if (_collapsedForReorderIndex != null) {
          _safeSetState(() {
            _collapsedForReorderIndex = null;
            _reorderDragActive = false;
          });
        }
      });
    });
  }

  Widget _buildReorderCollapsedCard(int index) {
    final question = _questions[index];
    return SizedBox(
      height: _kReorderCollapsedCardHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDADCE0), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              _questionTypeIcon(question.type),
              color: const Color(0xFF673AB7),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                question.questionText.isEmpty
                    ? 'Untitled Question'
                    : question.questionText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.drag_indicator,
              color: Color(0xFF9AA0A6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(int index) {
    return Listener(
      onPointerDown: (_) => _onDragHandlePointerDown(index),
      onPointerUp: (_) => _onDragHandlePointerUp(),
      onPointerCancel: (_) => _onDragHandlePointerUp(),
      child: _OneSecondReorderDragStartListener(
        index: index,
        child: Semantics(
          label: 'Drag to reorder question',
          button: true,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: Icon(
                    Icons.drag_indicator,
                    color: const Color(0xFF9AA0A6),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addOption(int questionIndex) {
    _markDirty();
    _safeSetState(() {
      _questions[questionIndex].options.add('');
      _optionControllers[questionIndex].add(TextEditingController());
    });
  }

  void _removeOption(int questionIndex, int optionIndex) {
    if (_questions[questionIndex].options.length <= 1) return;
    _markDirty();
    _safeSetState(() {
      _questions[questionIndex].options.removeAt(optionIndex);
      _optionControllers[questionIndex][optionIndex].dispose();
      _optionControllers[questionIndex].removeAt(optionIndex);
    });
  }

  // Grid row/column management
  void _addGridRow(int questionIndex) {
    _markDirty();
    _safeSetState(() {
      _questions[questionIndex].gridRows.add('');
      _gridRowControllers[questionIndex].add(TextEditingController());
    });
  }

  void _removeGridRow(int questionIndex, int rowIndex) {
    if (_questions[questionIndex].gridRows.length <= 1) return;
    _markDirty();
    _safeSetState(() {
      _questions[questionIndex].gridRows.removeAt(rowIndex);
      _gridRowControllers[questionIndex][rowIndex].dispose();
      _gridRowControllers[questionIndex].removeAt(rowIndex);
    });
  }

  void _addGridColumn(int questionIndex) {
    _markDirty();
    _safeSetState(() {
      _questions[questionIndex].gridColumns.add('');
      _gridColControllers[questionIndex].add(TextEditingController());
    });
  }

  void _removeGridColumn(int questionIndex, int colIndex) {
    if (_questions[questionIndex].gridColumns.length <= 1) return;
    _markDirty();
    _safeSetState(() {
      _questions[questionIndex].gridColumns.removeAt(colIndex);
      _gridColControllers[questionIndex][colIndex].dispose();
      _gridColControllers[questionIndex].removeAt(colIndex);
    });
  }

  void _changeQuestionType(int questionIndex, QuestionType newType) {
    _markDirty();
    _safeSetState(() {
      final oldType = _questions[questionIndex].type;
      _questions[questionIndex].type = newType;

      // Reset isOther when switching to dropdown
      if (newType == QuestionType.dropdown) {
        _questions[questionIndex].isOther = false;
      }

      // Reset options if switching to non-choice types
      if (_isNonOptionType(newType)) {
        _questions[questionIndex].options = [];
        for (var c in _optionControllers[questionIndex]) {
          c.dispose();
        }
        _optionControllers[questionIndex] = [];
      } else {
        // Ensure at least one option for choice types
        if (_questions[questionIndex].options.isEmpty) {
          _questions[questionIndex].options = [''];
          _optionControllers[questionIndex] = [TextEditingController()];
        }
      }

      // Handle grid controllers
      if (_isGridType(newType)) {
        if (!_isGridType(oldType)) {
          // Initialize grid data
          _questions[questionIndex].gridRows = [''];
          _questions[questionIndex].gridColumns = ['', ''];
          // Dispose old grid controllers
          for (var c in _gridRowControllers[questionIndex]) {
            c.dispose();
          }
          for (var c in _gridColControllers[questionIndex]) {
            c.dispose();
          }
          _gridRowControllers[questionIndex] = [TextEditingController()];
          _gridColControllers[questionIndex] = [
            TextEditingController(),
            TextEditingController(),
          ];
        }
      } else {
        // Clear grid controllers if switching away from grid
        for (var c in _gridRowControllers[questionIndex]) {
          c.dispose();
        }
        for (var c in _gridColControllers[questionIndex]) {
          c.dispose();
        }
        _gridRowControllers[questionIndex] = [];
        _gridColControllers[questionIndex] = [];
      }

      // Handle scale controllers
      if (newType == QuestionType.linearScale) {
        _scaleLowLabelControllers[questionIndex]?.dispose();
        _scaleHighLabelControllers[questionIndex]?.dispose();
        _scaleLowLabelControllers[questionIndex] = null;
        _scaleHighLabelControllers[questionIndex] = null;
      }
    });
  }

  PopupMenuItem<QuestionType> _questionTypePopupItem(QuestionType type) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(
            _questionTypeIcon(type),
            size: 20,
            color: const Color(0xFF5F6368),
          ),
          const SizedBox(width: 8),
          Text(_questionTypeLabel(type)),
        ],
      ),
    );
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
      case QuestionType.image:
        return 'Image';
      case QuestionType.video:
        return 'Video';
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
      case QuestionType.info:
        return 'Info';
      case QuestionType.section:
        return 'Section';
    }
  }

  IconData _questionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Icons.radio_button_checked;
      case QuestionType.checkbox:
        return Icons.check_box;
      case QuestionType.shortAnswer:
        return Icons.short_text;
      case QuestionType.paragraph:
        return Icons.notes;
      case QuestionType.dropdown:
        return Icons.arrow_drop_down_circle;
      case QuestionType.image:
        return Icons.image;
      case QuestionType.video:
        return Icons.videocam;
      case QuestionType.linearScale:
        return Icons.linear_scale;
      case QuestionType.multipleChoiceGrid:
        return Icons.grid_on;
      case QuestionType.checkboxGrid:
        return Icons.checklist_rtl;
      case QuestionType.date:
        return Icons.calendar_today;
      case QuestionType.time:
        return Icons.access_time;
      case QuestionType.info:
        return Icons.title;
      case QuestionType.section:
        return Icons.view_week;
    }
  }

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null && mounted) {
      _markDirty();
      _safeSetState(() {
        _questions[index].mediaUrl = pickedFile.path;
      });
    }
  }

  Future<void> _pickEmbeddedImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null && mounted) {
      _markDirty();
      _safeSetState(() {
        _questions[index].embeddedImageUrl = pickedFile.path;
      });
    }
  }

  Widget _buildEmbeddedImagePreview(int index) {
    final url = _questions[index].embeddedImageUrl;
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: url.startsWith('http')
                ? Image.network(
                    url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF673AB7),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, error, _) {
                      return Container(
                        height: 100,
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Color(0xFFBDBDBD), size: 40),
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(url),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, _) {
                      return Container(
                        height: 100,
                        color: const Color(0xFFF5F5F5),
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Color(0xFFBDBDBD), size: 40),
                        ),
                      );
                    },
                  ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () {
                  _markDirty();
                  _safeSetState(() {
                    _questions[index].embeddedImageUrl = null;
                  });
                },
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showVideoUrlDialog(int index) async {
    final controller = _videoUrlControllers[index];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADCE0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Add YouTube video',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Paste YouTube URL here',
                    hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final url = controller.text.trim();
                        Navigator.pop(sheetContext);
                        if (url.isNotEmpty && mounted) {
                          _markDirty();
                          _safeSetState(() {
                            _questions[index].mediaUrl = url;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _syncAllFields() {
    for (int i = 0; i < _questions.length; i++) {
      _questions[i].questionText = _questionControllers[i].text;
      for (int j = 0; j < _optionControllers[i].length; j++) {
        if (j < _questions[i].options.length) {
          _questions[i].options[j] = _optionControllers[i][j].text;
        }
      }
      if (_questions[i].type == QuestionType.video) {
        _questions[i].mediaUrl = _videoUrlControllers[i].text;
      }
      // Sync grid data
      if (_isGridType(_questions[i].type)) {
        for (int j = 0; j < _gridRowControllers[i].length; j++) {
          if (j < _questions[i].gridRows.length) {
            _questions[i].gridRows[j] = _gridRowControllers[i][j].text;
          }
        }
        for (int j = 0; j < _gridColControllers[i].length; j++) {
          if (j < _questions[i].gridColumns.length) {
            _questions[i].gridColumns[j] = _gridColControllers[i][j].text;
          }
        }
      }
      // Sync scale labels
      if (_questions[i].type == QuestionType.linearScale) {
        _questions[i].scaleLowLabel = _scaleLowLabelControllers[i]?.text;
        _questions[i].scaleHighLabel = _scaleHighLabelControllers[i]?.text;
      }
      // Sync section description
      if (_questions[i].type == QuestionType.section) {
        final descCtrl = _sectionDescriptionControllers[i];
        if (descCtrl != null) {
          _questions[i].description = descCtrl.text.isNotEmpty ? descCtrl.text : null;
        }
      }
    }
  }

  Future<void> _saveForm() async {
    if (_isSaving) return;

    _syncAllFields();

    // Check for valid questions
    final validCount = _questions
        .where(
          (q) =>
              q.questionText.trim().isNotEmpty ||
              q.type == QuestionType.image && q.mediaUrl != null ||
              q.type == QuestionType.video &&
                  q.mediaUrl != null &&
                  q.mediaUrl!.isNotEmpty,
        )
        .length;
    if (validCount == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question before saving.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check for duplicate choices in choice-based questions
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (!q.isChoiceType) continue;
      final nonEmpty = q.options.where((o) => o.trim().isNotEmpty).toList();
      final unique = nonEmpty.toSet();
      if (unique.length < nonEmpty.length) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You can't have duplicated choices in a multiple choice question.",
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // Build the updated form model from current editor state
    final updatedForm = FormModel(
      title: _titleController.text.isEmpty
          ? 'Untitled form'
          : _titleController.text,
      description: _descriptionController.text,
      questions: _questions,
      collectEmail: _collectEmail,
      emailCollectionType: _emailCollectionType,
      sendResponseCopy: _sendResponseCopy,
      limitOneResponse: _limitOneResponse,
      editAfterSubmit: _editAfterSubmit,
      showProgressBar: _showProgressBar,
      confirmationMessage: _confirmationMessageController.text,
      shuffleQuestions: _shuffleQuestions,
    );

    // ---- Branch: new form vs. existing form ----
    if (_currentFormId == null || _originalForm == null) {
      // NEW FORM: use the existing createFullForm logic
      await _saveNewForm(updatedForm);
    } else {
      // EXISTING FORM: detect changes using cached original data (no API call)
      final changes = _formsService.detectFormChanges(_originalForm!, updatedForm);

      // If there are breaking changes, show a warning dialog BEFORE the saving overlay
      if (changes.hasBreakingChanges) {
        final shouldContinue = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Save changes?'),
            content: Text(
              'This change will affect existing responses: ${changes.breakingChangesDescription}.\n\n'
              'Do you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'continue'),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Color(0xFF673AB7)),
                ),
              ),
            ],
          ),
        );
        if (shouldContinue != 'continue') return;
      }

      // Show saving overlay IMMEDIATELY — no delay between user action and overlay
      setState(() => _isSaving = true);
      _showSavingOverlay();

      // Now fetch fresh data and perform the update (behind the overlay)
      await _saveExistingForm(updatedForm);
    }
  }

  /// Show the non-dismissible saving overlay.
  void _showSavingOverlay() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF673AB7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Saving...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Save a brand new form using createFullForm.
  Future<void> _saveNewForm(FormModel form) async {
    setState(() => _isSaving = true);
    _showSavingOverlay();

    final result = await _formsService.createFullForm(form);
    final createdForm = result['form'] as FormModel?;
    final error = result['error'] as String?;

    if (!mounted) return;

    if (createdForm != null && error == null) {
      _currentFormId = createdForm.formId;
      final fetchedForm = await _formsService.getForm(createdForm.formId);
      final savedForm = fetchedForm ?? createdForm;
      _originalForm = savedForm;
      if (mounted) {
        _safeSetState(() => _syncQuestionsOrderFromSavedForm(savedForm));
      }
      await _applySettingsAndFinish(
        savedForm.formId,
        savedForm.responderUri ?? createdForm.responderUri,
        null,
      );
    } else if (createdForm != null && error != null) {
      _currentFormId = createdForm.formId;
      _originalForm = createdForm;
      if (mounted) {
        Navigator.of(context).pop(); // Close saving overlay
        _safeSetState(() {
          _isSaving = false;
          _isDirty = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(error)),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Done',
              textColor: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop(); // Close saving overlay
        _safeSetState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(error ?? 'Failed to save form.')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Save changes to an existing form using in-place update (batchUpdate).
  /// Called AFTER the saving overlay is already shown.
  Future<void> _saveExistingForm(FormModel updatedForm) async {
    // Fetch the latest original form from the API to get accurate itemIds
    // (this runs behind the saving overlay, so no visible delay)
    final freshOriginal = await _formsService.getForm(_currentFormId!);
    if (freshOriginal == null) {
      if (mounted) {
        Navigator.of(context).pop(); // Close saving overlay
        _safeSetState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load current form data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    _originalForm = freshOriginal;

    final result = await _formsService.updateExistingForm(
      _currentFormId!,
      _originalForm!,
      updatedForm,
    );
    final savedForm = result['form'] as FormModel?;
    final error = result['error'] as String?;

    if (!mounted) return;

    if (savedForm != null) {
      _originalForm = savedForm;
      _safeSetState(() => _syncQuestionsOrderFromSavedForm(savedForm));
      await _applySettingsAndFinish(
        _currentFormId!,
        savedForm.responderUri ?? _responderUri,
        error, // non-fatal errors (e.g. rename failed)
      );
    } else {
      if (mounted) {
        Navigator.of(context).pop(); // Close saving overlay
        _safeSetState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(error ?? 'Failed to update form.')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Apply form settings (email, Apps Script) and finish the save flow.
  Future<void> _applySettingsAndFinish(
      String formId, String? responderUri, String? nonFatalError) async {
    String? settingsError;

    // Email collection type - use REST API
    if (_emailCollectionType != 'none') {
      final emailErr = await _formsService.updateEmailCollectionType(
        formId,
        _emailCollectionType,
      );
      if (!mounted) return;
      if (emailErr != null) {
        debugPrint('Email collection error: $emailErr');
        settingsError = 'Email collection: $emailErr';
      }
    }

    // Other settings via Apps Script if configured
    if (_appsScriptService.isConfigured && formId.isNotEmpty) {
      final settingsResult = await _appsScriptService
          .applyFormSettings(formId, {
            'acceptingResponses': _isAcceptingResponses,
            'limitOneResponse': _limitOneResponse,
            'editAfterSubmit': _editAfterSubmit,
            'showProgressBar': _showProgressBar,
            'shuffleQuestions': _shuffleQuestions,
            'confirmationMessage': _confirmationMessageController.text,
            'sendResponseCopy': _sendResponseCopy,
          });
      if (!mounted) return;
      if (!(settingsResult['success'] as bool? ?? false)) {
        settingsError = settingsResult['error'] as String?;
      }
    }

    if (responderUri != null && responderUri.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: responderUri));
      if (mounted) {
        Navigator.of(context).pop(); // Close saving overlay
        _safeSetState(() {
          _isSaving = false;
          _isDirty = false;
          _responderUri = responderUri;
          _webViewController = null;
        });
        // Build the appropriate success/warning message
        final List<String> warnings = [];
        if (nonFatalError != null) {
          warnings.add(nonFatalError);
        }
        if (settingsError != null) {
          warnings.add('Settings: $settingsError');
        }

        final snackBarMsg = warnings.isEmpty
            ? 'Form saved! Link copied to clipboard.'
            : 'Form saved! Link copied. ${warnings.join(' ')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackBarMsg),
            backgroundColor: warnings.isNotEmpty
                ? Colors.orange
                : Colors.green,
            duration: Duration(seconds: warnings.isNotEmpty ? 5 : 2),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop(); // Close saving overlay
        _safeSetState(() {
          _isSaving = false;
          _isDirty = false;
        });
        final List<String> warnings = [];
        if (nonFatalError != null) {
          warnings.add(nonFatalError);
        }
        if (settingsError != null) {
          warnings.add('Settings: $settingsError');
        }
        if (warnings.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(warnings.join(' ')),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  String _friendlyError(String error) {
    if (error.contains('duplicate values')) {
      return "You can't have duplicated choices in a multiple choice question.";
    }
    if (error.contains('INVALID_ARGUMENT')) {
      return 'Invalid data. Please check your form and try again.';
    }
    if (error.contains('PERMISSION_DENIED')) {
      return 'Permission denied. Please check your Google account access.';
    }
    return error.length > 100 ? '${error.substring(0, 100)}...' : error;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0EBF4),
        appBar: AppBar(
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBackPress,
        ),
        title: Text(
          _titleController.text.isEmpty
              ? 'Untitled form'
              : _titleController.text,
          style: TextStyle(
            color: _titleController.text.isEmpty
                ? Colors.white70
                : Colors.white,
            fontSize: 18,
            fontStyle: _titleController.text.isEmpty
                ? FontStyle.italic
                : FontStyle.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Copy link button
          IconButton(
            onPressed: () {
              if (_responderUri != null && _responderUri!.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: _responderUri!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copied to clipboard'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Save the form first to get a link'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.link, color: Colors.white, size: 20),
            tooltip: 'Copy Link',
          ),
          // Publish button
          IconButton(
            onPressed: _isPublishing ? null : _togglePublish,
            icon: _isPublishing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : _isPublished
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.send, color: Colors.white, size: 16),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF673AB7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green[300],
                                  size: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Icon(Icons.send_outlined, color: Colors.white, size: 20),
            tooltip: _isPublished ? 'Published' : 'Publish',
          ),
          // Save button
          IconButton(
            onPressed: _isSaving ? null : _saveForm,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white, size: 20),
            tooltip: 'Save',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF673AB7),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              tabs: const [
                Tab(text: 'Edit'),
                Tab(text: 'Preview'),
                Tab(text: 'Responses'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildEditTabSkeleton()
          : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEditTab(),
                _buildPreviewTab(),
                _buildResponseTab(),
                _buildSettingsTab(),
              ],
            ),
      bottomNavigationBar: _isLoading
          ? null
          : _tabController.index == 2 && _currentFormId != null
          ? _buildResponseBottomBar()
          : _tabController.index == 3
          ? null
          : _tabController.index != 0
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _showAddQuestionDialog,
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF673AB7),
                        size: 28,
                      ),
                      tooltip: 'Add question',
                    ),
                    IconButton(
                      onPressed: () => _addQuestion(QuestionType.image),
                      icon: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF5F6368),
                        size: 28,
                      ),
                      tooltip: 'Add image',
                    ),
                    IconButton(
                      onPressed: () => _addQuestion(QuestionType.video),
                      icon: const Icon(
                        Icons.videocam_outlined,
                        color: Color(0xFF5F6368),
                        size: 28,
                      ),
                      tooltip: 'Add video',
                    ),
                    IconButton(
                      onPressed: () => _addQuestion(QuestionType.info),
                      icon: const Icon(
                        Icons.title,
                        color: Color(0xFF5F6368),
                        size: 28,
                      ),
                      tooltip: 'Add info',
                    ),
                    IconButton(
                      onPressed: () => _addQuestion(QuestionType.section),
                      icon: const Icon(
                        Icons.view_week_outlined,
                        color: Color(0xFF5F6368),
                        size: 28,
                      ),
                      tooltip: 'Add section',
                    ),
                  ],
                ),
              ),
            ),
    ),
    );
  }

  // ==================== EDIT TAB ====================
  Widget _buildEditTab() {
    final roboTheme = Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Roboto'),
    );
    return Theme(
      data: roboTheme,
      child: DefaultTextStyle(
        style: TextStyle(fontFamily: 'Roboto', color: Color(0xFF202124)),
        child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildFormInfoCard(),
                  ),
                ),
                SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverReorderableList(
                itemCount: _questions.length,
                autoScrollerVelocityScalar: 50,
                onReorderStart: _onReorderDragStart,
                onReorderEnd: (_) => _onReorderDragEnd(),
                onReorderItem: (oldIndex, newIndex) {
                  if (oldIndex >= _questions.length) return;
                  final clampedNew =
                      newIndex.clamp(0, _questions.length - 1);
                  _reorderQuestions(oldIndex, clampedNew);
                },
                proxyDecorator: (child, index, animation) {
                  if (index >= _questions.length) return child;
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final t = Curves.easeInOut.transform(animation.value);
                      return Material(
                        elevation: 6.0 * t,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF673AB7).withValues(alpha: 0.3 * t),
                              width: 1,
                            ),
                          ),
                          child: _buildReorderCollapsedCard(index),
                        ),
                      );
                    },
                  );
                },
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final isSection = question.type == QuestionType.section;

                  // Section items are not reorderable
                  if (isSection) {
                    return Padding(
                      key: _questionKeys.length > index ? _questionKeys[index] : ValueKey('section_$index'),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSectionCard(index),
                    );
                  }

                  // Regular question cards with drag handle
                  return Padding(
                    key: _questionKeys.length > index ? _questionKeys[index] : ValueKey('question_$index'),
                    padding: const EdgeInsets.only(bottom: _kReorderItemBottomPadding),
                    child: _collapsedForReorderIndex == index
                        ? _buildReorderCollapsedCard(index)
                        : _buildQuestionCard(index),
                  );
                },
              ),
            ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _showAddQuestionDialog,
                        icon: const Icon(Icons.add, color: Color(0xFF673AB7)),
                        label: const Text(
                          'Add question',
                          style: TextStyle(
                            color: Color(0xFF673AB7),
                            fontWeight: FontWeight.w500,
                          ),
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

  // ==================== PREVIEW TAB ====================
  Widget _buildPreviewTab() {
    if (_responderUri == null || _responderUri!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.preview_outlined,
                size: 64,
                color: Color(0xFFDADCE0),
              ),
              const SizedBox(height: 16),
              const Text(
                'No preview available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Save your form first to see a live preview of how it looks to respondents.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF80868B)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveForm,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, size: 20),
                label: Text(_isSaving ? 'Saving...' : 'Save to preview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    _webViewController ??= WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_responderUri!));

    return WebViewWidget(controller: _webViewController!);
  }

  Widget _buildFormInfoCard() {
    final sectionCount = _getSectionCount();
    final showSectionLabel = sectionCount > 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          if (showSectionLabel)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Section 1 of $sectionCount',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5F6368),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Form title',
              hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Color(0xFF202124),
            ),
            onChanged: (_) => _markDirty(),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Form description',
              hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
            style: const TextStyle(fontSize: 16, color: Color(0xFF5F6368)),
            maxLines: null,
            onChanged: (_) => _markDirty(),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION CARD ====================
  Widget _buildSectionCard(int index) {
    final question = _questions[index];
    final (sectionNum, totalSections) = _getSectionInfo(index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDADCE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with section label and arrow icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.view_week,
                  color: const Color(0xFF673AB7),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Section $sectionNum of $totalSections',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF673AB7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _questionControllers[index],
              decoration: const InputDecoration(
                hintText: 'Section title',
                hintStyle: TextStyle(color: Color(0xFF202124)),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDADCE0)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF673AB7), width: 2),
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF202124),
              ),
              onChanged: (_) {
                _markDirty();
              },
            ),
          ),
          // Section description
          if (question.showDescription)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextField(
                controller: _sectionDescriptionControllers.putIfAbsent(
                  index,
                  () => TextEditingController(text: question.description ?? ''),
                ),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5F6368),
                ),
                maxLines: null,
                onChanged: (val) {
                  _markDirty();
                  _questions[index].description = val.isNotEmpty ? val : null;
                },
              ),
            ),
          // Bottom action bar
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.content_copy,
                    size: 20,
                    color: Color(0xFF5F6368),
                  ),
                  onPressed: () => _duplicateQuestion(index),
                  tooltip: 'Duplicate',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFF5F6368),
                  ),
                  onPressed: () => _removeQuestion(index),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Color(0xFF5F6368),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'More options',
                  onSelected: (value) {
                    if (value == 'showDescription') {
                      _markDirty();
                      _safeSetState(() {
                        _questions[index].showDescription =
                            !_questions[index].showDescription;
                      });
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 'showDescription',
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: _questions[index].showDescription,
                                onChanged: null,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Show description',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QUESTION CARD ====================
  Widget _buildQuestionCard(int index) {
    final question = _questions[index];

    // Section type has its own dedicated UI
    if (question.type == QuestionType.section) {
      return _buildSectionCard(index);
    }

    final isChoiceType = question.isChoiceType;
    final isImageType = question.type == QuestionType.image;
    final isVideoType = question.type == QuestionType.video;
    final isLinearScale = question.type == QuestionType.linearScale;
    final isGridType = _isGridType(question.type);
    final isDate = question.type == QuestionType.date;
    final isTime = question.type == QuestionType.time;
    final isInfoType = question.type == QuestionType.info;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDADCE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
            ),
            child: Row(
              children: [
                _buildDragHandle(index),
                const SizedBox(width: 4),
                Expanded(
                  child: PopupMenuButton<QuestionType>(
                    onSelected: (type) => _changeQuestionType(index, type),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _questionTypeIcon(question.type),
                          color: const Color(0xFF673AB7),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _questionTypeLabel(question.type),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF673AB7),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF673AB7),
                          size: 20,
                        ),
                      ],
                    ),
                    itemBuilder: (context) => [
                      // Group 1: Text
                      _questionTypePopupItem(QuestionType.shortAnswer),
                      _questionTypePopupItem(QuestionType.paragraph),
                      const PopupMenuDivider(height: 1),
                      // Group 2: Choice
                      _questionTypePopupItem(QuestionType.multipleChoice),
                      _questionTypePopupItem(QuestionType.checkbox),
                      _questionTypePopupItem(QuestionType.dropdown),
                      const PopupMenuDivider(height: 1),
                      // Group 3: Scale & Grid
                      _questionTypePopupItem(QuestionType.linearScale),
                      _questionTypePopupItem(QuestionType.multipleChoiceGrid),
                      _questionTypePopupItem(QuestionType.checkboxGrid),
                      const PopupMenuDivider(height: 1),
                      // Group 4: Date & Time
                      _questionTypePopupItem(QuestionType.date),
                      _questionTypePopupItem(QuestionType.time),
                    ],
                   ),
                 ),
                if (!isImageType && !isVideoType && !isInfoType)
                  IconButton(
                    icon: Icon(
                      _questions[index].embeddedImageUrl != null &&
                              _questions[index].embeddedImageUrl!.isNotEmpty
                          ? Icons.image
                          : Icons.add_photo_alternate_outlined,
                      size: 20,
                      color: _questions[index].embeddedImageUrl != null &&
                              _questions[index].embeddedImageUrl!.isNotEmpty
                          ? const Color(0xFF673AB7)
                          : const Color(0xFF5F6368),
                    ),
                    onPressed: () => _pickEmbeddedImage(index),
                    tooltip: 'Add image to question',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
               ],
             ),
           ),

          // Embedded image preview (for non-image/video questions)
          if (!isImageType && !isVideoType && !isInfoType && _questions[index].embeddedImageUrl != null && _questions[index].embeddedImageUrl!.isNotEmpty)
            _buildEmbeddedImagePreview(index),

          // Question text field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _questionControllers[index],
              decoration: InputDecoration(
                hintText: isImageType
                    ? 'Image title (optional)'
                    : isVideoType
                    ? 'Video title'
                    : 'Question',
                hintStyle: const TextStyle(color: Color(0xFF202124)),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDADCE0)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF673AB7), width: 2),
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF202124),
              ),
              onChanged: (val) {
                _markDirty();
                _questions[index].questionText = val;
              },
            ),
          ),

          // Description field (for Date/Time questions when showDescription is true, and always for Info type)
          if ((isDate || isTime) && _questions[index].showDescription)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: TextEditingController(
                  text: _questions[index].description ?? '',
                ),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDADCE0)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF673AB7), width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5F6368),
                ),
                onChanged: (val) {
                  _markDirty();
                  _questions[index].description = val;
                },
              ),
            ),

          // Info description field (shown when showDescription is enabled for Info type)
          if (isInfoType && _questions[index].showDescription)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextField(
                controller: TextEditingController(
                  text: _questions[index].description ?? '',
                ),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5F6368),
                ),
                maxLines: null,
                onChanged: (val) {
                  _markDirty();
                  _questions[index].description = val;
                },
              ),
            ),

          // Description field for all other question types
          if (!isInfoType && !isDate && !isTime && _questions[index].showDescription)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: TextEditingController(
                  text: _questions[index].description ?? '',
                ),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDADCE0)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF673AB7), width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5F6368),
                ),
                onChanged: (val) {
                  _markDirty();
                  _questions[index].description = val;
                },
              ),
            ),

          // Image content
          if (isImageType) _buildImageContent(index),

          // Video content
          if (isVideoType) _buildVideoContent(index),

          // Options (for choice-based questions)
          if (isChoiceType) _buildChoiceOptions(index),

          // Text answer preview
          if (question.type == QuestionType.shortAnswer)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Short answer text',
                style: TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          if (question.type == QuestionType.paragraph)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Long answer text',
                style: TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Linear Scale content
          if (isLinearScale) _buildLinearScaleContent(index),

          // Grid content
          if (isGridType) _buildGridContent(index),

          // Date content
          if (isDate) _buildDateContent(index),

          // Time content
          if (isTime) _buildTimeContent(index),

          // Bottom action bar
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Required toggle (not shown for Info type)
                if (!isInfoType && !isImageType && !isVideoType)
                  Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 13,
                      color: _questions[index].isRequired
                          ? const Color(0xFF202124)
                          : const Color(0xFF9E9E9E),
                      fontWeight: _questions[index].isRequired
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                if (!isInfoType && !isImageType && !isVideoType) const SizedBox(width: 4),
                if (!isInfoType && !isImageType && !isVideoType)
                  Switch(
                    value: _questions[index].isRequired,
                    onChanged: (val) {
                      _markDirty();
                      _safeSetState(() {
                        _questions[index].isRequired = val;
                      });
                    },
                    activeThumbColor: const Color(0xFF673AB7),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (!isInfoType && !isImageType && !isVideoType) const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.content_copy,
                    size: 20,
                    color: Color(0xFF5F6368),
                  ),
                  onPressed: () => _duplicateQuestion(index),
                  tooltip: 'Duplicate',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFF5F6368),
                  ),
                  onPressed: () => _removeQuestion(index),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                // "3 dots" overflow menu for all question types
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Color(0xFF5F6368),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'More options',
                  onSelected: (value) {
                    _markDirty();
                    _safeSetState(() {
                      if (value == 'includeYear') {
                        _questions[index].dateIncludeYear =
                            !_questions[index].dateIncludeYear;
                      } else if (value == 'duration') {
                        _questions[index].timeDuration =
                            !_questions[index].timeDuration;
                      } else if (value == 'showDescription') {
                        _questions[index].showDescription =
                            !_questions[index].showDescription;
                      }
                    });
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[];
                    if (isInfoType) {
                      items.add(
                        PopupMenuItem(
                          value: 'showDescription',
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _questions[index].showDescription,
                                  onChanged: null,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Show description',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (isDate) {
                      items.add(
                        PopupMenuItem(
                          value: 'includeYear',
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _questions[index].dateIncludeYear,
                                  onChanged: null,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Include year',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (isTime) {
                      items.add(
                        PopupMenuItem(
                          value: 'duration',
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _questions[index].timeDuration,
                                  onChanged: null,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Duration',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (isDate || isTime) {
                      items.add(
                        PopupMenuItem(
                          value: 'showDescription',
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _questions[index].showDescription,
                                  onChanged: null,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Show description',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    // For all other question types (MC, Checkbox, Dropdown, Short Answer, Paragraph, Linear Scale, Grid types, Image, Video)
                    if (!isInfoType && !isDate && !isTime) {
                      items.add(
                        PopupMenuItem(
                          value: 'showDescription',
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _questions[index].showDescription,
                                  onChanged: null,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Show description',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return items;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CHOICE OPTIONS ====================
  Widget _buildChoiceOptions(int index) {
    final question = _questions[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          ...List.generate(_optionControllers[index].length, (optIdx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (question.type == QuestionType.multipleChoice)
                    const Icon(
                      Icons.radio_button_unchecked,
                      color: Color(0xFF9E9E9E),
                      size: 20,
                    )
                  else if (question.type == QuestionType.checkbox)
                    const Icon(
                      Icons.check_box_outline_blank,
                      color: Color(0xFF9E9E9E),
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF9E9E9E),
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _optionControllers[index][optIdx],
                      decoration: InputDecoration(
                        hintText: 'Option ${optIdx + 1}',
                        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (val) {
                        _markDirty();
                        _questions[index].options[optIdx] = val;
                      },
                    ),
                  ),
                  if (_optionControllers[index].length > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF9E9E9E),
                      ),
                      onPressed: () => _removeOption(index, optIdx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            );
          }),
          InkWell(
            onTap: () => _addOption(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  if (question.type == QuestionType.multipleChoice)
                    const Icon(
                      Icons.radio_button_unchecked,
                      color: Color(0xFFBDBDBD),
                      size: 20,
                    )
                  else if (question.type == QuestionType.checkbox)
                    const Icon(
                      Icons.check_box_outline_blank,
                      color: Color(0xFFBDBDBD),
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFFBDBDBD),
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    'Add option',
                    style: TextStyle(
                      color: const Color(0xFF673AB7).withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // "Other" option toggle (only for multiple choice and checkbox, NOT dropdown)
          if (question.type != QuestionType.dropdown)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Other',
                    style: TextStyle(
                      fontSize: 13,
                      color: _questions[index].isOther
                          ? const Color(0xFF202124)
                          : const Color(0xFF9E9E9E),
                      fontWeight: _questions[index].isOther
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: _questions[index].isOther,
                    onChanged: (val) {
                      _markDirty();
                      _safeSetState(() {
                        _questions[index].isOther = val;
                      });
                    },
                    activeThumbColor: const Color(0xFF673AB7),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==================== LINEAR SCALE CONTENT ====================
  Widget _buildLinearScaleContent(int index) {
    final q = _questions[index];
    final low = q.scaleLow;
    final high = q.scaleHigh;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scale range configuration
          Row(
            children: [
              const Text(
                'Min value',
                style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 56,
                child: DropdownButton<int>(
                  value: low.clamp(0, high - 1),
                  items: List.generate(
                    high,
                    (i) => DropdownMenuItem(value: i, child: Text('$i')),
                  ),
                  onChanged: (val) {
                    if (val != null && val < high) {
                      _markDirty();
                      _safeSetState(() {
                        _questions[index].scaleLow = val;
                      });
                    }
                  },
                  isDense: true,
                  underline: Container(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF202124),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              const Text(
                'Max value',
                style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 56,
                child: DropdownButton<int>(
                  value: high.clamp(low + 1, 10),
                  items: List.generate(
                    10 - low,
                    (i) => DropdownMenuItem(
                      value: low + 1 + i,
                      child: Text('${low + 1 + i}'),
                    ),
                  ),
                  onChanged: (val) {
                    if (val != null && val > low) {
                      _markDirty();
                      _safeSetState(() {
                        _questions[index].scaleHigh = val;
                      });
                    }
                  },
                  isDense: true,
                  underline: Container(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF202124),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scale preview (Google Forms style row of radio buttons)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Low label
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Icon(
                        Icons.radio_button_unchecked,
                        size: 20,
                        color: const Color(0xFF673AB7).withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          '$low',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Intermediate values
                ...List.generate(high - low - 1, (i) {
                  final val = low + 1 + i;
                  return SizedBox(
                    width: 48,
                    child: Column(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          size: 20,
                          color: const Color(0xFF673AB7).withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 2),
                        Center(
                          child: Text(
                            '$val',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5F6368),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // High label
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Icon(
                        Icons.radio_button_unchecked,
                        size: 20,
                        color: const Color(0xFF673AB7).withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          '$high',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Label text fields
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _scaleLowLabelControllers[index],
                  decoration: InputDecoration(
                    hintText: 'Label (optional)',
                    hintStyle: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 12,
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFDADCE0)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF673AB7),
                        width: 2,
                      ),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (val) {
                    _markDirty();
                    _questions[index].scaleLowLabel = val.isEmpty ? null : val;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _scaleHighLabelControllers[index],
                  decoration: InputDecoration(
                    hintText: 'Label (optional)',
                    hintStyle: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 12,
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFDADCE0)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF673AB7),
                        width: 2,
                      ),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (val) {
                    _markDirty();
                    _questions[index].scaleHighLabel = val.isEmpty ? null : val;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== GRID CONTENT ====================
  Widget _buildGridContent(int index) {
    final q = _questions[index];
    final isCheckboxGrid = q.type == QuestionType.checkboxGrid;
    final rowIcon = isCheckboxGrid
        ? Icons.check_box_outline_blank
        : Icons.radio_button_unchecked;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columns section
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 4),
            child: Text(
              'Columns',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5F6368),
              ),
            ),
          ),
          ...List.generate(_gridColControllers[index].length, (colIdx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFBDBDBD),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _gridColControllers[index][colIdx],
                      decoration: InputDecoration(
                        hintText: 'Column ${colIdx + 1}',
                        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (val) {
                        _markDirty();
                        _questions[index].gridColumns[colIdx] = val;
                      },
                    ),
                  ),
                  if (_gridColControllers[index].length > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF9E9E9E),
                      ),
                      onPressed: () => _removeGridColumn(index, colIdx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: InkWell(
              onTap: () => _addGridColumn(index),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Color(0xFF673AB7), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Add column',
                    style: TextStyle(
                      color: const Color(0xFF673AB7).withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, indent: 8, endIndent: 8),

          // Rows section
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 0, 4),
            child: Text(
              'Rows',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5F6368),
              ),
            ),
          ),
          ...List.generate(_gridRowControllers[index].length, (rowIdx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
              child: Row(
                children: [
                  Icon(rowIcon, color: const Color(0xFFBDBDBD), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _gridRowControllers[index][rowIdx],
                      decoration: InputDecoration(
                        hintText: 'Row ${rowIdx + 1}',
                        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (val) {
                        _markDirty();
                        _questions[index].gridRows[rowIdx] = val;
                      },
                    ),
                  ),
                  if (_gridRowControllers[index].length > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF9E9E9E),
                      ),
                      onPressed: () => _removeGridRow(index, rowIdx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () => _addGridRow(index),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Color(0xFF673AB7), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Add row',
                    style: TextStyle(
                      color: const Color(0xFF673AB7).withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DATE CONTENT ====================
  Widget _buildDateContent(int index) {
    final q = _questions[index];
    // Build the date format string based on options
    String dateFormat;
    if (q.dateIncludeYear) {
      dateFormat = 'MM/DD/YYYY';
    } else {
      dateFormat = 'MM/DD';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date preview (Google Forms style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDADCE0)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF9E9E9E),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  dateFormat,
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TIME CONTENT ====================
  Widget _buildTimeContent(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDADCE0)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF9E9E9E),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  _questions[index].timeDuration ? 'HH:MM:SS' : 'HH:MM',
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== IMAGE CONTENT ====================
  Widget _buildImageContent(int index) {
    final mediaUrl = _questions[index].mediaUrl;
    final hasImage = mediaUrl != null && mediaUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: GestureDetector(
        onTap: hasImage ? null : () => _pickImage(index),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Stack(
                  children: [
                    // Display image from file or network
                    mediaUrl.startsWith('http')
                        ? Image.network(
                            mediaUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 140,
                                color: const Color(0xFFF5F5F5),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF673AB7),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (ctx, error, _) {
                              return Container(
                                height: 140,
                                color: const Color(0xFFF5F5F5),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Color(0xFFBDBDBD),
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          )
                        : Image.file(
                            File(mediaUrl),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, _) {
                              return Container(
                                height: 140,
                                color: const Color(0xFFF5F5F5),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Color(0xFFBDBDBD),
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),
                    // Delete image button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            _markDirty();
                            _safeSetState(() {
                              _questions[index].mediaUrl = null;
                            });
                          },
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click to upload image',
                      style: TextStyle(
                        color: const Color(0xFF9E9E9E).withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Extract YouTube video ID from various URL formats
  String? _extractYouTubeVideoId(String? url) {
    if (url == null || url.isEmpty) return null;
    var match = RegExp(r'v=([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (match != null) return match.group(1);
    match = RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (match != null) return match.group(1);
    match = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (match != null) return match.group(1);
    return null;
  }

  Future<void> _openYouTubeVideo(String url) async {
    String normalizedUrl = url;
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch YouTube URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open YouTube.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ==================== RESPONSE TAB ====================
  Future<void> _loadResponsesForTab() async {
    if (_currentFormId == null || _isLoadingResponses) return;
    setState(() => _isLoadingResponses = true);

    FormModel? latestForm;
    if (!_isDirty) {
      latestForm = await _formsService.getForm(_currentFormId!);
    }

    final responses = await _formsService.listResponses(_currentFormId!);
    if (mounted) {
      _safeSetState(() {
        if (latestForm != null) {
          _syncQuestionsOrderFromSavedForm(latestForm);
          _originalForm = latestForm;
        }
        _responses = responses;
        _isLoadingResponses = false;
        _hasLoadedResponses = true;
        // Clamp selection indices so they stay within bounds
        if (_selectedIndividualIndex >= _responses.length) {
          _selectedIndividualIndex =
              _responses.isEmpty ? 0 : _responses.length - 1;
        }
        final answerable = _answerableQuestionIndices();
        if (_selectedQuestionIndex >= answerable.length) {
          _selectedQuestionIndex =
              answerable.isEmpty ? 0 : answerable.length - 1;
        }
      });
    }
  }

  Future<void> _loadResponses() async => _loadResponsesForTab();

  Widget _buildResponseTab() {
    if (_currentFormId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.save_outlined,
                size: 64,
                color: Color(0xFFDADCE0),
              ),
              const SizedBox(height: 16),
              const Text(
                'Save your form first',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You need to save your form before you can view responses.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF80868B)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveForm,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, size: 20),
                label: Text(_isSaving ? 'Saving...' : 'Save form'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show skeleton until responses have been loaded at least once.
    // This prevents flashing "No responses yet" before the API call starts.
    if (!_hasLoadedResponses) {
      return Column(
        children: [
          _buildExportButtonBar(),
          Expanded(child: _buildResponseLoadingSkeleton()),
        ],
      );
    }

    // PageView for clean horizontal swipe between sub-tabs
    // When no responses, all three pages show the same empty state
    // Use different keys to force full rebuild when transitioning between
    // empty and non-empty states, so Flutter never reuses the wrong PageView.
    final pageView = _responses.isEmpty
        ? PageView(
            key: ValueKey('responses_empty_$_responseOrderEpoch'),
            controller: _responseSubTabController,
            onPageChanged: (index) {
              _safeSetState(() {
                _responseSubTab = index;
              });
            },
            children: [
              _buildEmptyResponsesView(),
              _buildEmptyResponsesView(),
              _buildEmptyResponsesView(),
            ],
          )
        : PageView(
            key: ValueKey('responses_data_$_responseOrderEpoch'),
            controller: _responseSubTabController,
            onPageChanged: (index) {
              _safeSetState(() {
                _responseSubTab = index;
              });
            },
            children: [
              _buildSummaryView(),
              _buildQuestionView(),
              _buildIndividualView(),
            ],
          );

    return Column(
      children: [
        _buildExportButtonBar(),
        Expanded(
          child: Stack(
            children: [
              if (_isLoadingResponses)
                _buildResponseLoadingSkeleton()
              else
                pageView,
              _buildRefreshFAB(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportButtonBar() {
    final bool hasResponses = _responses.isNotEmpty && _currentFormId != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _buildExportIconButton(
            icon: Icons.table_chart_outlined,
            label: 'XLSX',
            tooltip: 'Export as .xlsx',
            onPressed: hasResponses ? () => _showExportDialog('xlsx') : null,
          ),
          const SizedBox(width: 8),
          _buildExportIconButton(
            icon: Icons.grid_on_outlined,
            label: 'CSV',
            tooltip: 'Export as .csv',
            onPressed: hasResponses ? () => _showExportDialog('csv') : null,
          ),
          const SizedBox(width: 8),
          _buildExportIconButton(
            icon: _linkedSheetId != null
                ? Icons.table_chart
                : Icons.add_chart_outlined,
            label: 'Sheets',
            tooltip: _linkedSheetId != null
                ? 'Open linked Google Sheet'
                : 'Link to Google Sheet',
            onPressed: _currentFormId != null ? _linkToGoogleSheet : null,
            color: _linkedSheetId != null ? const Color(0xFF0F9D58) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildExportIconButton({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    final effectiveColor = color ?? const Color(0xFF673AB7);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: onPressed != null
            ? effectiveColor.withValues(alpha: 0.08)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: onPressed != null
                      ? effectiveColor
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onPressed != null
                        ? effectiveColor
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExportDialog(String format) {
    final TextEditingController fileNameController = TextEditingController(
      text: _titleController.text.trim().isEmpty
          ? 'responses'
          : _titleController.text.trim(),
    );

    showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                format == 'xlsx'
                    ? Icons.table_chart_outlined
                    : Icons.grid_on_outlined,
                color: const Color(0xFF673AB7),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Export as ${format.toUpperCase()}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter a file name for the export:',
                style: TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fileNameController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'File name',
                  suffixText: '.$format',
                  suffixStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF673AB7),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF5F6368)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final name = fileNameController.text.trim().isEmpty
                    ? 'responses'
                    : fileNameController.text.trim();
                Navigator.of(dialogContext).pop(name);
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    ).then((fileName) {
      if (fileName != null && mounted) {
        if (format == 'xlsx') {
          _exportToXlsx(fileName);
        } else {
          _exportToCsv(fileName);
        }
      }
    });
  }

  List<String> _buildExportHeaders() {
    final headers = <String>['Response ID', 'Create Time', 'Last Submitted Time'];
    for (final i in _answerableQuestionIndices()) {
      final q = _questions[i];
      if ((q.type == QuestionType.multipleChoiceGrid ||
              q.type == QuestionType.checkboxGrid) &&
          q.gridRowQuestionIds.isNotEmpty) {
        for (int r = 0; r < q.gridRows.length; r++) {
          if (q.gridRows[r].isNotEmpty) {
            headers.add('${q.questionText} [${q.gridRows[r]}]');
          }
        }
      } else {
        headers.add(q.questionText.isNotEmpty ? q.questionText : 'Untitled');
      }
    }
    return headers;
  }

  /// Clean an answer value for export: returns empty string if the value
  /// looks like an unanswered question's raw timestamp fragment.
  String _cleanExportAnswer(String value) {
    if (value.isEmpty) return '';
    // Google Forms sometimes returns a bare ISO-8601 time fragment like
    // "T08:10:40.927183Z" for unanswered date/time questions.
    if (RegExp(r'^T\d{2}:\d{2}:\d{2}').hasMatch(value)) return '';
    return value;
  }

  List<List<String>> _buildExportRows() {
    final rows = <List<String>>[];
    for (final response in _responses) {
      final row = <String>[
        response.responseId,
        response.createTime,
        response.lastSubmittedTime,
      ];
      for (final i in _answerableQuestionIndices()) {
        final q = _questions[i];
        if ((q.type == QuestionType.multipleChoiceGrid ||
                q.type == QuestionType.checkboxGrid) &&
            q.gridRowQuestionIds.isNotEmpty) {
          for (int r = 0; r < q.gridRowQuestionIds.length; r++) {
            if (r < q.gridRows.length && q.gridRows[r].isNotEmpty) {
              final rowQId = q.gridRowQuestionIds[r];
              row.add(_cleanExportAnswer(response.getAnswerForQuestion(rowQId)));
            }
          }
        } else {
          row.add(_cleanExportAnswer(response.getAnswerForQuestion(q.itemId)));
        }
      }
      rows.add(row);
    }
    return rows;
  }

  Future<void> _exportToXlsx(String fileName) async {
    String? filePath;

    try {
      final excel = excel_lib.Excel.createExcel();
      final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
      excel.rename(sheetName, 'Responses');
      final sheet = excel['Responses'];

      final headers = _buildExportHeaders();
      final rows = _buildExportRows();

      // Write headers
      for (int c = 0; c < headers.length; c++) {
        final cell = sheet.cell(
          excel_lib.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0),
        );
        cell.value = excel_lib.TextCellValue(headers[c]);
      }

      // Write data rows
      for (int r = 0; r < rows.length; r++) {
        for (int c = 0; c < rows[r].length; c++) {
          final cell = sheet.cell(
            excel_lib.CellIndex.indexByColumnRow(
              columnIndex: c,
              rowIndex: r + 1,
            ),
          );
          cell.value = excel_lib.TextCellValue(rows[r][c]);
        }
      }

      final dir = await getTemporaryDirectory();
      filePath = '${dir.path}/$fileName.xlsx';
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
      } else {
        filePath = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (filePath != null && mounted) {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: '$fileName.xlsx',
      );
    }
  }

  Future<void> _exportToCsv(String fileName) async {
    final headers = _buildExportHeaders();
    final rows = _buildExportRows();

    final buffer = StringBuffer();

    // Header row
    buffer.writeln(headers.map(_csvEscape).join(','));
    // Data rows
    for (final row in rows) {
      buffer.writeln(row.map(_csvEscape).join(','));
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName.csv';
    try {
      final file = File(filePath);
      final utf8Bom = utf8.encode('\ufeff');
      final csvBytes = utf8.encode(buffer.toString());
      await file.writeAsBytes([...utf8Bom, ...csvBytes]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (mounted) {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: '$fileName.csv',
      );
    }
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  void _linkToGoogleSheet() {
    if (_currentFormId == null) return;

    if (_linkedSheetId != null) {
      // Already linked — show the linked sheet info dialog
      _showLinkedSheetDialog();
    } else {
      // Not linked — show dialog to create a new spreadsheet and link
      _showLinkNewSheetDialog();
    }
  }

  /// Show dialog when form is already linked to a spreadsheet.
  void _showLinkedSheetDialog() {
    final sheetUrl =
        'https://docs.google.com/spreadsheets/d/$_linkedSheetId/edit';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(
                Icons.link,
                color: Color(0xFF0F9D58),
                size: 24,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Linked to Sheet',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Responses are automatically saved to this spreadsheet:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.table_chart,
                      color: Color(0xFF0F9D58),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _linkedSheetTitle ?? 'Linked Spreadsheet',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to open in browser',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _unlinkSheet();
              },
              child: Text(
                'Unlink',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                launchUrl(
                  Uri.parse(sheetUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open Sheet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F9D58),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show dialog to create a new spreadsheet and link it to the form.
  void _showLinkNewSheetDialog() {
    final TextEditingController sheetNameController = TextEditingController(
      text: '${_titleController.text.trim()} (Responses)',
    );

    showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(
                Icons.add_chart_outlined,
                color: Color(0xFF673AB7),
                size: 24,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Link to Google Sheet',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Form responses will be automatically saved to this spreadsheet. '
                'A new sheet tab will be created with all responses.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sheetNameController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Spreadsheet name',
                  prefixIcon: const Icon(
                    Icons.table_chart,
                    color: Color(0xFF0F9D58),
                    size: 22,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF673AB7),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF5F6368)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final name = sheetNameController.text.trim().isEmpty
                    ? 'Untitled (Responses)'
                    : sheetNameController.text.trim();
                Navigator.of(dialogContext).pop(name);
              },
              icon: const Icon(Icons.link, size: 18),
              label: const Text('Create & Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    ).then((sheetName) {
      if (sheetName != null && mounted) {
        _createAndLinkSpreadsheet(sheetName);
      }
    });
  }

  /// Create an empty spreadsheet and link it as the form's response destination.
  Future<void> _createAndLinkSpreadsheet(String sheetName) async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      // Step 1: Create empty spreadsheet via Sheets API
      final spreadsheetId =
          await _formsService.createEmptySpreadsheet(sheetName);

      if (spreadsheetId == null) {
        if (!mounted) return;
        _safeSetState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create spreadsheet. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Step 2: Link the form to the spreadsheet via Apps Script
      final result = await _appsScriptService.linkFormToSheet(
        _currentFormId!,
        spreadsheetId,
      );

      if (!mounted) return;
      _safeSetState(() => _isSaving = false);

      if (result['success'] == true) {
        final linkedId = result['spreadsheetId'] as String? ?? spreadsheetId;
        _safeSetState(() {
          _linkedSheetId = linkedId;
          _linkedSheetTitle = sheetName;
        });

        // Load full sheet info in background
        _loadLinkedSheetInfo();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Form linked to "$sheetName" successfully!'),
            backgroundColor: const Color(0xFF0F9D58),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                launchUrl(
                  Uri.parse(
                    'https://docs.google.com/spreadsheets/d/$linkedId/edit',
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ),
        );
      } else {
        final error = result['error'] as String? ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to link: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _safeSetState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Unlink the form from its response destination spreadsheet.
  Future<void> _unlinkSheet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Unlink Sheet?'),
          content: const Text(
            'New form responses will no longer be saved to this spreadsheet. '
            'Existing responses in the sheet will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Unlink',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    final result =
        await _appsScriptService.unlinkFormFromSheet(_currentFormId!);

    if (!mounted) return;
    _safeSetState(() {
      _isSaving = false;
      if (result['success'] == true) {
        _linkedSheetId = null;
        _linkedSheetTitle = null;
      }
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sheet unlinked successfully.'),
          backgroundColor: Color(0xFF0F9D58),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final error = result['error'] as String? ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unlink: $error'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildRefreshFAB() {
    return Positioned(
      right: 20,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: _isLoadingResponses ? null : _loadResponses,
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: _isLoadingResponses
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh, size: 28),
      ),
    );
  }

  Widget _buildEmptyResponsesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Color(0xFFDADCE0),
            ),
            const SizedBox(height: 16),
            const Text(
              'No responses yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5F6368),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Responses will appear here once people submit your form.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF80868B)),
            ),
            const SizedBox(height: 24),
            if (_responderUri != null) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _responderUri!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Share this form'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildSubTabButton(
                icon: Icons.bar_chart,
                label: 'Summary',
                index: 0,
              ),
            ),
            Expanded(
              child: _buildSubTabButton(
                icon: Icons.quiz_outlined,
                label: 'Question',
                index: 1,
              ),
            ),
            Expanded(
              child: _buildSubTabButton(
                icon: Icons.person_outline,
                label: 'Individual',
                index: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabButton({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _responseSubTab == index;
    return InkWell(
      onTap: () {
        if (!_responseSubTabController.hasClients) {
          _safeSetState(() => _responseSubTab = index);
          return;
        }
        _responseSubTabController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF673AB7).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF673AB7)
                  : const Color(0xFF5F6368),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF673AB7)
                    : const Color(0xFF5F6368),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SUMMARY VIEW ====================
  Widget _buildSummaryView() {
    final totalResponses = _responses.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Response count header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF673AB7).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.people_outline,
                color: Color(0xFF673AB7),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '$totalResponses ${totalResponses == 1 ? 'response' : 'responses'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202124),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Per-question summary
        ..._buildQuestionSummaries(),
        const SizedBox(height: 80),
      ],
    );
  }

  List<Widget> _buildQuestionSummaries() {
    final widgets = <Widget>[];
    for (final i in _answerableQuestionIndices()) {
      final q = _questions[i];

      // Count total answered for this question
      var totalAnswered = 0;
      for (final response in _responses) {
        final answer = _getAnswerForQuestionIndex(response, i);
        if (answer != null && answer.isNotEmpty) {
          totalAnswered++;
        }
      }

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8EAED)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF673AB7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_displayNumberForQuestionIndex(i)}',
                        style: const TextStyle(
                          color: Color(0xFF673AB7),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.questionText.isEmpty
                                ? 'Untitled Question'
                                : q.questionText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF202124),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalAnswered ${totalAnswered == 1 ? 'response' : 'responses'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF80868B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildQuestionSummaryContent(i),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildQuestionSummaryContent(int questionIndex) {
    final q = _questions[questionIndex];
    final answerCounts = <String, int>{};
    var totalAnswered = 0;

    for (final response in _responses) {
      final answer = _getAnswerForQuestionIndex(response, questionIndex);
      if (answer != null && answer.isNotEmpty) {
        totalAnswered++;
        if (q.type == QuestionType.checkbox) {
          final parts = answer.split(', ');
          for (final part in parts) {
            final trimmed = part.trim();
            if (trimmed.isNotEmpty) {
              answerCounts[trimmed] = (answerCounts[trimmed] ?? 0) + 1;
            }
          }
        } else {
          final trimmed = answer.trim();
          answerCounts[trimmed] = (answerCounts[trimmed] ?? 0) + 1;
        }
      }
    }

    if (totalAnswered == 0) {
      return const Text(
        'No answers yet.',
        style: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // MC / Dropdown → Pie Chart
    if (q.type == QuestionType.multipleChoice ||
        q.type == QuestionType.dropdown) {
      final allOptions = q.options.where((o) => o.isNotEmpty).toList();
      for (final key in answerCounts.keys) {
        if (!allOptions.contains(key)) allOptions.add(key);
      }
      if (allOptions.isEmpty) return const SizedBox.shrink();
      return _buildPieChart(allOptions, answerCounts, totalAnswered);
    }

    // Checkbox → Horizontal Bar Chart
    if (q.type == QuestionType.checkbox) {
      final allOptions = q.options.where((o) => o.isNotEmpty).toList();
      for (final key in answerCounts.keys) {
        if (!allOptions.contains(key)) allOptions.add(key);
      }
      return _buildHorizontalBarChart(allOptions, answerCounts, totalAnswered);
    }

    // Linear Scale → Vertical Bar Chart with percentage
    if (q.type == QuestionType.linearScale) {
      return _buildLinearScaleChart(q, answerCounts, totalAnswered);
    }

    // Grid → Vertical Bar Chart
    if (q.type == QuestionType.multipleChoiceGrid ||
        q.type == QuestionType.checkboxGrid) {
      return _buildGridChart(q, questionIndex);
    }

    // Text types → grouped answers with counts
    if (q.type == QuestionType.shortAnswer ||
        q.type == QuestionType.paragraph) {
      final sortedEntries = answerCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final uniqueCount = sortedEntries.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sortedEntries
              .take(10)
              .map(
                (entry) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF202124),
                          ),
                        ),
                      ),
                      if (entry.value > 1)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1967D2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          if (uniqueCount > 10)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '... and ${uniqueCount - 10} more',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ),
        ],
      );
    }

    // Default (date, time) → answer list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: answerCounts.entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(e.key, style: const TextStyle(fontSize: 14)),
                  ),
                  Text(
                    '${e.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------- PIE CHART (MC / Dropdown) ----------
  Widget _buildPieChart(
    List<String> options,
    Map<String, int> counts,
    int total,
  ) {
    final pieColors = [
      const Color(0xFF673AB7),
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
      const Color(0xFF00ACC1),
      const Color(0xFFFF7043),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
      const Color(0xFFEF5350),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final pieSize = Responsive.getPieChartSize(constraints.maxWidth);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pie
            SizedBox(
              width: pieSize,
              height: pieSize,
              child: CustomPaint(
                painter: _PieChartPainter(
                  options: options,
                  counts: counts,
                  colors: pieColors,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(options.length, (i) {
                  final count = counts[options[i]] ?? 0;
                  final pct = total > 0
                      ? (count / total * 100).toStringAsFixed(0)
                      : '0';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: pieColors[i % pieColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            options[i],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF202124),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$count ($pct%)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- HORIZONTAL BAR CHART (Checkbox) ----------
  Widget _buildHorizontalBarChart(
    List<String> options,
    Map<String, int> counts,
    int total,
  ) {
    final maxCount = counts.values.fold(0, (a, b) => a > b ? a : b);
    return Column(
      children: options.map((option) {
        final count = counts[option] ?? 0;
        final pct = total > 0 ? count / total : 0.0;
        final barPct = maxCount > 0 ? count / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF202124),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count (${(pct * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: barPct,
                  backgroundColor: const Color(0xFFE8EAED),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF673AB7),
                  ),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------- VERTICAL BAR CHART WITH % (Linear Scale) ----------
  Widget _buildLinearScaleChart(
    QuestionItem q,
    Map<String, int> counts,
    int total,
  ) {
    final scaleMap = <int, int>{};
    for (int v = q.scaleLow; v <= q.scaleHigh; v++) {
      scaleMap[v] = 0;
    }
    counts.forEach((key, count) {
      final val = int.tryParse(key);
      if (val != null && val >= q.scaleLow && val <= q.scaleHigh) {
        scaleMap[val] = count;
      }
    });
    final maxCount = scaleMap.values.fold(0, (a, b) => a > b ? a : b);
    final chartHeight = (scaleMap.length * 28.0).clamp(80.0, 200.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (q.scaleLowLabel != null || q.scaleHighLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  q.scaleLowLabel ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                Text(
                  q.scaleHighLabel ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: chartHeight,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final barCount = scaleMap.length;
              final spacing = 6.0;
              final barWidth =
                  (constraints.maxWidth - (barCount - 1) * spacing) / barCount;
              return Row(
                children: scaleMap.entries.map((entry) {
                  final barPct = maxCount > 0 ? entry.value / maxCount : 0.0;
                  final pctStr = total > 0
                      ? (entry.value / total * 100).toStringAsFixed(0)
                      : '0';
                  return Container(
                    width: barWidth,
                    margin: EdgeInsets.only(
                      right: entry.key == scaleMap.keys.last ? 0 : spacing,
                    ),
                    child: Column(
                      children: [
                        // Percentage label (fixed)
                        SizedBox(
                          height: 18,
                          child: Center(
                            child: Text(
                              '$pctStr%',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF5F6368),
                              ),
                            ),
                          ),
                        ),
                        // Bar area (expanded, bar grows from bottom)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: maxCount > 0
                                  ? (barPct * (chartHeight - 60) * 0.3).clamp(
                                      4.0,
                                      (chartHeight - 60) * 0.3,
                                    )
                                  : 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF673AB7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Scale value
                        Text(
                          '${entry.key}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                        // Count
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------- VERTICAL BAR CHART (Grid) ----------
  Widget _buildGridChart(QuestionItem q, int questionIndex) {
    final barColors = [
      const Color(0xFF673AB7),
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
      const Color(0xFF00ACC1),
      const Color(0xFFFF7043),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
      const Color(0xFFEF5350),
    ];

    final rows = q.gridRows.where((r) => r.isNotEmpty).toList();
    final cols = q.gridColumns.where((c) => c.isNotEmpty).toList();
    if (rows.isEmpty || cols.isEmpty) {
      return const Text(
        'No grid data.',
        style: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Count per (row, col): rowCounts[row][col] = count
    final rowCounts = <String, Map<String, int>>{};
    for (final row in rows) {
      rowCounts[row] = {for (final col in cols) col: 0};
    }
    var totalCells = 0;
    for (final response in _responses) {
      final answer = _getAnswerForQuestionIndex(response, questionIndex);
      if (answer != null && answer.isNotEmpty) {
        final pairs = answer.split('; ');
        for (final pair in pairs) {
          if (!pair.contains(': ')) continue;
          final idx = pair.indexOf(': ');
          final row = pair.substring(0, idx);
          final colValue = pair.substring(idx + 2);
          if (rowCounts.containsKey(row)) {
            // For checkbox grid, a row may have multiple comma-separated column selections
            final colParts = q.type == QuestionType.checkboxGrid
                ? colValue.split(', ')
                : [colValue];
            for (final col in colParts) {
              if (rowCounts[row]!.containsKey(col)) {
                rowCounts[row]![col] = (rowCounts[row]![col] ?? 0) + 1;
                totalCells++;
              }
            }
          }
        }
      }
    }
    if (totalCells == 0) {
      return const Text(
        'No answers yet.',
        style: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Find max count across all rows/cols
    var maxCount = 0;
    for (final rowMap in rowCounts.values) {
      for (final c in rowMap.values) {
        if (c > maxCount) maxCount = c;
      }
    }

    // Chart height depends on number of rows
    final chartHeight = (rows.length * 50.0).clamp(120.0, 300.0);
    const labelHeight = 36.0;
    const yAxisWidth = 36.0;
    const baselineThickness = 1.0;

    // Y-axis ticks: 0 to maxCount (at most 5 ticks)
    final yTickCount = maxCount <= 5 ? maxCount : 5;
    final yTickStep = maxCount <= 5 ? 1 : (maxCount / 5).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend for columns
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: List.generate(
            cols.length,
            (ci) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: barColors[ci % barColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  cols[ci],
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Chart area with Y-axis
        SizedBox(
          height: chartHeight + baselineThickness + labelHeight,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final barAreaHeight = chartHeight;
              final barAreaWidth = constraints.maxWidth - yAxisWidth;
              final groupWidth = barAreaWidth / rows.length;
              final barGap = 2.0;
              // Calculate bar width that always fits within groupWidth (no upward clamp)
              final colBarWidth = max(
                1.0,
                (groupWidth - (cols.length + 1) * barGap) / cols.length,
              );

              return Column(
                children: [
                  // Bar area — Y-axis + bars side by side
                  SizedBox(
                    height: barAreaHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Y-axis labels
                        SizedBox(
                          width: yAxisWidth,
                          child: Stack(
                            children: [
                              // Tick labels
                              ...List.generate(yTickCount + 1, (ti) {
                                final value = (ti * yTickStep).toInt();
                                if (value > maxCount) {
                                  return const SizedBox.shrink();
                                }
                                final fraction = maxCount > 0
                                    ? value / maxCount
                                    : 0.0;
                                final top =
                                    barAreaHeight * (1.0 - fraction) - 6;
                                return Positioned(
                                  top: top.clamp(0.0, barAreaHeight - 14),
                                  left: 0,
                                  right: 4,
                                  child: Text(
                                    '$value',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        // Bar chart area with horizontal gridlines
                        Expanded(
                          child: Stack(
                            children: [
                              // Horizontal gridlines
                              ...List.generate(yTickCount + 1, (ti) {
                                final value = (ti * yTickStep).toInt();
                                if (value > maxCount) {
                                  return const SizedBox.shrink();
                                }
                                final fraction = maxCount > 0
                                    ? value / maxCount
                                    : 0.0;
                                final top = barAreaHeight * (1.0 - fraction);
                                return Positioned(
                                  left: 0,
                                  right: 0,
                                  top: top,
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFE8EAED),
                                  ),
                                );
                              }),
                              // Bars — wrapped in SizedBox.expand so the Row fills
                              // the full Stack height, keeping bar bottoms at the 0 line
                              SizedBox.expand(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(rows.length, (ri) {
                                    final row = rows[ri];
                                    final rowCountsMap = rowCounts[row] ?? {};
                                    return SizedBox(
                                      width: groupWidth,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(cols.length, (
                                          ci,
                                        ) {
                                          final count =
                                              rowCountsMap[cols[ci]] ?? 0;
                                          final barPct = maxCount > 0
                                              ? count / maxCount
                                              : 0.0;
                                          return Container(
                                            width: colBarWidth,
                                            height: maxCount > 0
                                                ? (barPct * barAreaHeight)
                                                      .clamp(
                                                        count > 0 ? 4.0 : 0.0,
                                                        barAreaHeight,
                                                      )
                                                : 0,
                                            margin: EdgeInsets.symmetric(
                                              horizontal: barGap / 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  barColors[ci %
                                                      barColors.length],
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom axis line
                  Row(
                    children: [
                      const SizedBox(width: yAxisWidth),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFDADCE0),
                        ),
                      ),
                    ],
                  ),
                  // Label area — shared fixed height, all labels in one row
                  SizedBox(
                    height: labelHeight,
                    child: Row(
                      children: [
                        const SizedBox(width: yAxisWidth),
                        Expanded(
                          child: Row(
                            children: List.generate(rows.length, (ri) {
                              return SizedBox(
                                width: groupWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Text(
                                    rows[ri],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF5F6368),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String? _getAnswerForQuestionIndex(FormResponse response, int questionIndex) {
    if (questionIndex < 0 || questionIndex >= _questions.length) return null;
    final q = _questions[questionIndex];

    // For grid questions, combine answers from all row question IDs
    if (q.type == QuestionType.multipleChoiceGrid ||
        q.type == QuestionType.checkboxGrid) {
      if (q.gridRowQuestionIds.isEmpty) return null;
      final parts = <String>[];
      for (
        int r = 0;
        r < q.gridRowQuestionIds.length && r < q.gridRows.length;
        r++
      ) {
        final rowQId = q.gridRowQuestionIds[r];
        final answer = response.getAnswerForQuestion(rowQId);
        if (answer.isNotEmpty) {
          parts.add('${q.gridRows[r]}: $answer');
        }
      }
      return parts.isEmpty ? null : parts.join('; ');
    }

    // For regular questions, use the itemId (which stores the questionId from the API)
    if (q.itemId.isEmpty) return null;
    final answer = response.getAnswerForQuestion(q.itemId);
    return answer.isEmpty ? null : answer;
  }

  // ==================== QUESTION VIEW ====================
  Widget _buildQuestionView() {
    final questionIndices = _answerableQuestionIndices();

    if (questionIndices.isEmpty) {
      return const Center(
        child: Text(
          'No questions found.',
          style: TextStyle(color: Color(0xFF5F6368), fontSize: 16),
        ),
      );
    }

    // Clamp selected index
    if (_selectedQuestionIndex >= questionIndices.length) {
      _selectedQuestionIndex = questionIndices.length - 1;
    }

    final currentQIndex = questionIndices[_selectedQuestionIndex];
    final currentQ = _questions[currentQIndex];

    return Column(
      children: [
        // Question selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Text(
                'Question: ',
                style: TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedQuestionIndex,
                  isExpanded: true,
                  underline: Container(),
                  items: questionIndices.asMap().entries.map((entry) {
                    final qi = entry.value;
                    final q = _questions[qi];
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        q.questionText.isEmpty
                            ? 'Question ${entry.key + 1}'
                            : q.questionText,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _safeSetState(() => _selectedQuestionIndex = val);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        // Navigation arrows
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _selectedQuestionIndex > 0
                    ? () => _safeSetState(() => _selectedQuestionIndex--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF673AB7),
              ),
              Text(
                '${_selectedQuestionIndex + 1} / ${questionIndices.length}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
              ),
              IconButton(
                onPressed: _selectedQuestionIndex < questionIndices.length - 1
                    ? () => _safeSetState(() => _selectedQuestionIndex++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF673AB7),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Question detail content — pattern-based display
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE8EAED)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQ.questionText.isEmpty
                            ? 'Untitled Question'
                            : currentQ.questionText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF202124),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _questionTypeLabel(currentQ.type),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF80868B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionPatternContent(currentQIndex),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== QUESTION PATTERN CONTENT ====================
  Widget _buildQuestionPatternContent(int questionIndex) {
    final q = _questions[questionIndex];

    // Collect all answers and group by pattern
    final patternCounts = <String, List<String>>{};
    for (final response in _responses) {
      final answer = _getAnswerForQuestionIndex(response, questionIndex);
      final key = answer ?? '';
      if (!patternCounts.containsKey(key)) patternCounts[key] = [];
      patternCounts[key]!.add(key);
    }
    // Remove empty pattern
    patternCounts.remove('');

    if (patternCounts.isEmpty) {
      return const Text(
        'No answers yet.',
        style: TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Sort patterns by count descending
    final sortedPatterns = patternCounts.keys.toList()
      ..sort(
        (a, b) => patternCounts[b]!.length.compareTo(patternCounts[a]!.length),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedPatterns.map((pattern) {
        final count = patternCounts[pattern]!.length;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F0FE),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8DEF8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatternOptions(q, pattern),
              const SizedBox(height: 8),
              Text(
                '$count ${count == 1 ? 'Response' : 'Responses'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF673AB7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatternOptions(QuestionItem q, String pattern) {
    // MC / Dropdown → radio-style
    if (q.type == QuestionType.multipleChoice ||
        q.type == QuestionType.dropdown) {
      final options = q.options.where((o) => o.isNotEmpty).toList();
      return Column(
        children: options
            .map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      pattern == opt
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: pattern == opt
                          ? const Color(0xFF673AB7)
                          : const Color(0xFFBDBDBD),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 14,
                          color: pattern == opt
                              ? const Color(0xFF202124)
                              : const Color(0xFF9E9E9E),
                          fontWeight: pattern == opt
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }

    // Checkbox → checkbox-style (pattern may be "Opt1, Opt2")
    if (q.type == QuestionType.checkbox) {
      final selected = pattern.split(', ').toSet();
      final options = q.options.where((o) => o.isNotEmpty).toList();
      return Column(
        children: options
            .map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      selected.contains(opt)
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: selected.contains(opt)
                          ? const Color(0xFF673AB7)
                          : const Color(0xFFBDBDBD),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 14,
                          color: selected.contains(opt)
                              ? const Color(0xFF202124)
                              : const Color(0xFF9E9E9E),
                          fontWeight: selected.contains(opt)
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }

    // Linear Scale → show selected value
    if (q.type == QuestionType.linearScale) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.linear_scale, color: Color(0xFF673AB7), size: 20),
            const SizedBox(width: 8),
            Text(
              pattern,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202124),
              ),
            ),
            if (q.scaleLowLabel != null || q.scaleHighLabel != null) ...[
              const SizedBox(width: 12),
              Text(
                '(${q.scaleLowLabel ?? q.scaleLow} – ${q.scaleHighLabel ?? q.scaleHigh})',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ],
          ],
        ),
      );
    }

    // Grid → show row:col pairs
    if (q.type == QuestionType.multipleChoiceGrid ||
        q.type == QuestionType.checkboxGrid) {
      final pairs = pattern.split('; ');
      return Column(
        children: pairs.map((pair) {
          final parts = pair.split(': ');
          final row = parts.isNotEmpty ? parts[0] : pair;
          final col = parts.length > 1 ? parts[1] : '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF673AB7),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  row,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202124),
                  ),
                ),
                if (col.isNotEmpty) ...[
                  const Text(' → ', style: TextStyle(color: Color(0xFF9E9E9E))),
                  Text(
                    col,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      );
    }

    // Text / Date / Time → just show text
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        pattern,
        style: const TextStyle(fontSize: 14, color: Color(0xFF202124)),
      ),
    );
  }

  // ==================== INDIVIDUAL VIEW ====================
  Widget _buildIndividualView() {
    if (_responses.isEmpty) {
      return const Center(
        child: Text(
          'No responses.',
          style: TextStyle(color: Color(0xFF5F6368), fontSize: 16),
        ),
      );
    }

    if (_selectedIndividualIndex >= _responses.length) {
      _selectedIndividualIndex = _responses.length - 1;
    }

    final response = _responses[_selectedIndividualIndex];
    final submittedTime = _formatTimestamp(response.lastSubmittedTime);

    return Column(
      children: [
        // Navigation bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _selectedIndividualIndex > 0
                    ? () => _safeSetState(() => _selectedIndividualIndex--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF673AB7),
              ),
              Text(
                '${_selectedIndividualIndex + 1} of ${_responses.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
              ),
              IconButton(
                onPressed: _selectedIndividualIndex < _responses.length - 1
                    ? () => _safeSetState(() => _selectedIndividualIndex++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF673AB7),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Individual response detail
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card with timestamp
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFF673AB7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        submittedTime.isNotEmpty
                            ? 'Submitted: $submittedTime'
                            : 'Response ${_selectedIndividualIndex + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Answers for each question
              ..._buildIndividualAnswers(response),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIndividualAnswers(FormResponse response) {
    final widgets = <Widget>[];
    for (final i in _answerableQuestionIndices()) {
      final q = _questions[i];
      final answer = _getAnswerForQuestionIndex(response, i);

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8EAED)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF673AB7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_displayNumberForQuestionIndex(i)}',
                        style: const TextStyle(
                          color: Color(0xFF673AB7),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.questionText.isEmpty
                                ? 'Untitled Question'
                                : q.questionText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF202124),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (answer != null && answer.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                answer,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF202124),
                                ),
                              ),
                            )
                          else
                            const Text(
                              'No answer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9E9E9E),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  /// Load the title of the currently linked spreadsheet (if any).
  Future<void> _loadLinkedSheetInfo() async {
    if (_linkedSheetId == null) return;
    final info = await _formsService.getSpreadsheetInfo(_linkedSheetId!);
    if (info != null && mounted) {
      _safeSetState(() {
        _linkedSheetTitle = info['title'];
      });
    }
  }

  Future<void> _loadFormSettings() async {
    debugPrint('=== _loadFormSettings START ===');
    debugPrint('formId: $_currentFormId');

    final result = await _appsScriptService.getFormSettings(_currentFormId!);
    if (!mounted) return;

    debugPrint('=== _loadFormSettings RESULT ===');
    debugPrint('success: ${result['success']}');
    debugPrint('settings: ${result['settings']}');
    debugPrint('error: ${result['error']}');

    if (result['success'] == true) {
      final settings = result['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        debugPrint('=== _loadFormSettings APPLYING SETTINGS ===');
        debugPrint('isAcceptingResponses: ${settings['isAcceptingResponses']}');
        debugPrint('limitOneResponse: ${settings['limitOneResponse']}');
        debugPrint('editAfterSubmit: ${settings['editAfterSubmit']}');
        debugPrint('showProgressBar: ${settings['showProgressBar']}');
        debugPrint('shuffleQuestions: ${settings['shuffleQuestions']}');
        debugPrint('confirmationMessage: ${settings['confirmationMessage']}');
        debugPrint('sendResponseCopy: ${settings['sendResponseCopy']}');

        // Read shuffleQuestions from Apps Script result (highest priority).
        // REST API shuffle was already loaded via getFormWithAllData().
        final appsScriptShuffle = settings['shuffleQuestions'] as bool?;
        final effectiveShuffle = appsScriptShuffle ?? _shuffleQuestions;

        debugPrint('=== SHUFFLE DEBUG ===');
        debugPrint('Apps Script shuffleQuestions: $appsScriptShuffle');
        debugPrint('Effective shuffleQuestions: $effectiveShuffle');

        _safeSetState(() {
          _isAcceptingResponses = settings['isAcceptingResponses'] as bool? ?? true;
          _limitOneResponse = settings['limitOneResponse'] as bool? ?? false;
          _editAfterSubmit = settings['editAfterSubmit'] as bool? ?? false;
          _showProgressBar = settings['showProgressBar'] as bool? ?? false;
          _shuffleQuestions = effectiveShuffle;
          _sendResponseCopy = settings['sendResponseCopy'] as bool? ?? false;
          final msg = settings['confirmationMessage'] as String?;
          if (msg != null && msg.isNotEmpty) {
            _confirmationMessageController.text = msg;
          }
          _linkedSheetId ??= settings['linkedSheetId'] as String?;
        });
        debugPrint('=== _loadFormSettings SETTINGS APPLIED SUCCESSFULLY ===');
        debugPrint('_shuffleQuestions is now: $_shuffleQuestions');
      } else {
        debugPrint('=== _loadFormSettings WARNING: settings map is null ===');
      }
    } else {
      final error = result['error'] as String?;
      debugPrint('=== _loadFormSettings FAILED: $error ===');
      if (mounted && error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load form settings: $error'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Load publish settings from the REST API.
  /// Show reminder dialog when user tries to accept responses on an unpublished form.
  void _showPublishReminder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF673AB7), size: 22),
            SizedBox(width: 8),
            Text('Publish Required', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'You need to publish this form before it can accept responses. '
          'Would you like to publish it now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _togglePublish();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
            ),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  void _reloadPreview() {
    if (_webViewController != null && _responderUri != null) {
      _webViewController!.reload();
    }
  }

  /// Publish or unpublish the form via REST API.
  Future<void> _togglePublish() async {
    if (_currentFormId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save the form first before publishing.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isPublished) {
      // Already published, show options
      _showPublishedOptions();
      return;
    }

    // Publish the form
    _safeSetState(() => _isPublishing = true);

    final result = await _formsService.setPublishSettings(
      _currentFormId!,
      isPublished: true,
      isAcceptingResponses: true,
    );

    if (!mounted) return;
    _safeSetState(() => _isPublishing = false);

    if (result != null && (result['success'] as bool? ?? false)) {
      _safeSetState(() {
        _isPublished = true;
        _isAcceptingResponses = true;
      });

      // Reload the preview WebView so the updated publish state is reflected
      _reloadPreview();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Form published and now accepting responses!')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      final error = result?['error'] as String? ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to publish: ${_friendlyError(error)}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Show options for an already-published form.
  void _showPublishedOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Form is published',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.link, size: 20),
                title: const Text('Copy form link'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (_responderUri != null && _responderUri!.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: _responderUri!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.toggle_off, size: 20),
                title: const Text('Unpublish form'),
                subtitle: const Text('Form will stop accepting responses'),
                onTap: () async {
                  Navigator.pop(ctx);
                  _safeSetState(() => _isPublishing = true);
                  final result = await _formsService.setPublishSettings(
                    _currentFormId!,
                    isPublished: false,
                    isAcceptingResponses: false,
                  );
                  if (!mounted) return;
                  _safeSetState(() {
                    _isPublishing = false;
                    if (result != null && (result['success'] as bool? ?? false)) {
                      _isPublished = false;
                      _isAcceptingResponses = false;
                    }
                  });
                  if (result != null && (result['success'] as bool? ?? false)) {
                    _reloadPreview();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Form unpublished'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SETTINGS TAB ====================
  Widget _buildSettingsTab() {
    if (_isLoadingSettings) {
      return _buildSettingsLoadingSkeleton();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Responses Section ──
        _buildSettingsSectionHeader('Responses'),
        _buildSettingsCard([
          // Accept responses
          _buildSettingsSwitch(
            icon: Icons.toggle_on,
            title: 'Accept responses',
            subtitle: _isAcceptingResponses
                ? 'People can submit responses to this form'
                : 'This form is not accepting responses',
            value: _isAcceptingResponses,
            onChanged: (val) {
              if (val && !_isPublished) {
                _showPublishReminder();
                return;
              }
              _safeSetState(() { _markDirty(); _isAcceptingResponses = val; });
            },
          ),
          const Divider(height: 1, indent: 56),
          // Collect email addresses
          _buildSettingsDropdown(
            icon: Icons.email_outlined,
            title: 'Collect email addresses',
            subtitle: 'Choose how to collect responder emails',
            value: _emailCollectionType,
            items: const [
              DropdownMenuItem(value: 'none', child: Text("Don't collect")),
              DropdownMenuItem(value: 'verified', child: Text('Verified')),
              DropdownMenuItem(
                value: 'responder_input',
                child: Text('Responder input'),
              ),
            ],
            onChanged: (val) {
              _markDirty();
              _safeSetState(() {
                _emailCollectionType = val ?? 'none';
                _collectEmail = val != 'none';
              });
            },
          ),
          const Divider(height: 1, indent: 56),
          // Limit to 1 response
          _buildSettingsSwitch(
            icon: Icons.person_add_outlined,
            title: 'Limit to 1 response',
            subtitle: 'Requires responders to sign in',
            value: _limitOneResponse,
            onChanged: (val) => _safeSetState(() { _markDirty(); _limitOneResponse = val; }),
          ),
          const Divider(height: 1, indent: 56),
          // Edit after submit
          _buildSettingsSwitch(
            icon: Icons.edit_note,
            title: 'Edit after submit',
            subtitle:
                'Allow responders to edit their response after submission',
            value: _editAfterSubmit,
            onChanged: (val) => _safeSetState(() { _markDirty(); _editAfterSubmit = val; }),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Presentation Section ──
        _buildSettingsSectionHeader('Presentation'),
        _buildSettingsCard([
          // Show progress bar
          _buildSettingsSwitch(
            icon: Icons.linear_scale,
            title: 'Show progress bar',
            subtitle: 'Shows a progress bar at the bottom of the form',
            value: _showProgressBar,
            onChanged: (val) => _safeSetState(() { _markDirty(); _showProgressBar = val; }),
          ),
          const Divider(height: 1, indent: 56),
          // Shuffle questions
          _buildSettingsSwitch(
            icon: Icons.shuffle,
            title: 'Shuffle question order',
            subtitle:
                'Questions will appear in a different order for each responder',
            value: _shuffleQuestions,
            onChanged: (val) => _safeSetState(() { _markDirty(); _shuffleQuestions = val; }),
          ),
          const Divider(height: 1, indent: 56),
          // Confirmation message
          _buildSettingsTextField(
            icon: Icons.check_circle_outline,
            title: 'Confirmation message',
            subtitle: 'Message shown after form submission',
            controller: _confirmationMessageController,
            hintText: 'Enter confirmation message',
          ),
        ]),
        const SizedBox(height: 20),

        // ── Editors Section ──
        _buildSettingsSectionHeaderWithAction(
          'Editors',
          onAdd: _isCurrentUserOwner ? _showAddEditorDialog : null,
        ),
        _buildSettingsCard(_buildEditorsSectionChildren()),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEditTabSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        children: [
          // Form Info Card skeleton
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _SkeletonLine(width: 180, height: 26),
                  ),
                ),
                SizedBox(height: 16),
                Divider(height: 1, indent: 20, endIndent: 20),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _SkeletonLine(width: 240, height: 14),
                  ),
                ),
                SizedBox(height: 6),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _SkeletonLine(width: 160, height: 14),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Question card skeletons
          _buildSkeletonQuestionCard(),
          const SizedBox(height: 12),
          _buildSkeletonQuestionCard(),
          const SizedBox(height: 12),
          _buildSkeletonQuestionCard(),
        ],
      ),
    );
  }

  Widget _buildSkeletonQuestionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SkeletonLine(width: 22, height: 22, radius: 4),
                SizedBox(width: 12),
                Expanded(child: _SkeletonLine(height: 14)),
              ],
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(left: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonLine(width: 220, height: 14),
                  SizedBox(height: 14),
                  _SkeletonLine(width: 180, height: 14),
                  SizedBox(height: 14),
                  _SkeletonLine(width: 200, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Response count header skeleton
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF673AB7).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              _SkeletonLine(width: 28, height: 28, radius: 14),
              SizedBox(width: 12),
              _SkeletonLine(width: 120, height: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Question summary card skeletons
        _buildSkeletonSummaryCard(),
        const SizedBox(height: 12),
        _buildSkeletonSummaryCard(),
        const SizedBox(height: 12),
        _buildSkeletonSummaryCard(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSkeletonSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 28, height: 24, radius: 4),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(width: 200, height: 16),
                      SizedBox(height: 6),
                      _SkeletonLine(width: 90, height: 12, color: Color(0xFFF1F3F4)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Bar chart skeleton
            Padding(
              padding: EdgeInsets.only(left: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _SkeletonLine(height: 32, radius: 2)),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _SkeletonLine(height: 56, radius: 2),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: _SkeletonLine(height: 40, radius: 2)),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: _SkeletonLine(height: 72, radius: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Responses Section Skeleton ──
        _buildSettingsSectionHeader('Responses'),
        _buildSettingsCard([
          _buildSkeletonRow(),
          const Divider(height: 1, indent: 56),
          _buildSkeletonRow(),
          const Divider(height: 1, indent: 56),
          _buildSkeletonRow(),
          const Divider(height: 1, indent: 56),
          _buildSkeletonRow(),
        ]),
        const SizedBox(height: 20),

        // ── Presentation Section Skeleton ──
        _buildSettingsSectionHeader('Presentation'),
        _buildSettingsCard([
          _buildSkeletonRow(),
          const Divider(height: 1, indent: 56),
          _buildSkeletonRow(),
          const Divider(height: 1, indent: 56),
          _buildSkeletonRow(),
        ]),
        const SizedBox(height: 20),

        // ── Editors Section Skeleton ──
        _buildSettingsSectionHeader('Editors'),
        _buildSettingsCard([
          _buildSkeletonEditorRow(),
          const Divider(height: 1, indent: 72),
          _buildSkeletonEditorRow(),
        ]),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSkeletonRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const _SkeletonLine(width: 22, height: 22, radius: 4),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkeletonLine(height: 14, width: 140),
                SizedBox(height: 6),
                _SkeletonLine(height: 11, width: 200, color: Color(0xFFF1F3F4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _SkeletonLine(width: 46, height: 26, radius: 13),
        ],
      ),
    );
  }

  Widget _buildSkeletonEditorRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const _SkeletonLine(width: 40, height: 40, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkeletonLine(height: 14, width: 120),
                SizedBox(height: 6),
                _SkeletonLine(height: 11, width: 180, color: Color(0xFFF1F3F4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEditorsSectionChildren() {
    if (_isLoadingEditors) {
      return [
        _buildSkeletonEditorRow(),
        const Divider(height: 1, indent: 72),
        _buildSkeletonEditorRow(),
      ];
    }

    final children = <Widget>[];

    if (_owner != null) {
      children.add(_buildEditorItem(_owner!, isOwnerRow: true));
    }

    if (_editors.isEmpty) {
      if (_owner != null) {
        children.add(const Divider(height: 1, indent: 72));
      }
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Text(
            _owner == null
                ? 'No collaborators found for this form.'
                : _isCurrentUserOwner
                    ? 'No editors yet. Tap +Add to invite someone by Gmail.'
                    : 'No editors on this form.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF80868B),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
      return children;
    }

    if (_owner != null) {
      children.add(const Divider(height: 1, indent: 72));
    }

    for (var i = 0; i < _editors.length; i++) {
      if (i > 0) {
        children.add(const Divider(height: 1, indent: 72));
      }
      children.add(_buildEditorItem(_editors[i]));
    }
    return children;
  }

  Widget _buildSettingsSectionHeaderWithAction(
    String title, {
    VoidCallback? onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF673AB7),
              ),
            ),
          ),
          if (onAdd != null)
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF673AB7),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(44, 44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditorItem(FormEditor editor, {bool isOwnerRow = false}) {
    final initial = editor.displayLabel.isNotEmpty
        ? editor.displayLabel[0].toUpperCase()
        : '?';
    final showDelete = _isCurrentUserOwner && !isOwnerRow && !editor.isOwner;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF673AB7),
            backgroundImage: editor.photoUrl != null
                ? CachedNetworkImageProvider(editor.photoUrl!)
                : null,
            child: editor.photoUrl == null
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editor.displayLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202124),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (editor.displayName?.trim().isNotEmpty == true ||
                    isOwnerRow) ...[
                  const SizedBox(height: 2),
                  Text(
                    editor.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF80868B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (isOwnerRow)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Owner',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF673AB7),
                ),
              ),
            )
          else if (showDelete)
            IconButton(
              onPressed: () => _showRemoveEditorConfirmation(editor),
              icon: const Icon(Icons.person_remove_outlined),
              color: const Color(0xFF5F6368),
              tooltip: 'Remove editor',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
        ],
      ),
    );
  }

  Future<void> _loadEditors() async {
    final formId = _currentFormId;
    if (formId == null || formId.isEmpty) return;

    _safeSetState(() => _isLoadingEditors = true);

    final result = await _formsService.listEditors(formId);
    if (!mounted) return;

    if (result == null) {
      _safeSetState(() => _isLoadingEditors = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load editors.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _safeSetState(() {
      _editors = result.editors;
      _owner = result.owner;
      _isLoadingEditors = false;
    });
  }

  Future<void> _showAddEditorDialog() async {
    if (!_isCurrentUserOwner) return;

    final email = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _AddEditorDialog(),
    );

    if (email != null && email.isNotEmpty && mounted) {
      await _addEditor(email);
    }
  }

  Future<void> _addEditor(String email) async {
    final formId = _currentFormId;
    if (formId == null || formId.isEmpty) return;

    final normalizedEmail = email.trim().toLowerCase();
    final currentUserEmail = _authService.currentUser?.email.toLowerCase();

    if (currentUserEmail != null && normalizedEmail == currentUserEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already the owner of this form.'),
        ),
      );
      return;
    }

    if (_owner?.email.toLowerCase() == normalizedEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This user is already the owner of this form.'),
        ),
      );
      return;
    }

    if (_editors.any((editor) => editor.email.toLowerCase() == normalizedEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This user is already an editor on this form.'),
        ),
      );
      return;
    }

    _safeSetState(() => _isLoadingEditors = true);

    final result = await _formsService.addEditor(formId, normalizedEmail);
    if (!mounted) return;

    if (!result.success) {
      _safeSetState(() => _isLoadingEditors = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to add editor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $normalizedEmail as an editor.')),
    );
    await _loadEditors();
  }

  Future<void> _showRemoveEditorConfirmation(FormEditor editor) async {
    if (!_isCurrentUserOwner) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove editor?'),
        content: Text(
          'Remove ${editor.displayLabel} from this form? They will no longer be able to edit it.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _removeEditor(editor);
    }
  }

  Future<void> _removeEditor(FormEditor editor) async {
    if (!_isCurrentUserOwner) return;

    final formId = _currentFormId;
    if (formId == null || formId.isEmpty) return;

    if (editor.isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The owner cannot be removed.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _safeSetState(() => _isLoadingEditors = true);

    final result = await _formsService.removeEditor(formId, editor.permissionId);
    if (!mounted) return;

    if (!result.success) {
      _safeSetState(() => _isLoadingEditors = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to remove editor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${editor.displayLabel}.')),
    );
    await _loadEditors();
  }

  Widget _buildSettingsSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF673AB7),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: const Color(0xFF5F6368), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF80868B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF673AB7),
            activeTrackColor: const Color(0xFFD1C4E9),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsDropdown({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: const Color(0xFF5F6368), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF80868B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDADCE0)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: value,
                    items: items,
                    onChanged: onChanged,
                    isExpanded: true,
                    underline: Container(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF202124),
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTextField({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: const Color(0xFF5F6368), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF80868B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFDADCE0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFDADCE0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFF673AB7),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF202124),
                  ),
                  onChanged: (_) => _markDirty(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== VIDEO CONTENT ====================
  Widget _buildVideoContent(int index) {
    final mediaUrl = _questions[index].mediaUrl;
    final hasVideo = mediaUrl != null && mediaUrl.isNotEmpty;
    final videoId = hasVideo ? _extractYouTubeVideoId(mediaUrl) : null;
    final thumbnailUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasVideo)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _openYouTubeVideo(mediaUrl),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 180),
                      color: const Color(0xFF1A1A1A),
                      child: thumbnailUrl != null
                          ? Image.network(
                              thumbnailUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 140,
                                  color: const Color(0xFF1A1A1A),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF673AB7),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (ctx, error, _) {
                                return Container(
                                  height: 140,
                                  color: const Color(0xFF1A1A1A),
                                  child: const Center(
                                    child: Icon(
                                      Icons.videocam,
                                      color: Color(0xFFBDBDBD),
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 140,
                              color: const Color(0xFF1A1A1A),
                              child: const Center(
                                child: Icon(
                                  Icons.videocam,
                                  color: Color(0xFFBDBDBD),
                                  size: 48,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showVideoUrlDialog(index),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Change'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF5F6368),
                              side: const BorderSide(color: Color(0xFFDADCE0)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _markDirty();
                              _safeSetState(() {
                                _questions[index].mediaUrl = null;
                                _videoUrlControllers[index].clear();
                              });
                            },
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Remove'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE53935),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (!hasVideo)
            GestureDetector(
              onTap: () => _showVideoUrlDialog(index),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF673AB7).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Color(0xFF673AB7), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Paste YouTube video URL',
                      style: TextStyle(
                        color: const Color(0xFF673AB7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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

// ==================== PIE CHART PAINTER ====================
class _PieChartPainter extends CustomPainter {
  final List<String> options;
  final Map<String, int> counts;
  final List<Color> colors;

  _PieChartPainter({
    required this.options,
    required this.counts,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0 || options.isEmpty) return;

    var startAngle = -pi / 2; // Start from top
    for (int i = 0; i < options.length; i++) {
      final count = counts[options[i]] ?? 0;
      if (count == 0) continue;
      final sweepAngle = (count / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      options != oldDelegate.options || counts != oldDelegate.counts;
}

/// Drag handle listener that requires a 0.6s hold before reorder drag starts.
class _OneSecondReorderDragStartListener extends ReorderableDragStartListener {
  static const Duration _holdDelay = Duration(milliseconds: 600);

  const _OneSecondReorderDragStartListener({
    required super.child,
    required super.index,
  });

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(
      delay: _holdDelay,
      debugOwner: this,
    );
  }
}

class _SkeletonLine extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonLine({
    this.width,
    this.height = 14,
    this.radius = 4,
    this.color = const Color(0xFFE8EAED),
  });

  @override
  State<_SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<_SkeletonLine>
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

class _AddEditorDialog extends StatefulWidget {
  const _AddEditorDialog();

  @override
  State<_AddEditorDialog> createState() => _AddEditorDialogState();
}

class _AddEditorDialogState extends State<_AddEditorDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      Navigator.pop(context, _emailController.text.trim());
    }
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add editor'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Gmail address',
            hintText: 'name@gmail.com',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Please enter a Gmail address.';
            }
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            if (!emailRegex.hasMatch(trimmed)) {
              return 'Please enter a valid email address.';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            'Add',
            style: TextStyle(color: Color(0xFF673AB7)),
          ),
        ),
      ],
    );
  }
}
