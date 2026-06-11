import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'google_auth_service.dart';
import '../models/form_model.dart';
import '../models/question_model.dart';
import '../models/response_model.dart';

/// Summary of changes between original and updated form.
class FormChangeSummary {
  final bool titleChanged;
  final bool descriptionChanged;
  final List<QuestionItem> addedQuestions;
  final List<QuestionItem> deletedQuestions;
  final List<QuestionItem> updatedQuestions;
  final List<int> movedQuestionIndices;
  final bool hasBreakingChanges;
  final String breakingChangesDescription;

  FormChangeSummary({
    required this.titleChanged,
    required this.descriptionChanged,
    required this.addedQuestions,
    required this.deletedQuestions,
    required this.updatedQuestions,
    required this.movedQuestionIndices,
    required this.hasBreakingChanges,
    required this.breakingChangesDescription,
  });

}

/// Whether a new question has enough content to be created via the API.
bool isCreateableQuestion(QuestionItem q) {
  if (q.type == QuestionType.image &&
      (q.mediaUrl == null || q.mediaUrl!.isEmpty)) {
    return false;
  }
  if (q.type == QuestionType.video &&
      (q.mediaUrl == null || q.mediaUrl!.isEmpty)) {
    return false;
  }
  if (q.type != QuestionType.image &&
      q.type != QuestionType.video &&
      q.questionText.trim().isEmpty) {
    return false;
  }
  return true;
}

/// Build sequential `moveItem` requests to transform [currentOrder] into
/// [targetOrder]. Simulates index shifts after each move because batchUpdate
/// processes requests in order.
List<Map<String, dynamic>> buildMoveItemRequests(
  List<String> currentOrder,
  List<String> targetOrder,
) {
  if (currentOrder.length != targetOrder.length) {
    return [];
  }

  final current = List<String>.from(currentOrder);
  final requests = <Map<String, dynamic>>[];

  for (int i = 0; i < targetOrder.length; i++) {
    if (current[i] == targetOrder[i]) continue;

    final itemId = targetOrder[i];
    final fromIdx = current.indexOf(itemId);
    if (fromIdx < 0) continue;

    requests.add({
      'moveItem': {
        'originalLocation': {'index': fromIdx},
        'newLocation': {'index': i},
      },
    });

    final moved = current.removeAt(fromIdx);
    current.insert(i, moved);
  }

  return requests;
}

/// Build the desired item-id order from the updated form, using placeholders
/// for newly created items that do not yet have server-assigned ids.
List<String> buildTargetItemOrder(List<QuestionItem> updatedQuestions) {
  final targetOrder = <String>[];
  var newPlaceholderIndex = 0;

  for (final q in updatedQuestions) {
    if (q.itemId.isNotEmpty) {
      targetOrder.add(q.itemId);
    } else if (isCreateableQuestion(q)) {
      targetOrder.add('__new_$newPlaceholderIndex');
      newPlaceholderIndex++;
    }
  }

  return targetOrder;
}

class GoogleFormsService {
  static final GoogleFormsService _instance = GoogleFormsService._internal();
  factory GoogleFormsService() => _instance;
  GoogleFormsService._internal();

  final String _formsBaseUrl = 'https://forms.googleapis.com/v1/forms';
  final String _driveBaseUrl = 'https://www.googleapis.com/drive/v3/files';
  final GoogleAuthService _authService = GoogleAuthService();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Create a new Google Form
  Future<Map<String, dynamic>> createForm(FormModel form) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return {'form': null, 'error': 'No access token'};

