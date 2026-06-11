// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Form';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get discard => 'Discard';

  @override
  String get continueAction => 'Continue';

  @override
  String get done => 'Done';

  @override
  String get remove => 'Remove';

  @override
  String get add => 'Add';

  @override
  String get settings => 'Settings';

  @override
  String get close => 'Close';

  @override
  String get untitled => 'Untitled';

  @override
  String get open => 'Open';

  @override
  String get change => 'Change';

  @override
  String get export => 'Export';

  @override
  String get publish => 'Publish';

  @override
  String get unlink => 'Unlink';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get rename => 'Rename';

  @override
  String get renameForm => 'Rename form';

  @override
  String get enterNewName => 'Enter new name';

  @override
  String get documentName => 'Document name';

  @override
  String get formRenamed => 'Form renamed';

  @override
  String get failedToRename => 'Failed to rename form';

  @override
  String get required => 'Required';

  @override
  String get optional => 'Optional';

  @override
  String get other => 'Other';

  @override
  String get description => 'Description';

  @override
  String get question => 'Question';

  @override
  String get columns => 'Columns';

  @override
  String get rows => 'Rows';

  @override
  String get image => 'Image';

  @override
  String get video => 'Video';

  @override
  String get owner => 'Owner';

  @override
  String get loginSubtitle => 'Create and manage forms on the go';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInFailed => 'Sign in failed. Please try again.';

  @override
  String get tabMyForms => 'My forms';

  @override
  String get tabTemplates => 'Templates';

  @override
  String get searchForms => 'Search your forms';

  @override
  String get searchTemplates => 'Search templates';

  @override
  String get recentForms => 'Recent forms';

  @override
  String get noRecentForms => 'No recent forms';

  @override
  String noFormsMatching(String query) {
    return 'No forms matching \"$query\"';
  }

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String noTemplatesMatching(String query) {
    return 'No templates matching \"$query\"';
  }

  @override
  String get tryDifferentSearchOrCategory =>
      'Try a different search term or category';

  @override
  String get thisIsTheEnd => '-This is the end-';

  @override
  String get linkCopiedToClipboard => 'Link copied to clipboard';

  @override
  String get deleteFormTitle => 'Delete form?';

  @override
  String get deleteFormContent => 'This form will be moved to trash.';

  @override
  String get formMovedToTrash => 'Form moved to trash';

  @override
  String get failedToDeleteForm => 'Failed to delete form';

  @override
  String get duplicatingForm => 'Duplicating form...';

  @override
  String get formDuplicated => 'Form duplicated!';

  @override
  String get failedToDuplicateForm => 'Failed to duplicate form';

  @override
  String get templateComingSoon => 'Template coming soon!';

  @override
  String get loadingTemplate => 'Loading template...';

  @override
  String get failedToLoadTemplate =>
      'Failed to load template. Please try again.';

  @override
  String get soon => 'Soon';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templates',
      one: '1 template',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => 'Owned by anyone';

  @override
  String get ownedByMe => 'Owned by me';

  @override
  String get notOwnedByMe => 'Not owned by me';

  @override
  String get lastModified => 'Last modified';

  @override
  String get lastOpened => 'Last opened';

  @override
  String get titleAZ => 'Title (A–Z)';

  @override
  String get copyLink => 'Copy link';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryCommunity => 'Community';

  @override
  String get categoryHealth => 'Health & Wellness';

  @override
  String get tplPrayerRequestSafety =>
      'Prayer Request for Safety and Protection';

  @override
  String get tplPrayerRequestSafetyDesc =>
      'Submit prayer requests for safety and protection';

  @override
  String get tplWorkshopEvaluation => 'Workshop Evaluation';

  @override
  String get tplWorkshopEvaluationDesc => 'Evaluate workshop effectiveness';

  @override
  String get tplSoccerTryoutEvaluation => 'Soccer Tryout Evaluation';

  @override
  String get tplSoccerTryoutEvaluationDesc =>
      'Assess soccer tryout performance';

  @override
  String get tplOralPresentationEvaluation =>
      'Oral Presentation Evaluation Form';

  @override
  String get tplOralPresentationEvaluationDesc =>
      'Evaluate oral presentation skills';

  @override
  String get tplPeerFeedback => 'Peer Feedback Form';

  @override
  String get tplPeerFeedbackDesc => 'Provide feedback to peers';

  @override
  String get tplPresentationFeedback => 'Presentation Feedback';

  @override
  String get tplPresentationFeedbackDesc => 'Give feedback on presentations';

  @override
  String get tplPatientFeedback => 'Patient Feedback Form';

  @override
  String get tplPatientFeedbackDesc => 'Collect patient feedback on care';

  @override
  String get tplChildcareRegistration => 'Childcare Registration Form';

  @override
  String get tplChildcareRegistrationDesc =>
      'Register children for childcare services';

  @override
  String get tplMedicationOrder => 'Medication Order Form';

  @override
  String get tplMedicationOrderDesc => 'Submit medication orders';

  @override
  String get tplTeamworkCollaborationEvaluation =>
      'Teamwork & Collaboration Evaluation';

  @override
  String get tplTeamworkCollaborationEvaluationDesc =>
      'Evaluate team collaboration skills';

  @override
  String get tplTrainingDevelopmentFeedback =>
      'Training & Development Feedback Form';

  @override
  String get tplTrainingDevelopmentFeedbackDesc =>
      'Provide feedback on training programs';

  @override
  String get tplAnnualEmployeePerformanceReview =>
      'Annual Employee Performance Review';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc =>
      'Review employee performance annually';

  @override
  String get useThisTemplate => 'Use this template';

  @override
  String get failedToCopyTemplate =>
      'Failed to copy template. Please try again.';

  @override
  String get untitledForm => 'Untitled form';

  @override
  String sectionTitleOf(int n, int total) {
    return 'Section $n of $total';
  }

  @override
  String get sectionTitle => 'Section title';

  @override
  String get shortAnswerText => 'Short answer text';

  @override
  String get longAnswerText => 'Long answer text';

  @override
  String get imageTitleOptional => 'Image title (optional)';

  @override
  String get videoTitle => 'Video title';

  @override
  String optionLabel(int n) {
    return 'Option $n';
  }

  @override
  String get youTubeVideo => 'YouTube video';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Google Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutContent =>
      'Are you sure you want to sign out of your account?';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get goPremiumDesc => 'Unlock all features and remove ads';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get language => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => 'Edit';

  @override
  String get tabPreview => 'Preview';

  @override
  String get tabResponses => 'Responses';

  @override
  String get tabSettings => 'Settings';

  @override
  String get qTypeMultipleChoice => 'Multiple choice';

  @override
  String get qTypeCheckboxes => 'Checkboxes';

  @override
  String get qTypeShortAnswer => 'Short answer';

  @override
  String get qTypeParagraph => 'Paragraph';

  @override
  String get qTypeDropdown => 'Dropdown';

  @override
  String get qTypeImage => 'Image';

  @override
  String get qTypeVideo => 'Video';

  @override
  String get qTypeLinearScale => 'Linear scale';

  @override
  String get qTypeMultipleChoiceGrid => 'Multiple choice grid';

  @override
  String get qTypeCheckboxGrid => 'Checkbox grid';

  @override
  String get qTypeDate => 'Date';

  @override
  String get qTypeTime => 'Time';

  @override
  String get qTypeInfo => 'Info';

  @override
  String get qTypeSection => 'Section';

  @override
  String get qTypeTitleDescription => 'Title & description';

  @override
  String get addQuestion => 'Add question';

  @override
  String get addImage => 'Add image';

  @override
  String get addVideo => 'Add video';

  @override
  String get addInfo => 'Add info';

  @override
  String get addSection => 'Add section';

  @override
  String get addYouTubeVideo => 'Add YouTube video';

  @override
  String get pasteYouTubeUrl => 'Paste YouTube URL here';

  @override
  String get clickToUploadImage => 'Click to upload image';

  @override
  String get pasteYouTubeVideoUrl => 'Paste YouTube video URL';

  @override
  String get saving => 'Saving...';

  @override
  String get formSaved => 'Form saved! Link copied to clipboard.';

  @override
  String formSavedWithWarnings(String warnings) {
    return 'Form saved! Link copied. $warnings';
  }

  @override
  String get failedToSaveForm => 'Failed to save form.';

  @override
  String get failedToLoadForm => 'Failed to load form.';

  @override
  String get saveToPreview => 'Save to preview';

  @override
  String get saveForm => 'Save form';

  @override
  String get saveTheFormFirst => 'Save the form first to get a link';

  @override
  String get saveBeforePublishing =>
      'Please save the form first before publishing.';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get unsavedChangesBackDesc =>
      'You have unsaved changes. Do you want to save before leaving?';

  @override
  String get unsavedChangesPreviewDesc =>
      'Save your form to see the latest preview of your changes.';

  @override
  String get dontSave => 'Don\'t save';

  @override
  String get untitledQuestion => 'Untitled Question';

  @override
  String get formTitle => 'Form title';

  @override
  String get formDescription => 'Form description';

  @override
  String get addOption => 'Add option';

  @override
  String columnN(int n) {
    return 'Column $n';
  }

  @override
  String rowN(int n) {
    return 'Row $n';
  }

  @override
  String get addColumn => 'Add column';

  @override
  String get addRow => 'Add row';

  @override
  String get minValue => 'Min value';

  @override
  String get maxValue => 'Max value';

  @override
  String get labelOptional => 'Label (optional)';

  @override
  String get showDescription => 'Show description';

  @override
  String get includeYear => 'Include year';

  @override
  String get duration => 'Duration';

  @override
  String get tooltipDragToReorder => 'Drag to reorder question';

  @override
  String get tooltipCopyLink => 'Copy Link';

  @override
  String get tooltipPublished => 'Published';

  @override
  String get tooltipPublish => 'Publish';

  @override
  String get tooltipSave => 'Save';

  @override
  String get tooltipDuplicate => 'Duplicate';

  @override
  String get tooltipDelete => 'Delete';

  @override
  String get tooltipMoreOptions => 'More options';

  @override
  String get tooltipAddImageToQuestion => 'Add image to question';

  @override
  String get tooltipExportXlsx => 'Export as .xlsx';

  @override
  String get tooltipExportCsv => 'Export as .csv';

  @override
  String get tooltipOpenLinkedSheet => 'Open linked Google Sheet';

  @override
  String get tooltipLinkToSheet => 'Link to Google Sheet';

  @override
  String get tooltipRemoveEditor => 'Remove editor';

  @override
  String get noPreviewAvailable => 'No preview available';

  @override
  String get noPreviewDesc =>
      'Save your form first to see a live preview of how it looks to respondents.';

  @override
  String get saveYourFormFirst => 'Save your form first';

  @override
  String get needSaveForResponses =>
      'You need to save your form before you can view responses.';

  @override
  String get noResponsesYet => 'No responses yet';

  @override
  String get noResponsesDesc =>
      'Responses will appear here once people submit your form.';

  @override
  String get shareThisForm => 'Share this form';

  @override
  String get responseSubSummary => 'Summary';

  @override
  String get responseSubQuestion => 'Question';

  @override
  String get responseSubIndividual => 'Individual';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count responses',
      one: '1 response',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => 'No answers yet.';

  @override
  String get noGridData => 'No grid data.';

  @override
  String andNMore(int n) {
    return '... and $n more';
  }

  @override
  String get noQuestionsFound => 'No questions found.';

  @override
  String get questionLabel => 'Question:';

  @override
  String questionN(int n) {
    return 'Question $n';
  }

  @override
  String get noResponses => 'No responses.';

  @override
  String responseNOfTotal(int n, int total) {
    return '$n of $total';
  }

  @override
  String submittedTime(String time) {
    return 'Submitted: $time';
  }

  @override
  String responseN(int n) {
    return 'Response $n';
  }

  @override
  String get noAnswer => 'No answer';

  @override
  String get couldNotOpenYouTube => 'Could not open YouTube.';

  @override
  String exportAs(String format) {
    return 'Export as $format';
  }

  @override
  String get enterFileName => 'Enter a file name for the export:';

  @override
  String get fileName => 'File name';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get responseId => 'Response ID';

  @override
  String get createTime => 'Create Time';

  @override
  String get lastSubmittedTime => 'Last Submitted Time';

  @override
  String get responsesSheet => 'Responses';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => 'Linked to Sheet';

  @override
  String get responsesAutoSaved =>
      'Responses are automatically saved to this spreadsheet:';

  @override
  String get linkedSpreadsheet => 'Linked Spreadsheet';

  @override
  String get tapToOpenInBrowser => 'Tap to open in browser';

  @override
  String get openSheet => 'Open Sheet';

  @override
  String get linkToGoogleSheet => 'Link to Google Sheet';

  @override
  String get linkSheetDesc =>
      'Form responses will be automatically saved to this spreadsheet. A new sheet tab will be created with all responses.';

  @override
  String get createAndLink => 'Create & Link';

  @override
  String get spreadsheetName => 'Spreadsheet name';

  @override
  String get unlinkSheetTitle => 'Unlink Sheet?';

  @override
  String get unlinkSheetDesc =>
      'New form responses will no longer be saved to this spreadsheet. Existing responses in the sheet will not be deleted.';

  @override
  String get sheetUnlinked => 'Sheet unlinked successfully.';

  @override
  String get failedToCreateSheet =>
      'Failed to create spreadsheet. Please try again.';

  @override
  String formLinkedToSheet(String name) {
    return 'Form linked to \"$name\" successfully!';
  }

  @override
  String failedToLink(String error) {
    return 'Failed to link: $error';
  }

  @override
  String failedToUnlink(String error) {
    return 'Failed to unlink: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get publishRequired => 'Publish Required';

  @override
  String get publishRequiredDesc =>
      'You need to publish this form before it can accept responses. Would you like to publish it now?';

  @override
  String get formPublished => 'Form published and now accepting responses!';

  @override
  String failedToPublish(String error) {
    return 'Failed to publish: $error';
  }

  @override
  String get formUnpublished => 'Form unpublished';

  @override
  String get formIsPublished => 'Form is published';

  @override
  String get copyFormLink => 'Copy form link';

  @override
  String get unpublishForm => 'Unpublish form';

  @override
  String get unpublishFormDesc => 'Form will stop accepting responses';

  @override
  String get settingsResponses => 'Responses';

  @override
  String get settingsPresentation => 'Presentation';

  @override
  String get settingsEditors => 'Editors';

  @override
  String get acceptResponses => 'Accept responses';

  @override
  String get acceptResponsesEnabled =>
      'People can submit responses to this form';

  @override
  String get acceptResponsesDisabled => 'This form is not accepting responses';

  @override
  String get collectEmail => 'Collect email addresses';

  @override
  String get collectEmailDesc => 'Choose how to collect responder emails';

  @override
  String get dontCollect => 'Don\'t collect';

  @override
  String get verified => 'Verified';

  @override
  String get responderInput => 'Responder input';

  @override
  String get limitToOneResponse => 'Limit to 1 response';

  @override
  String get limitToOneResponseDesc => 'Requires responders to sign in';

  @override
  String get editAfterSubmit => 'Edit after submit';

  @override
  String get editAfterSubmitDesc =>
      'Allow responders to edit their response after submission';

  @override
  String get showProgressBar => 'Show progress bar';

  @override
  String get showProgressBarDesc =>
      'Shows a progress bar at the bottom of the form';

  @override
  String get shuffleQuestionOrder => 'Shuffle question order';

  @override
  String get shuffleQuestionOrderDesc =>
      'Questions will appear in a different order for each responder';

  @override
  String get confirmationMessage => 'Confirmation message';

  @override
  String get confirmationMessageDesc => 'Message shown after form submission';

  @override
  String get enterConfirmationMessage => 'Enter confirmation message';

  @override
  String get defaultConfirmationMessage => 'Your response has been recorded.';

  @override
  String get addEditor => 'Add editor';

  @override
  String get gmailAddress => 'Gmail address';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => 'Please enter a Gmail address.';

  @override
  String get enterValidEmail => 'Please enter a valid email address.';

  @override
  String get removeEditorTitle => 'Remove editor?';

  @override
  String removeEditorDesc(String name) {
    return 'Remove $name from this form? They will no longer be able to edit it.';
  }

  @override
  String get alreadyOwner => 'You are already the owner of this form.';

  @override
  String get alreadyOwnerOther =>
      'This user is already the owner of this form.';

  @override
  String get alreadyEditor => 'This user is already an editor on this form.';

  @override
  String get failedToAddEditor => 'Failed to add editor.';

  @override
  String addedEditor(String email) {
    return 'Added $email as an editor.';
  }

  @override
  String get cannotRemoveOwner => 'The owner cannot be removed.';

  @override
  String get failedToRemoveEditor => 'Failed to remove editor.';

  @override
  String removedEditor(String name) {
    return 'Removed $name.';
  }

  @override
  String get noOwnerFound => 'No collaborators found for this form.';

  @override
  String get noEditorsYet =>
      'No editors yet. Tap +Add to invite someone by Gmail.';

  @override
  String get noEditorsOnForm => 'No editors on this form.';

  @override
  String get failedToLoadEditors => 'Failed to load editors.';

  @override
  String get saveChangesTitle => 'Save changes?';

  @override
  String breakingChangesDesc(String desc) {
    return 'This change will affect existing responses: $desc.\n\nDo you want to continue?';
  }

  @override
  String get duplicateChoicesError =>
      'You can\'t have duplicated choices in a multiple choice question.';

  @override
  String get invalidDataError =>
      'Invalid data. Please check your form and try again.';

  @override
  String get permissionDeniedError =>
      'Permission denied. Please check your Google account access.';

  @override
  String get addAtLeastOneQuestion =>
      'Please add at least one question before saving.';

  @override
  String get failedToUpdateForm => 'Failed to update form.';

  @override
  String get failedToLoadCurrentForm =>
      'Failed to load current form data. Please try again.';

  @override
  String couldNotLoadSettings(String error) {
    return 'Could not load form settings: $error';
  }

  @override
  String get linkCopiedToClipboardExclaim => 'Link copied to clipboard!';

  @override
  String get userFallback => 'User';

  @override
  String get languagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Français';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get noInternetConnectionDesc =>
      'Please check your network settings and try again.';

  @override
  String get noInternetSaveError => 'No internet connection. Cannot save form.';

  @override
  String get noInternetLoadError => 'No internet connection. Cannot load form.';

  @override
  String get retry => 'Retry';

  @override
  String get formNoLongerExists => 'This form no longer exists or was deleted.';

  @override
  String get failedToPickImage => 'Could not pick image. Please try again.';

  @override
  String get failedToShareFile => 'Could not share file.';
}
