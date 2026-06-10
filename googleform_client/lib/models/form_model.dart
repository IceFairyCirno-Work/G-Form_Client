import 'question_model.dart';

/// A collaborator on a form, backed by a Google Drive permission entry.
class FormEditor {
  final String permissionId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role; // 'owner', 'writer', 'reader'
  final String type; // 'user', 'group', 'anyone'

  const FormEditor({
    required this.permissionId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.type,
  });

  bool get isOwner => role == 'owner';
  bool get isWriter => role == 'writer';

  String get displayLabel => displayName?.trim().isNotEmpty == true
      ? displayName!.trim()
      : email;

  factory FormEditor.fromDrivePermission(Map<String, dynamic> json) {
    return FormEditor(
      permissionId: json['id'] as String? ?? '',
      email: json['emailAddress'] as String? ?? '',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoLink'] as String?,
      role: json['role'] as String? ?? 'reader',
      type: json['type'] as String? ?? 'user',
    );
  }
}

class FormModel {
  String formId;
  String title;
  String description;
  List<QuestionItem> questions;
  String? responderUri;
  String? documentTitle;
  String? linkedSheetId;

  // Settings - General
  bool isAcceptingResponses;
  bool collectEmail;
  String emailCollectionType; // 'none', 'verified', 'responder_input'
  bool sendResponseCopy;
  bool limitOneResponse;
  bool editAfterSubmit;
  bool showProgressBar;
  String confirmationMessage;
  bool shuffleQuestions;
  List<FormEditor> editors;

  FormModel({
    this.formId = '',
    this.title = 'Untitled form',
    this.description = '',
    List<QuestionItem>? questions,
    this.responderUri,
    this.documentTitle,
    this.linkedSheetId,
    this.isAcceptingResponses = true,
    this.collectEmail = false,
    this.emailCollectionType = 'none',
    this.sendResponseCopy = false,
    this.limitOneResponse = false,
    this.editAfterSubmit = false,
    this.showProgressBar = false,
    this.confirmationMessage = 'Your response has been recorded.',
    this.shuffleQuestions = false,
    List<FormEditor>? editors,
  })  : questions = questions ?? [QuestionItem()],
        editors = editors ?? [];

  Map<String, dynamic> toCreateJson() {
    return {
      'info': {
        'title': title,
      },
    };
  }

  /// Maps API emailCollectionType values to internal values.
  static String _parseEmailCollectionType(String? apiValue) {
    switch (apiValue) {
      case 'VERIFIED':
        return 'verified';
      case 'RESPONDER_INPUT':
        return 'responder_input';
      case 'DO_NOT_COLLECT':
      default:
        return 'none';
    }
  }

  factory FormModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?) ?? [];
    final questions = items
        .map((item) => QuestionItem.fromApiJson(item as Map<String, dynamic>))
        .toList();

    // Parse emailCollectionType from REST API response
    final settingsJson = json['settings'] as Map<String, dynamic>?;
    final apiEmailType = settingsJson?['emailCollectionType'] as String?;
    final emailType = _parseEmailCollectionType(apiEmailType);

    return FormModel(
      formId: json['formId'] as String? ?? '',
      title: (json['info'] as Map<String, dynamic>?)?['title'] as String? ?? 'Untitled form',
      description: (json['info'] as Map<String, dynamic>?)?['description'] as String? ?? '',
      responderUri: json['responderUri'] as String?,
      documentTitle: (json['info'] as Map<String, dynamic>?)?['documentTitle'] as String?,
      linkedSheetId: json['linkedSheetId'] as String?,
      questions: questions.isNotEmpty ? questions : [QuestionItem()],
      collectEmail: emailType != 'none',
      emailCollectionType: emailType,
    );
  }
}