    try {
      final bodyJson = form.toCreateJson();
      debugPrint('=== CREATE FORM REQUEST ===');
      debugPrint('URL: $_formsBaseUrl');
      debugPrint('Body: ${jsonEncode(bodyJson)}');

      final response = await http.post(
        Uri.parse(_formsBaseUrl),
        headers: _headers(token),
        body: jsonEncode(bodyJson),
      );

      debugPrint('=== CREATE FORM RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {'form': FormModel.fromJson(jsonData), 'error': null};
      } else {
        return {'form': null, 'error': 'Create failed (${response.statusCode}): ${response.body}'};
      }
    } catch (e) {
      return {'form': null, 'error': 'Create exception: $e'};
    }
  }

  /// Send batchUpdate requests to a form. Returns null on success, error string on failure.
  Future<String?> batchUpdate(String formId, List<Map<String, dynamic>> requests, {String? label}) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return 'No access token';

    try {
      final bodyJson = {
        'requests': requests,
      };

      debugPrint('=== BATCH UPDATE${label != null ? " ($label)" : ""} REQUEST ===');
      debugPrint('URL: $_formsBaseUrl/$formId:batchUpdate');
      debugPrint('Body: ${JsonEncoder.withIndent('  ').convert(bodyJson)}');

      final response = await http.post(
        Uri.parse('$_formsBaseUrl/$formId:batchUpdate'),
        headers: _headers(token),
        body: jsonEncode(bodyJson),
      );

      debugPrint('=== BATCH UPDATE${label != null ? " ($label)" : ""} RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        return null; // success
      } else {
        final errMsg = 'batchUpdate (${label ?? "?"}) error ${response.statusCode}: ${response.body}';
        return errMsg;
      }
    } catch (e) {
      final errMsg = 'batchUpdate (${label ?? "?"}) exception: $e';
      return errMsg;
    }
  }

  /// Create a full form with title, description, and questions in one flow
  /// Returns a result map with 'form' and optional 'error' keys
  Future<Map<String, dynamic>> createFullForm(FormModel form) async {
    final errors = <String>[];

    // Step 1: Create the form with title only (API restriction)
    debugPrint('\n========================================');
    debugPrint('CREATE FULL FORM: title="${form.title}", questions=${form.questions.length}');
    debugPrint('========================================');

    final createResult = await createForm(form);
    final createdForm = createResult['form'] as FormModel?;
    final createError = createResult['error'] as String?;

    if (createdForm == null) {
      return {'form': null, 'error': createError ?? 'Failed to create form'};
    }

    debugPrint('Form created with ID: ${createdForm.formId}');

    // Step 2: Update description via batchUpdate (only title can be set on create)
    if (form.description.isNotEmpty) {
      final descErr = await batchUpdate(createdForm.formId, [
        {
          'updateFormInfo': {
            'info': {'description': form.description},
            'updateMask': 'description',
          },
        },
      ], label: 'DESCRIPTION');
      if (descErr != null) {
        errors.add('Description: $descErr');
      }
    }

    // Step 3: Rename file in Google Drive (documentTitle), independent of info.title
    final driveName = form.documentTitle?.trim().isNotEmpty == true
        ? form.documentTitle!.trim()
        : form.title;
    final renameErr = await renameDriveFile(createdForm.formId, driveName);
    if (renameErr != null) {
      errors.add('Rename: $renameErr');
    }

    // Step 4: Upload any local images to Drive and get public URLs
    for (int i = 0; i < form.questions.length; i++) {
      final q = form.questions[i];
      if (q.type == QuestionType.image &&
          q.mediaUrl != null &&
          q.mediaUrl!.isNotEmpty &&
          !q.mediaUrl!.startsWith('http')) {
        debugPrint('Uploading local image for question $i: ${q.mediaUrl}');
        final publicUrl = await uploadImageToDrive(q.mediaUrl!);
        if (publicUrl != null) {
          q.mediaUrl = publicUrl;
          debugPrint('Image uploaded, URL: $publicUrl');
        } else {
          debugPrint('Failed to upload image for question $i — clearing mediaUrl so question is skipped');
          q.mediaUrl = null; // Clear so the question gets skipped below
          errors.add('Image upload failed for question ${i + 1}');
        }
      }
    }

    // Step 4b: Upload any embedded images for non-image/video questions
    for (int i = 0; i < form.questions.length; i++) {
      final q = form.questions[i];
      if (q.type != QuestionType.image &&
          q.type != QuestionType.video &&
          q.embeddedImageUrl != null &&
          q.embeddedImageUrl!.isNotEmpty &&
          !q.embeddedImageUrl!.startsWith('http')) {
        debugPrint('Uploading embedded image for question $i: ${q.embeddedImageUrl}');
        final publicUrl = await uploadImageToDrive(q.embeddedImageUrl!);
        if (publicUrl != null) {
          q.embeddedImageUrl = publicUrl;
          debugPrint('Embedded image uploaded, URL: $publicUrl');
        } else {
          debugPrint('Failed to upload embedded image for question $i — clearing');
          q.embeddedImageUrl = null;
          errors.add('Embedded image upload failed for question ${i + 1}');
        }
      }
    }

    // Step 5: Add questions (including image/video items)
    final questionRequests = <Map<String, dynamic>>[];
    int locationIndex = 0;
    for (int i = 0; i < form.questions.length; i++) {
      final q = form.questions[i];

      // Image items require a valid media URL to be sent to the API
      if (q.type == QuestionType.image) {
        if (q.mediaUrl == null || q.mediaUrl!.isEmpty) {
          debugPrint('Skipping image question $i: no image URL');
          continue;
        }
      }

      // Video items require a valid YouTube URL
      if (q.type == QuestionType.video) {
        if (q.mediaUrl == null || q.mediaUrl!.isEmpty) {
          debugPrint('Skipping video question $i: no video URL');
          continue;
        }
      }

      // Skip other question types with no text
      if (q.type != QuestionType.image &&
          q.type != QuestionType.video &&
          q.questionText.trim().isEmpty) {
        debugPrint('Skipping question $i: empty text');
        continue;
      }

      debugPrint('Adding item $i at location $locationIndex: "${q.questionText}" (type: ${q.type})');
      questionRequests.add(q.toApiJson(locationIndex));
      locationIndex++;
    }

    if (questionRequests.isNotEmpty) {
      final qErr = await batchUpdate(createdForm.formId, questionRequests, label: 'QUESTIONS');
      if (qErr != null) {
        errors.add('Questions: $qErr');
      }
    } else {
      debugPrint('No valid questions to add');
    }

    debugPrint('========================================');
    debugPrint('DONE. Errors: ${errors.isEmpty ? "none" : errors.join("; ")}');
    debugPrint('========================================\n');

    return {
      'form': createdForm,
      'error': errors.isEmpty ? null : errors.join('\n'),
    };
  }

  /// Get a single form by ID
  Future<FormModel?> getForm(String formId) async {
    final result = await getFormWithAllData(formId);
    return result['form'] as FormModel?;
  }

  /// Fetch a form and extract all data in a single API call.
  /// Returns a map with:
  /// - 'form': FormModel?
  /// - 'isPublished': bool
  /// - 'isAcceptingResponses': bool
  /// - 'shuffleQuestions': bool?
  /// - 'emailCollectionType': String?
  /// - 'linkedSheetId': String?
  Future<Map<String, dynamic>> getFormWithAllData(String formId) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) {
      return {
        'form': null,
        'isPublished': false,
        'isAcceptingResponses': false,
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$_formsBaseUrl/$formId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        final form = FormModel.fromJson(jsonData);

        // Extract publish settings from same response
        bool isPublished = false;
        bool isAcceptingResponses = false;
        final publishSettings =
            jsonData['publishSettings'] as Map<String, dynamic>?;
        if (publishSettings != null) {
          final publishState =
              publishSettings['publishState'] as Map<String, dynamic>?;
          if (publishState != null) {
            isPublished = publishState['isPublished'] as bool? ?? false;
            isAcceptingResponses =
                publishState['isAcceptingResponses'] as bool? ?? false;
          }
        }

        // Extract shuffleQuestions from same response
        bool? shuffleQuestions;
        final settingsJson = jsonData['settings'] as Map<String, dynamic>?;
        if (settingsJson != null &&
            settingsJson.containsKey('shuffleQuestions')) {
          shuffleQuestions = settingsJson['shuffleQuestions'] as bool?;
        }

        final linkedSheetUri = form.linkedSheetId;

        return {
          'form': form,
          'isPublished': isPublished,
          'isAcceptingResponses': isAcceptingResponses,
          'shuffleQuestions': shuffleQuestions,
          'linkedSheetId': linkedSheetUri,
        };
      } else {
        debugPrint('Get form error: ${response.statusCode}');
        return {
          'form': null,
          'isPublished': false,
          'isAcceptingResponses': false,
        };
      }
    } catch (e) {
      debugPrint('Get form exception: $e');
      return {
        'form': null,
        'isPublished': false,
        'isAcceptingResponses': false,
      };
    }
  }

  /// Update email collection type via REST API (supports VERIFIED vs RESPONDER_INPUT).
  /// Returns null on success, error string on failure.
  Future<String?> updateEmailCollectionType(String formId, String emailType) async {
    // Map internal values to API enum values
    final apiEmailType = switch (emailType) {
      'verified' => 'VERIFIED',
      'responder_input' => 'RESPONDER_INPUT',
      _ => 'DO_NOT_COLLECT',
    };

    return batchUpdate(formId, [
      {
        'updateSettings': {
          'settings': {
            'emailCollectionType': apiEmailType,
          },
          'updateMask': 'emailCollectionType',
        },
      },
    ], label: 'EMAIL_COLLECTION');
  }

  /// Rename a file in Google Drive (to set the document name / documentTitle).
  Future<String?> renameDriveFile(String fileId, String newName) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return 'No access token';

    try {
      final response = await http.patch(
        Uri.parse('$_driveBaseUrl/$fileId'),
        headers: _headers(token),
        body: jsonEncode({'name': newName}),
      );

      debugPrint('=== DRIVE RENAME RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        return null; // success
      } else {
        return 'Drive rename error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'Drive rename exception: $e';
    }
  }

  /// Rename only the Drive file name (documentTitle). Does not change info.title.
  Future<String?> renameDocumentTitle(String formId, String newName) async {
    return renameDriveFile(formId, newName);
  }

  /// Fetch the current Drive file name for a form (source of truth for documentTitle).
  Future<String?> getDriveFileName(String fileId) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_driveBaseUrl/$fileId?fields=name'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData['name'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('getDriveFileName exception: $e');
      return null;
    }
  }

  /// Upload an image file to Google Drive and return its public URL
  /// Returns the public URL on success, null on failure
  Future<String?> uploadImageToDrive(String localPath) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return null;

    try {
      final file = File(localPath);
      if (!await file.exists()) {
        debugPrint('Image file not found: $localPath');
        return null;
      }

      final fileName = 'form_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await file.readAsBytes();

      // Determine MIME type from extension
      final ext = localPath.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      debugPrint('=== DRIVE UPLOAD ===');
      debugPrint('File: $localPath (${fileBytes.length} bytes, $mimeType)');

      // Build a manual multipart/related request body
      // Google Drive requires multipart/related (NOT multipart/form-data)
      final boundary = 'foo_bar_baz_${DateTime.now().millisecondsSinceEpoch}';
      final metadataJson = jsonEncode({
        'name': fileName,
        'mimeType': mimeType,
      });

      // Construct multipart/related body
      final body = <int>[
        // Part 1: JSON metadata
        ...utf8.encode('--$boundary\r\n'),
        ...utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
        ...utf8.encode(metadataJson),
        ...utf8.encode('\r\n'),
        // Part 2: Binary file data
        ...utf8.encode('--$boundary\r\n'),
        ...utf8.encode('Content-Type: $mimeType\r\n\r\n'),
        ...fileBytes,
        ...utf8.encode('\r\n'),
        // Closing boundary
        ...utf8.encode('--$boundary--\r\n'),
      ];

      final response = await http.post(
        Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        body: body,
      );

      debugPrint('Upload status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Upload failed: ${response.body}');
        return null;
      }

      final jsonData = jsonDecode(response.body);
      final fileId = jsonData['id'] as String?;

      if (fileId == null) {
        debugPrint('No file ID returned');
        return null;
      }

      // Make the file publicly accessible
      final publicUrl = await _makeFilePublic(fileId);
      return publicUrl;
    } catch (e) {
      debugPrint('Drive upload exception: $e');
      return null;
    }
  }

  /// Make a Drive file publicly accessible, returns the contentUri-compatible URL
  Future<String?> _makeFilePublic(String fileId) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return null;

    try {
      // Set permissions so anyone can view the image
      final permResponse = await http.post(
        Uri.parse('$_driveBaseUrl/$fileId/permissions'),
        headers: _headers(token),
        body: jsonEncode({
          'role': 'reader',
          'type': 'anyone',
        }),
      );

      debugPrint('Permission status: ${permResponse.statusCode}');

      // Get the web content link
      final fileResponse = await http.get(
        Uri.parse('$_driveBaseUrl/$fileId?fields=webContentLink'),
        headers: _headers(token),
      );

      if (fileResponse.statusCode == 200) {
        final data = jsonDecode(fileResponse.body);
        final link = data['webContentLink'] as String?;
        debugPrint('Public URL: $link');
        return link;
      }
      return null;
    } catch (e) {
      debugPrint('Make public exception: $e');
      return null;
    }
  }

  /// Delete a form (move to trash) via Drive API.
  /// Retries up to [maxRetries] times on failure with exponential back-off.
  Future<bool> deleteForm(String formId, {int maxRetries = 3}) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      final token = await _authService.getFreshAccessToken();
      if (token == null) return false;

      try {
        // Move to trash instead of permanent delete
        final response = await http.patch(
          Uri.parse('$_driveBaseUrl/$formId'),
          headers: _headers(token),
          body: jsonEncode({'trashed': true}),
        );

        debugPrint('=== DELETE FORM RESPONSE (attempt ${attempt + 1}) ===');
        debugPrint('Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          return true;
        }

        // Don't retry on 404 — the form is already gone
        if (response.statusCode == 404) {
          debugPrint('Form $formId not found (already deleted).');
          return true;
        }

        // Retry for other errors
        if (attempt < maxRetries) {
          final delay = Duration(seconds: (attempt + 1) * 2);
          debugPrint('Delete failed (status ${response.statusCode}), retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
        }
      } catch (e) {
        debugPrint('Delete form exception (attempt ${attempt + 1}): $e');
        if (attempt < maxRetries) {
          final delay = Duration(seconds: (attempt + 1) * 2);
          await Future.delayed(delay);
        }
      }
    }
    return false;
  }

  /// Detect changes between an original form (fetched from API) and the
  /// user-edited form. Returns a FormChangeSummary describing the diff.
  FormChangeSummary detectFormChanges(
      FormModel original, FormModel updated) {
    final originalQuestions = original.questions;
    final updatedQuestions = updated.questions;

    final titleChanged = original.title != updated.title;
    final descriptionChanged = original.description != updated.description;

    // Build a map of original questions by itemId for quick lookup
    final originalById = <String, QuestionItem>{};
    for (final q in originalQuestions) {
      if (q.itemId.isNotEmpty) {
        originalById[q.itemId] = q;
      }
    }
    final updatedById = <String, QuestionItem>{};
    for (final q in updatedQuestions) {
      if (q.itemId.isNotEmpty) {
        updatedById[q.itemId] = q;
      }
    }

    // Deleted: in original but not in updated (by itemId)
    final deletedQuestions = <QuestionItem>[];
    for (final q in originalQuestions) {
      if (q.itemId.isNotEmpty && !updatedById.containsKey(q.itemId)) {
        deletedQuestions.add(q);
      }
    }

    // Added: in updated but not in original (by itemId), or itemId is empty
    final addedQuestions = <QuestionItem>[];
    for (final q in updatedQuestions) {
      if (q.itemId.isEmpty || !originalById.containsKey(q.itemId)) {
        addedQuestions.add(q);
      }
    }

    // Updated: same itemId but content changed
    final updatedItems = <QuestionItem>[];
    final typeChangedItems = <QuestionItem>[];
    for (final q in updatedQuestions) {
      if (q.itemId.isNotEmpty) {
        final orig = originalById[q.itemId];
        if (orig != null && !q.equalsDeep(orig)) {
          updatedItems.add(q);
          if (q.type != orig.type) {
            typeChangedItems.add(q);
          }
        }
      }
    }

    // Detect moved questions (same itemId, different index)
    final movedIndices = <int>[];
    for (int i = 0; i < updatedQuestions.length; i++) {
      final q = updatedQuestions[i];
      if (q.itemId.isNotEmpty) {
        final origIdx = originalQuestions.indexWhere(
            (oq) => oq.itemId == q.itemId);
        if (origIdx >= 0 && origIdx != i) {
          movedIndices.add(i);
        }
      }
    }

    // Determine breaking changes
    final breakingReasons = <String>[];

    if (deletedQuestions.isNotEmpty) {
      breakingReasons.add(
          '${deletedQuestions.length} question(s) will be deleted');
    }
    for (final q in typeChangedItems) {
      breakingReasons.add(
          'Question "${q.questionText}" type changed — existing answers may no longer match');
    }

    final hasBreakingChanges = breakingReasons.isNotEmpty;
    final breakingChangesDescription = breakingReasons.join('. ');

    return FormChangeSummary(
      titleChanged: titleChanged,
      descriptionChanged: descriptionChanged,
      addedQuestions: addedQuestions,
      deletedQuestions: deletedQuestions,
      updatedQuestions: updatedItems,
      movedQuestionIndices: movedIndices,
      hasBreakingChanges: hasBreakingChanges,
      breakingChangesDescription: breakingChangesDescription,
    );
  }

  /// Update an existing form in-place using batchUpdate.
  /// [formId] — the form to update
  /// [original] — the form as currently stored on the server
  /// [updated] — the user-edited form with desired changes
  /// Returns a result map with 'form' (updated FormModel) and optional 'error'.
  Future<Map<String, dynamic>> updateExistingForm(
      String formId, FormModel original, FormModel updated) async {
    final errors = <String>[];
    final changes = detectFormChanges(original, updated);

    debugPrint('\n========================================');
    debugPrint('UPDATE EXISTING FORM: $formId');
    debugPrint('Title changed: ${changes.titleChanged}');
    debugPrint('Description changed: ${changes.descriptionChanged}');
    debugPrint('Added: ${changes.addedQuestions.length}, '
        'Deleted: ${changes.deletedQuestions.length}, '
        'Updated: ${changes.updatedQuestions.length}, '
        'Moved: ${changes.movedQuestionIndices.length}');
    debugPrint('========================================');

    // --- Step 1: Build batchUpdate requests ---

    final requests = <Map<String, dynamic>>[];

    // 1a. Update title and/or description
    if (changes.titleChanged || changes.descriptionChanged) {
      final info = <String, dynamic>{};
      final maskParts = <String>[];
      if (changes.titleChanged) {
        info['title'] = updated.title;
        maskParts.add('title');
      }
      if (changes.descriptionChanged) {
        info['description'] = updated.description;
        maskParts.add('description');
      }
      requests.add({
        'updateFormInfo': {
          'info': info,
          'updateMask': maskParts.join(','),
        },
      });
    }

    // 1b. Upload any NEW images to Drive (only for added/updated questions
    //     that have a local file path as mediaUrl or embeddedImageUrl)
    final allChangedQuestions = <QuestionItem>[
      ...changes.addedQuestions,
      ...changes.updatedQuestions,
    ];
    for (final q in allChangedQuestions) {
      // Upload main media image if local
      if (q.type == QuestionType.image &&
          q.mediaUrl != null &&
          q.mediaUrl!.isNotEmpty &&
          !q.mediaUrl!.startsWith('http')) {
        debugPrint('Uploading local image for question: ${q.questionText}');
        final publicUrl = await uploadImageToDrive(q.mediaUrl!);
        if (publicUrl != null) {
          q.mediaUrl = publicUrl;
        } else {
          q.mediaUrl = null;
          errors.add('Image upload failed for "${q.questionText}"');
        }
      }
      // Upload embedded image if local
      if (q.embeddedImageUrl != null &&
          q.embeddedImageUrl!.isNotEmpty &&
          !q.embeddedImageUrl!.startsWith('http')) {
        debugPrint('Uploading embedded image for question: ${q.questionText}');
        final publicUrl = await uploadImageToDrive(q.embeddedImageUrl!);
        if (publicUrl != null) {
          q.embeddedImageUrl = publicUrl;
        } else {
          q.embeddedImageUrl = null;
          errors.add('Embedded image upload failed for "${q.questionText}"');
        }
      }
    }

    // 1d. Delete removed questions (from highest index to lowest to avoid offset shifting)
    //     We need the current index of each deleted question in the ORIGINAL form.
    final deleteIndices = <int>[];
    for (final dq in changes.deletedQuestions) {
      final idx = original.questions.indexWhere((oq) => oq.itemId == dq.itemId);
      if (idx >= 0) {
        deleteIndices.add(idx);
      }
    }
    // Sort descending so we delete from the end first
    deleteIndices.sort((a, b) => b.compareTo(a));
    for (final idx in deleteIndices) {
      requests.add({
        'deleteItem': {
          'location': {'index': idx},
        },
      });
      debugPrint('Delete item at index $idx');
    }

    // After deletions, the item indices shift. We need to compute the current
    // index of each surviving item in the UPDATED form order.
    // Build a mapping: for each updated question that has an itemId from the
    // original form, determine its new index after deletions.

    // 1e. Update existing items (same itemId, content changed)
    //     We use the updated form's ordering to determine the current index.
    //     After deletions have been applied, the indices correspond to the
    //     form state *after* deletions. But since batchUpdate applies all
    //     requests sequentially, we need to think carefully about order.
    //
    //     Strategy: updateItem uses the location at the time the request is
    //     processed. After deletions, the remaining items have new indices.
    //     To keep things simple, we do: delete → update → create → move.

    // Build a list of surviving original items (after deletions) to compute
    // the "post-deletion" index for each item.
    final survivingOriginal = <QuestionItem>[];
    for (final oq in original.questions) {
      if (!changes.deletedQuestions.any((dq) => dq.itemId == oq.itemId)) {
        survivingOriginal.add(oq);
      }
    }

    for (final uq in changes.updatedQuestions) {
      // Find the index of this item in survivingOriginal
      final postDelIdx =
          survivingOriginal.indexWhere((sq) => sq.itemId == uq.itemId);
      if (postDelIdx < 0) continue; // shouldn't happen

      // Find the original question to compute update mask
      final origQ = original.questions.firstWhere(
        (oq) => oq.itemId == uq.itemId,
        orElse: () => uq,
      );
      final mask = uq.computeUpdateMask(origQ);
      if (mask.isEmpty) continue;

      requests.add(uq.toUpdateItemApiJson(postDelIdx, mask));
      debugPrint('Update item "${uq.questionText}" at index $postDelIdx (mask: $mask)');
    }

    // 1f. Create new items
    //     After deletions and updates, the current item count is:
    //     survivingOriginal.length
    //     New items are appended at the end (or at specific positions).
    //     We'll add them in order starting from survivingOriginal.length.
    //     NOTE: batchUpdate createItem requests are processed sequentially,
    //     so each new item increments the total. We need to track the running
    //     index.
    int nextCreateIndex = survivingOriginal.length;
    final postMutationOrder = <String>[
      for (final q in survivingOriginal) q.itemId,
    ];
    var createdPlaceholderIndex = 0;
    for (final aq in changes.addedQuestions) {
      if (!isCreateableQuestion(aq)) continue;

      postMutationOrder.add('__new_$createdPlaceholderIndex');
      createdPlaceholderIndex++;

      // Create at the end first; ordering is fixed via moveItem below.
      requests.add(aq.toApiJson(nextCreateIndex));
      debugPrint('Create item "${aq.questionText}" at index $nextCreateIndex');
      nextCreateIndex++;
    }

    // 1g. Reorder items to match the updated form's desired order.
    final targetOrder = buildTargetItemOrder(updated.questions);
    final moveRequests =
        buildMoveItemRequests(postMutationOrder, targetOrder);
    if (moveRequests.isNotEmpty) {
      debugPrint('Applying ${moveRequests.length} moveItem request(s)');
      requests.addAll(moveRequests);
    }

    // --- Step 2: Send batchUpdate ---
    if (requests.isNotEmpty) {
      final err = await batchUpdate(formId, requests, label: 'IN-PLACE UPDATE');
      if (err != null) {
        errors.add('Batch update: $err');
      }
    } else {
      debugPrint('No changes to apply');
    }

    // --- Step 3: Fetch updated form to return ---
    FormModel? resultForm;
    if (errors.isEmpty || errors.every((e) => e.startsWith('Rename:'))) {
      resultForm = await getForm(formId);
    }

    debugPrint('========================================');
    debugPrint('DONE. Errors: ${errors.isEmpty ? "none" : errors.join("; ")}');
    debugPrint('========================================\n');

    return {
      'form': resultForm,
      'error': errors.isEmpty ? null : errors.join('\n'),
    };
  }

  /// Set the publish settings of a form using the Google Forms API.
  /// Returns null on success, error string on failure.
  Future<Map<String, dynamic>?> setPublishSettings(
    String formId, {
    required bool isPublished,
    required bool isAcceptingResponses,
  }) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return {'success': false, 'error': 'No access token'};

    try {
      final bodyJson = {
        'publishSettings': {
          'publishState': {
            'isPublished': isPublished,
            'isAcceptingResponses': isAcceptingResponses,
          },
        },
      };

      debugPrint('=== SET PUBLISH SETTINGS REQUEST ===');
      debugPrint('URL: $_formsBaseUrl/$formId:setPublishSettings');
      debugPrint('Body: ${JsonEncoder.withIndent('  ').convert(bodyJson)}');

      final response = await http.post(
        Uri.parse('$_formsBaseUrl/$formId:setPublishSettings'),
        headers: _headers(token),
        body: jsonEncode(bodyJson),
      );

      debugPrint('=== SET PUBLISH SETTINGS RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': jsonData};
      } else {
        return {
          'success': false,
          'error': 'setPublishSettings error ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'setPublishSettings exception: $e'};
    }
  }

  /// Duplicate a form via Drive API copy
  /// [name] optionally overrides the copied file name (otherwise Drive adds "Copy of" prefix)
  Future<Map<String, String>?> duplicateForm(String formId, {String? name}) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return null;

    try {
      final body = name != null ? {'name': name} : <String, dynamic>{};
      final response = await http.post(
        Uri.parse('$_driveBaseUrl/$formId/copy'),
        headers: _headers(token),
        body: jsonEncode(body),
      );

      debugPrint('=== DUPLICATE FORM RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          'id': jsonData['id'] as String? ?? '',
          'name': jsonData['name'] as String? ?? 'Untitled',
          'modifiedTime': jsonData['modifiedTime'] as String? ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('Duplicate form exception: $e');
      return null;
    }
  }

  /// List all responses for a form
  Future<List<FormResponse>> listResponses(String formId) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_formsBaseUrl/$formId/responses'),
        headers: _headers(token),
      );

      debugPrint('=== LIST RESPONSES RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final responses = jsonData['responses'] as List<dynamic>? ?? [];
        final parsed = <FormResponse>[];
        for (final r in responses) {
          if (r is! Map<String, dynamic>) continue;
          try {
            parsed.add(FormResponse.fromApiJson(r));
          } catch (e) {
            debugPrint('Skip malformed response: $e');
          }
        }
        return parsed;
      } else {
        debugPrint('List responses error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('List responses exception: $e');
      return [];
    }
  }

  /// Fetch the Drive thumbnail URL for a single file (e.g. a template form).
  /// Returns the thumbnail link string, or null on failure.
  Future<String?> getThumbnailLink(String fileId) async {
    if (fileId.isEmpty) return null;

    final token = await _authService.getFreshAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_driveBaseUrl/$fileId?fields=thumbnailLink'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData['thumbnailLink'] as String?;
      }

      debugPrint('getThumbnailLink error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('getThumbnailLink exception: $e');
      return null;
    }
  }

  /// List recent forms from Google Drive with pagination support.
  /// [orderBy] Drive API sort key (e.g. 'modifiedByMeTime desc', 'viewedByMeTime desc', 'name')
  /// [ownershipFilter] Filter by ownership: 'anyone' (default), 'me', 'not_me'
  /// [pageToken] Token for the next page of results (null for first page)
  /// [pageSize] Number of results per page (max 100, default 20)
  /// Returns a record with the list of forms and the next page token (null if no more pages).
  Future<({List<Map<String, String>> forms, String? nextPageToken})> listRecentForms({
    String orderBy = 'modifiedByMeTime desc',
    String ownershipFilter = 'anyone',
    String? pageToken,
    int pageSize = 20,
  }) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return (forms: <Map<String, String>>[], nextPageToken: null);

    try {
      var queryStr = "mimeType='application/vnd.google-apps.form' and trashed = false";
      if (ownershipFilter == 'me') {
        queryStr += " and 'me' in owners";
      } else if (ownershipFilter == 'not_me') {
        queryStr += " and not 'me' in owners";
      }
      final query = Uri.encodeQueryComponent(queryStr);
      final pageSizeParam = pageSize.clamp(1, 100);
      var url = '$_driveBaseUrl?q=$query'
          '&orderBy=${Uri.encodeQueryComponent(orderBy)}'
          '&pageSize=$pageSizeParam'
          '&fields=nextPageToken,files(id,name,modifiedTime,viewedByMeTime,thumbnailLink)';
      if (pageToken != null && pageToken.isNotEmpty) {
        url += '&pageToken=${Uri.encodeQueryComponent(pageToken)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final files = (jsonData['files'] as List<dynamic>?) ?? [];
        final forms = files.map((file) => <String, String>{
          'id': file['id'] as String? ?? '',
          'name': file['name'] as String? ?? 'Untitled',
          'modifiedTime': file['modifiedTime'] as String? ?? '',
          'lastOpenedTime': file['viewedByMeTime'] as String? ?? '',
          'thumbnailLink': file['thumbnailLink'] as String? ?? '',
        }).toList();
        final nextPageToken = jsonData['nextPageToken'] as String?;
        return (forms: forms, nextPageToken: nextPageToken);
      } else {
        debugPrint('List forms error: ${response.statusCode}');
        return (forms: <Map<String, String>>[], nextPageToken: null);
      }
    } catch (e) {
      debugPrint('List forms exception: $e');
      return (forms: <Map<String, String>>[], nextPageToken: null);
    }
  }

  final String _sheetsBaseUrl = 'https://sheets.googleapis.com/v4/spreadsheets';

  /// Create an empty Google Spreadsheet (no pre-filled data).
  /// Used for linking as a form response destination — Google will auto-populate
  /// headers and existing responses once linked via setDestination.
  ///
  /// Returns the spreadsheet ID on success, null on failure.
  Future<String?> createEmptySpreadsheet(String title) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse(_sheetsBaseUrl),
        headers: _headers(token),
        body: jsonEncode({
          'properties': {'title': title},
        }),
      );

      debugPrint('=== CREATE EMPTY SPREADSHEET RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['spreadsheetId'] as String?;
      } else {
        debugPrint('Create empty spreadsheet error: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Create empty spreadsheet exception: $e');
      return null;
    }
  }

  /// Get metadata for a Google Spreadsheet (title, URL).
  /// Uses the Drive API to get the file info.
  ///
  /// Returns a map with 'title' and 'url', or null on failure.
  Future<Map<String, String>?> getSpreadsheetInfo(
    String spreadsheetId,
  ) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_driveBaseUrl/$spreadsheetId?fields=name'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final name = jsonData['name'] as String? ?? 'Untitled Spreadsheet';
        return {
          'title': name,
          'url': 'https://docs.google.com/spreadsheets/d/$spreadsheetId/edit',
        };
      } else {
        debugPrint('Get spreadsheet info error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Get spreadsheet info exception: $e');
      return null;
    }
  }

  /// List all user permissions on a form via Drive API.
  /// Returns editors (writers) and the owner when present.
  Future<({List<FormEditor> editors, FormEditor? owner})?> listEditors(
    String formId,
  ) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) return null;

    try {
      final uri = Uri.parse(
        '$_driveBaseUrl/$formId/permissions'
        '?fields=permissions(id,emailAddress,displayName,photoLink,role,type)',
      );
      final response = await http.get(uri, headers: _headers(token));

      debugPrint('=== LIST EDITORS RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('List editors error: ${response.body}');
        return null;
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final permissions =
          (jsonData['permissions'] as List<dynamic>?) ?? <dynamic>[];

      FormEditor? owner;
      final editors = <FormEditor>[];

      for (final raw in permissions) {
        if (raw is! Map<String, dynamic>) continue;
        final permissionType = raw['type'] as String? ?? 'user';
        if (permissionType != 'user') continue;
        final permission = FormEditor.fromDrivePermission(raw);
        if (permission.email.isEmpty) continue;

        if (permission.isOwner) {
          owner = permission;
        } else if (permission.isWriter) {
          editors.add(permission);
        }
      }

      editors.sort(
        (a, b) => a.displayLabel.toLowerCase().compareTo(
              b.displayLabel.toLowerCase(),
            ),
      );

      return (editors: editors, owner: owner);
    } catch (e) {
      debugPrint('List editors exception: $e');
      return null;
    }
  }

  /// Grant writer access to a Gmail account for the given form.
  Future<({bool success, String? errorMessage})> addEditor(
    String formId,
    String email,
  ) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) {
      return (success: false, errorMessage: 'Not signed in.');
    }

    try {
      final uri = Uri.parse(
        '$_driveBaseUrl/$formId/permissions?sendNotificationEmail=true',
      );
      final response = await http.post(
        uri,
        headers: _headers(token),
        body: jsonEncode({
          'role': 'writer',
          'type': 'user',
          'emailAddress': email.trim(),
        }),
      );

      debugPrint('=== ADD EDITOR RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (success: true, errorMessage: null);
      }

      final body = response.body;
      debugPrint('Add editor error: $body');

      if (response.statusCode == 403) {
        return (
          success: false,
          errorMessage: 'You do not have permission to add editors.',
        );
      }
      if (response.statusCode == 400 &&
          body.toLowerCase().contains('already exists')) {
        return (
          success: false,
          errorMessage: 'This user already has access to this form.',
        );
      }

      return (
        success: false,
        errorMessage: 'Failed to add editor. Please check the email address.',
      );
    } catch (e) {
      debugPrint('Add editor exception: $e');
      return (
        success: false,
        errorMessage: 'Network error. Please try again.',
      );
    }
  }

  /// Remove a collaborator permission from a form.
  Future<({bool success, String? errorMessage})> removeEditor(
    String formId,
    String permissionId,
  ) async {
    final token = await _authService.getFreshAccessToken();
    if (token == null) {
      return (success: false, errorMessage: 'Not signed in.');
    }

    try {
      final response = await http.delete(
        Uri.parse('$_driveBaseUrl/$formId/permissions/$permissionId'),
        headers: _headers(token),
      );

      debugPrint('=== REMOVE EDITOR RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        return (success: true, errorMessage: null);
      }

      debugPrint('Remove editor error: ${response.body}');

      if (response.statusCode == 403) {
        return (
          success: false,
          errorMessage: 'You do not have permission to remove this editor.',
        );
      }

      return (
        success: false,
        errorMessage: 'Failed to remove editor. Please try again.',
      );
    } catch (e) {
      debugPrint('Remove editor exception: $e');
      return (
        success: false,
        errorMessage: 'Network error. Please try again.',
      );
    }
  }
}