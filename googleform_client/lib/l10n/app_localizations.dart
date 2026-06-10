import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameForm.
  ///
  /// In en, this message translates to:
  /// **'Rename form'**
  String get renameForm;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get enterNewName;

  /// No description provided for @documentName.
  ///
  /// In en, this message translates to:
  /// **'Document name'**
  String get documentName;

  /// No description provided for @formRenamed.
  ///
  /// In en, this message translates to:
  /// **'Form renamed'**
  String get formRenamed;

  /// No description provided for @failedToRename.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename form'**
  String get failedToRename;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @columns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get columns;

  /// No description provided for @rows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get rows;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and manage forms on the go'**
  String get loginSubtitle;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get signInFailed;

  /// No description provided for @tabMyForms.
  ///
  /// In en, this message translates to:
  /// **'My forms'**
  String get tabMyForms;

  /// No description provided for @tabTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get tabTemplates;

  /// No description provided for @searchForms.
  ///
  /// In en, this message translates to:
  /// **'Search your forms'**
  String get searchForms;

  /// No description provided for @searchTemplates.
  ///
  /// In en, this message translates to:
  /// **'Search templates'**
  String get searchTemplates;

  /// No description provided for @recentForms.
  ///
  /// In en, this message translates to:
  /// **'Recent forms'**
  String get recentForms;

  /// No description provided for @noRecentForms.
  ///
  /// In en, this message translates to:
  /// **'No recent forms'**
  String get noRecentForms;

  /// No description provided for @noFormsMatching.
  ///
  /// In en, this message translates to:
  /// **'No forms matching \"{query}\"'**
  String noFormsMatching(String query);

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @noTemplatesMatching.
  ///
  /// In en, this message translates to:
  /// **'No templates matching \"{query}\"'**
  String noTemplatesMatching(String query);

  /// No description provided for @tryDifferentSearchOrCategory.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or category'**
  String get tryDifferentSearchOrCategory;

  /// No description provided for @thisIsTheEnd.
  ///
  /// In en, this message translates to:
  /// **'-This is the end-'**
  String get thisIsTheEnd;

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopiedToClipboard;

  /// No description provided for @deleteFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete form?'**
  String get deleteFormTitle;

  /// No description provided for @deleteFormContent.
  ///
  /// In en, this message translates to:
  /// **'This form will be moved to trash.'**
  String get deleteFormContent;

  /// No description provided for @formMovedToTrash.
  ///
  /// In en, this message translates to:
  /// **'Form moved to trash'**
  String get formMovedToTrash;

  /// No description provided for @failedToDeleteForm.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete form'**
  String get failedToDeleteForm;

  /// No description provided for @duplicatingForm.
  ///
  /// In en, this message translates to:
  /// **'Duplicating form...'**
  String get duplicatingForm;

  /// No description provided for @formDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Form duplicated!'**
  String get formDuplicated;

  /// No description provided for @failedToDuplicateForm.
  ///
  /// In en, this message translates to:
  /// **'Failed to duplicate form'**
  String get failedToDuplicateForm;

  /// No description provided for @templateComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Template coming soon!'**
  String get templateComingSoon;

  /// No description provided for @loadingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Loading template...'**
  String get loadingTemplate;

  /// No description provided for @failedToLoadTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to load template. Please try again.'**
  String get failedToLoadTemplate;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @templateCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 template} other{{count} templates}}'**
  String templateCount(int count);

  /// No description provided for @ownedByAnyone.
  ///
  /// In en, this message translates to:
  /// **'Owned by anyone'**
  String get ownedByAnyone;

  /// No description provided for @ownedByMe.
  ///
  /// In en, this message translates to:
  /// **'Owned by me'**
  String get ownedByMe;

  /// No description provided for @notOwnedByMe.
  ///
  /// In en, this message translates to:
  /// **'Not owned by me'**
  String get notOwnedByMe;

  /// No description provided for @lastModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified'**
  String get lastModified;

  /// No description provided for @lastOpened.
  ///
  /// In en, this message translates to:
  /// **'Last opened'**
  String get lastOpened;

  /// No description provided for @titleAZ.
  ///
  /// In en, this message translates to:
  /// **'Title (A–Z)'**
  String get titleAZ;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get categoryCommunity;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health & Wellness'**
  String get categoryHealth;

  /// No description provided for @tplPrayerRequestSafety.
  ///
  /// In en, this message translates to:
  /// **'Prayer Request for Safety and Protection'**
  String get tplPrayerRequestSafety;

  /// No description provided for @tplPrayerRequestSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'Submit prayer requests for safety and protection'**
  String get tplPrayerRequestSafetyDesc;

  /// No description provided for @tplWorkshopEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Workshop Evaluation'**
  String get tplWorkshopEvaluation;

  /// No description provided for @tplWorkshopEvaluationDesc.
  ///
  /// In en, this message translates to:
  /// **'Evaluate workshop effectiveness'**
  String get tplWorkshopEvaluationDesc;

  /// No description provided for @tplSoccerTryoutEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Soccer Tryout Evaluation'**
  String get tplSoccerTryoutEvaluation;

  /// No description provided for @tplSoccerTryoutEvaluationDesc.
  ///
  /// In en, this message translates to:
  /// **'Assess soccer tryout performance'**
  String get tplSoccerTryoutEvaluationDesc;

  /// No description provided for @tplOralPresentationEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Oral Presentation Evaluation Form'**
  String get tplOralPresentationEvaluation;

  /// No description provided for @tplOralPresentationEvaluationDesc.
  ///
  /// In en, this message translates to:
  /// **'Evaluate oral presentation skills'**
  String get tplOralPresentationEvaluationDesc;

  /// No description provided for @tplPeerFeedback.
  ///
  /// In en, this message translates to:
  /// **'Peer Feedback Form'**
  String get tplPeerFeedback;

  /// No description provided for @tplPeerFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Provide feedback to peers'**
  String get tplPeerFeedbackDesc;

  /// No description provided for @tplPresentationFeedback.
  ///
  /// In en, this message translates to:
  /// **'Presentation Feedback'**
  String get tplPresentationFeedback;

  /// No description provided for @tplPresentationFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Give feedback on presentations'**
  String get tplPresentationFeedbackDesc;

  /// No description provided for @tplPatientFeedback.
  ///
  /// In en, this message translates to:
  /// **'Patient Feedback Form'**
  String get tplPatientFeedback;

  /// No description provided for @tplPatientFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Collect patient feedback on care'**
  String get tplPatientFeedbackDesc;

  /// No description provided for @tplChildcareRegistration.
  ///
  /// In en, this message translates to:
  /// **'Childcare Registration Form'**
  String get tplChildcareRegistration;

  /// No description provided for @tplChildcareRegistrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Register children for childcare services'**
  String get tplChildcareRegistrationDesc;

  /// No description provided for @tplMedicationOrder.
  ///
  /// In en, this message translates to:
  /// **'Medication Order Form'**
  String get tplMedicationOrder;

  /// No description provided for @tplMedicationOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Submit medication orders'**
  String get tplMedicationOrderDesc;

  /// No description provided for @tplTeamworkCollaborationEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Teamwork & Collaboration Evaluation'**
  String get tplTeamworkCollaborationEvaluation;

  /// No description provided for @tplTeamworkCollaborationEvaluationDesc.
  ///
  /// In en, this message translates to:
  /// **'Evaluate team collaboration skills'**
  String get tplTeamworkCollaborationEvaluationDesc;

  /// No description provided for @tplTrainingDevelopmentFeedback.
  ///
  /// In en, this message translates to:
  /// **'Training & Development Feedback Form'**
  String get tplTrainingDevelopmentFeedback;

  /// No description provided for @tplTrainingDevelopmentFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Provide feedback on training programs'**
  String get tplTrainingDevelopmentFeedbackDesc;

  /// No description provided for @tplAnnualEmployeePerformanceReview.
  ///
  /// In en, this message translates to:
  /// **'Annual Employee Performance Review'**
  String get tplAnnualEmployeePerformanceReview;

  /// No description provided for @tplAnnualEmployeePerformanceReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Review employee performance annually'**
  String get tplAnnualEmployeePerformanceReviewDesc;

  /// No description provided for @useThisTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use this template'**
  String get useThisTemplate;

  /// No description provided for @failedToCopyTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy template. Please try again.'**
  String get failedToCopyTemplate;

  /// No description provided for @untitledForm.
  ///
  /// In en, this message translates to:
  /// **'Untitled form'**
  String get untitledForm;

  /// No description provided for @sectionTitleOf.
  ///
  /// In en, this message translates to:
  /// **'Section {n} of {total}'**
  String sectionTitleOf(int n, int total);

  /// No description provided for @sectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Section title'**
  String get sectionTitle;

  /// No description provided for @shortAnswerText.
  ///
  /// In en, this message translates to:
  /// **'Short answer text'**
  String get shortAnswerText;

  /// No description provided for @longAnswerText.
  ///
  /// In en, this message translates to:
  /// **'Long answer text'**
  String get longAnswerText;

  /// No description provided for @imageTitleOptional.
  ///
  /// In en, this message translates to:
  /// **'Image title (optional)'**
  String get imageTitleOptional;

  /// No description provided for @videoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video title'**
  String get videoTitle;

  /// No description provided for @optionLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {n}'**
  String optionLabel(int n);

  /// No description provided for @youTubeVideo.
  ///
  /// In en, this message translates to:
  /// **'YouTube video'**
  String get youTubeVideo;

  /// No description provided for @dateFormatWithYear.
  ///
  /// In en, this message translates to:
  /// **'MM/DD/YYYY'**
  String get dateFormatWithYear;

  /// No description provided for @dateFormatNoYear.
  ///
  /// In en, this message translates to:
  /// **'MM/DD'**
  String get dateFormatNoYear;

  /// No description provided for @timeFormatDuration.
  ///
  /// In en, this message translates to:
  /// **'HH:MM:SS'**
  String get timeFormatDuration;

  /// No description provided for @timeFormatStandard.
  ///
  /// In en, this message translates to:
  /// **'HH:MM'**
  String get timeFormatStandard;

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google Account'**
  String get googleAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get signOutContent;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @goPremiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and remove ads'**
  String get goPremiumDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageSimplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageSimplifiedChinese;

  /// No description provided for @languageTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get languageTraditionalChinese;

  /// No description provided for @tabEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tabEdit;

  /// No description provided for @tabPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get tabPreview;

  /// No description provided for @tabResponses.
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get tabResponses;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @qTypeMultipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get qTypeMultipleChoice;

  /// No description provided for @qTypeCheckboxes.
  ///
  /// In en, this message translates to:
  /// **'Checkboxes'**
  String get qTypeCheckboxes;

  /// No description provided for @qTypeShortAnswer.
  ///
  /// In en, this message translates to:
  /// **'Short answer'**
  String get qTypeShortAnswer;

  /// No description provided for @qTypeParagraph.
  ///
  /// In en, this message translates to:
  /// **'Paragraph'**
  String get qTypeParagraph;

  /// No description provided for @qTypeDropdown.
  ///
  /// In en, this message translates to:
  /// **'Dropdown'**
  String get qTypeDropdown;

  /// No description provided for @qTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get qTypeImage;

  /// No description provided for @qTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get qTypeVideo;

  /// No description provided for @qTypeLinearScale.
  ///
  /// In en, this message translates to:
  /// **'Linear scale'**
  String get qTypeLinearScale;

  /// No description provided for @qTypeMultipleChoiceGrid.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice grid'**
  String get qTypeMultipleChoiceGrid;

  /// No description provided for @qTypeCheckboxGrid.
  ///
  /// In en, this message translates to:
  /// **'Checkbox grid'**
  String get qTypeCheckboxGrid;

  /// No description provided for @qTypeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get qTypeDate;

  /// No description provided for @qTypeTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get qTypeTime;

  /// No description provided for @qTypeInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get qTypeInfo;

  /// No description provided for @qTypeSection.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get qTypeSection;

  /// No description provided for @qTypeTitleDescription.
  ///
  /// In en, this message translates to:
  /// **'Title & description'**
  String get qTypeTitleDescription;

  /// No description provided for @addQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get addQuestion;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add video'**
  String get addVideo;

  /// No description provided for @addInfo.
  ///
  /// In en, this message translates to:
  /// **'Add info'**
  String get addInfo;

  /// No description provided for @addSection.
  ///
  /// In en, this message translates to:
  /// **'Add section'**
  String get addSection;

  /// No description provided for @addYouTubeVideo.
  ///
  /// In en, this message translates to:
  /// **'Add YouTube video'**
  String get addYouTubeVideo;

  /// No description provided for @pasteYouTubeUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste YouTube URL here'**
  String get pasteYouTubeUrl;

  /// No description provided for @clickToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Click to upload image'**
  String get clickToUploadImage;

  /// No description provided for @pasteYouTubeVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste YouTube video URL'**
  String get pasteYouTubeVideoUrl;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @formSaved.
  ///
  /// In en, this message translates to:
  /// **'Form saved! Link copied to clipboard.'**
  String get formSaved;

  /// No description provided for @formSavedWithWarnings.
  ///
  /// In en, this message translates to:
  /// **'Form saved! Link copied. {warnings}'**
  String formSavedWithWarnings(String warnings);

  /// No description provided for @failedToSaveForm.
  ///
  /// In en, this message translates to:
  /// **'Failed to save form.'**
  String get failedToSaveForm;

  /// No description provided for @failedToLoadForm.
  ///
  /// In en, this message translates to:
  /// **'Failed to load form.'**
  String get failedToLoadForm;

  /// No description provided for @saveToPreview.
  ///
  /// In en, this message translates to:
  /// **'Save to preview'**
  String get saveToPreview;

  /// No description provided for @saveForm.
  ///
  /// In en, this message translates to:
  /// **'Save form'**
  String get saveForm;

  /// No description provided for @saveTheFormFirst.
  ///
  /// In en, this message translates to:
  /// **'Save the form first to get a link'**
  String get saveTheFormFirst;

  /// No description provided for @saveBeforePublishing.
  ///
  /// In en, this message translates to:
  /// **'Please save the form first before publishing.'**
  String get saveBeforePublishing;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @unsavedChangesBackDesc.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to save before leaving?'**
  String get unsavedChangesBackDesc;

  /// No description provided for @unsavedChangesPreviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Save your form to see the latest preview of your changes.'**
  String get unsavedChangesPreviewDesc;

  /// No description provided for @dontSave.
  ///
  /// In en, this message translates to:
  /// **'Don\'t save'**
  String get dontSave;

  /// No description provided for @untitledQuestion.
  ///
  /// In en, this message translates to:
  /// **'Untitled Question'**
  String get untitledQuestion;

  /// No description provided for @formTitle.
  ///
  /// In en, this message translates to:
  /// **'Form title'**
  String get formTitle;

  /// No description provided for @formDescription.
  ///
  /// In en, this message translates to:
  /// **'Form description'**
  String get formDescription;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get addOption;

  /// No description provided for @columnN.
  ///
  /// In en, this message translates to:
  /// **'Column {n}'**
  String columnN(int n);

  /// No description provided for @rowN.
  ///
  /// In en, this message translates to:
  /// **'Row {n}'**
  String rowN(int n);

  /// No description provided for @addColumn.
  ///
  /// In en, this message translates to:
  /// **'Add column'**
  String get addColumn;

  /// No description provided for @addRow.
  ///
  /// In en, this message translates to:
  /// **'Add row'**
  String get addRow;

  /// No description provided for @minValue.
  ///
  /// In en, this message translates to:
  /// **'Min value'**
  String get minValue;

  /// No description provided for @maxValue.
  ///
  /// In en, this message translates to:
  /// **'Max value'**
  String get maxValue;

  /// No description provided for @labelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get labelOptional;

  /// No description provided for @showDescription.
  ///
  /// In en, this message translates to:
  /// **'Show description'**
  String get showDescription;

  /// No description provided for @includeYear.
  ///
  /// In en, this message translates to:
  /// **'Include year'**
  String get includeYear;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @tooltipDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder question'**
  String get tooltipDragToReorder;

  /// No description provided for @tooltipCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get tooltipCopyLink;

  /// No description provided for @tooltipPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get tooltipPublished;

  /// No description provided for @tooltipPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get tooltipPublish;

  /// No description provided for @tooltipSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tooltipSave;

  /// No description provided for @tooltipDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get tooltipDuplicate;

  /// No description provided for @tooltipDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tooltipDelete;

  /// No description provided for @tooltipMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get tooltipMoreOptions;

  /// No description provided for @tooltipAddImageToQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add image to question'**
  String get tooltipAddImageToQuestion;

  /// No description provided for @tooltipExportXlsx.
  ///
  /// In en, this message translates to:
  /// **'Export as .xlsx'**
  String get tooltipExportXlsx;

  /// No description provided for @tooltipExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as .csv'**
  String get tooltipExportCsv;

  /// No description provided for @tooltipOpenLinkedSheet.
  ///
  /// In en, this message translates to:
  /// **'Open linked Google Sheet'**
  String get tooltipOpenLinkedSheet;

  /// No description provided for @tooltipLinkToSheet.
  ///
  /// In en, this message translates to:
  /// **'Link to Google Sheet'**
  String get tooltipLinkToSheet;

  /// No description provided for @tooltipRemoveEditor.
  ///
  /// In en, this message translates to:
  /// **'Remove editor'**
  String get tooltipRemoveEditor;

  /// No description provided for @noPreviewAvailable.
  ///
  /// In en, this message translates to:
  /// **'No preview available'**
  String get noPreviewAvailable;

  /// No description provided for @noPreviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Save your form first to see a live preview of how it looks to respondents.'**
  String get noPreviewDesc;

  /// No description provided for @saveYourFormFirst.
  ///
  /// In en, this message translates to:
  /// **'Save your form first'**
  String get saveYourFormFirst;

  /// No description provided for @needSaveForResponses.
  ///
  /// In en, this message translates to:
  /// **'You need to save your form before you can view responses.'**
  String get needSaveForResponses;

  /// No description provided for @noResponsesYet.
  ///
  /// In en, this message translates to:
  /// **'No responses yet'**
  String get noResponsesYet;

  /// No description provided for @noResponsesDesc.
  ///
  /// In en, this message translates to:
  /// **'Responses will appear here once people submit your form.'**
  String get noResponsesDesc;

  /// No description provided for @shareThisForm.
  ///
  /// In en, this message translates to:
  /// **'Share this form'**
  String get shareThisForm;

  /// No description provided for @responseSubSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get responseSubSummary;

  /// No description provided for @responseSubQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get responseSubQuestion;

  /// No description provided for @responseSubIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get responseSubIndividual;

  /// No description provided for @nResponses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 response} other{{count} responses}}'**
  String nResponses(int count);

  /// No description provided for @noAnswersYet.
  ///
  /// In en, this message translates to:
  /// **'No answers yet.'**
  String get noAnswersYet;

  /// No description provided for @noGridData.
  ///
  /// In en, this message translates to:
  /// **'No grid data.'**
  String get noGridData;

  /// No description provided for @andNMore.
  ///
  /// In en, this message translates to:
  /// **'... and {n} more'**
  String andNMore(int n);

  /// No description provided for @noQuestionsFound.
  ///
  /// In en, this message translates to:
  /// **'No questions found.'**
  String get noQuestionsFound;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question:'**
  String get questionLabel;

  /// No description provided for @questionN.
  ///
  /// In en, this message translates to:
  /// **'Question {n}'**
  String questionN(int n);

  /// No description provided for @noResponses.
  ///
  /// In en, this message translates to:
  /// **'No responses.'**
  String get noResponses;

  /// No description provided for @responseNOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total}'**
  String responseNOfTotal(int n, int total);

  /// No description provided for @submittedTime.
  ///
  /// In en, this message translates to:
  /// **'Submitted: {time}'**
  String submittedTime(String time);

  /// No description provided for @responseN.
  ///
  /// In en, this message translates to:
  /// **'Response {n}'**
  String responseN(int n);

  /// No description provided for @noAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get noAnswer;

  /// No description provided for @couldNotOpenYouTube.
  ///
  /// In en, this message translates to:
  /// **'Could not open YouTube.'**
  String get couldNotOpenYouTube;

  /// No description provided for @exportAs.
  ///
  /// In en, this message translates to:
  /// **'Export as {format}'**
  String exportAs(String format);

  /// No description provided for @enterFileName.
  ///
  /// In en, this message translates to:
  /// **'Enter a file name for the export:'**
  String get enterFileName;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileName;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @responseId.
  ///
  /// In en, this message translates to:
  /// **'Response ID'**
  String get responseId;

  /// No description provided for @createTime.
  ///
  /// In en, this message translates to:
  /// **'Create Time'**
  String get createTime;

  /// No description provided for @lastSubmittedTime.
  ///
  /// In en, this message translates to:
  /// **'Last Submitted Time'**
  String get lastSubmittedTime;

  /// No description provided for @responsesSheet.
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get responsesSheet;

  /// No description provided for @exportXlsx.
  ///
  /// In en, this message translates to:
  /// **'XLSX'**
  String get exportXlsx;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportCsv;

  /// No description provided for @sheets.
  ///
  /// In en, this message translates to:
  /// **'Sheets'**
  String get sheets;

  /// No description provided for @linkedToSheet.
  ///
  /// In en, this message translates to:
  /// **'Linked to Sheet'**
  String get linkedToSheet;

  /// No description provided for @responsesAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Responses are automatically saved to this spreadsheet:'**
  String get responsesAutoSaved;

  /// No description provided for @linkedSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Linked Spreadsheet'**
  String get linkedSpreadsheet;

  /// No description provided for @tapToOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Tap to open in browser'**
  String get tapToOpenInBrowser;

  /// No description provided for @openSheet.
  ///
  /// In en, this message translates to:
  /// **'Open Sheet'**
  String get openSheet;

  /// No description provided for @linkToGoogleSheet.
  ///
  /// In en, this message translates to:
  /// **'Link to Google Sheet'**
  String get linkToGoogleSheet;

  /// No description provided for @linkSheetDesc.
  ///
  /// In en, this message translates to:
  /// **'Form responses will be automatically saved to this spreadsheet. A new sheet tab will be created with all responses.'**
  String get linkSheetDesc;

  /// No description provided for @createAndLink.
  ///
  /// In en, this message translates to:
  /// **'Create & Link'**
  String get createAndLink;

  /// No description provided for @spreadsheetName.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet name'**
  String get spreadsheetName;

  /// No description provided for @unlinkSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink Sheet?'**
  String get unlinkSheetTitle;

  /// No description provided for @unlinkSheetDesc.
  ///
  /// In en, this message translates to:
  /// **'New form responses will no longer be saved to this spreadsheet. Existing responses in the sheet will not be deleted.'**
  String get unlinkSheetDesc;

  /// No description provided for @sheetUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Sheet unlinked successfully.'**
  String get sheetUnlinked;

  /// No description provided for @failedToCreateSheet.
  ///
  /// In en, this message translates to:
  /// **'Failed to create spreadsheet. Please try again.'**
  String get failedToCreateSheet;

  /// No description provided for @formLinkedToSheet.
  ///
  /// In en, this message translates to:
  /// **'Form linked to \"{name}\" successfully!'**
  String formLinkedToSheet(String name);

  /// No description provided for @failedToLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to link: {error}'**
  String failedToLink(String error);

  /// No description provided for @failedToUnlink.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink: {error}'**
  String failedToUnlink(String error);

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @publishRequired.
  ///
  /// In en, this message translates to:
  /// **'Publish Required'**
  String get publishRequired;

  /// No description provided for @publishRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'You need to publish this form before it can accept responses. Would you like to publish it now?'**
  String get publishRequiredDesc;

  /// No description provided for @formPublished.
  ///
  /// In en, this message translates to:
  /// **'Form published and now accepting responses!'**
  String get formPublished;

  /// No description provided for @failedToPublish.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish: {error}'**
  String failedToPublish(String error);

  /// No description provided for @formUnpublished.
  ///
  /// In en, this message translates to:
  /// **'Form unpublished'**
  String get formUnpublished;

  /// No description provided for @formIsPublished.
  ///
  /// In en, this message translates to:
  /// **'Form is published'**
  String get formIsPublished;

  /// No description provided for @copyFormLink.
  ///
  /// In en, this message translates to:
  /// **'Copy form link'**
  String get copyFormLink;

  /// No description provided for @unpublishForm.
  ///
  /// In en, this message translates to:
  /// **'Unpublish form'**
  String get unpublishForm;

  /// No description provided for @unpublishFormDesc.
  ///
  /// In en, this message translates to:
  /// **'Form will stop accepting responses'**
  String get unpublishFormDesc;

  /// No description provided for @settingsResponses.
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get settingsResponses;

  /// No description provided for @settingsPresentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get settingsPresentation;

  /// No description provided for @settingsEditors.
  ///
  /// In en, this message translates to:
  /// **'Editors'**
  String get settingsEditors;

  /// No description provided for @acceptResponses.
  ///
  /// In en, this message translates to:
  /// **'Accept responses'**
  String get acceptResponses;

  /// No description provided for @acceptResponsesEnabled.
  ///
  /// In en, this message translates to:
  /// **'People can submit responses to this form'**
  String get acceptResponsesEnabled;

  /// No description provided for @acceptResponsesDisabled.
  ///
  /// In en, this message translates to:
  /// **'This form is not accepting responses'**
  String get acceptResponsesDisabled;

  /// No description provided for @collectEmail.
  ///
  /// In en, this message translates to:
  /// **'Collect email addresses'**
  String get collectEmail;

  /// No description provided for @collectEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how to collect responder emails'**
  String get collectEmailDesc;

  /// No description provided for @dontCollect.
  ///
  /// In en, this message translates to:
  /// **'Don\'t collect'**
  String get dontCollect;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @responderInput.
  ///
  /// In en, this message translates to:
  /// **'Responder input'**
  String get responderInput;

  /// No description provided for @limitToOneResponse.
  ///
  /// In en, this message translates to:
  /// **'Limit to 1 response'**
  String get limitToOneResponse;

  /// No description provided for @limitToOneResponseDesc.
  ///
  /// In en, this message translates to:
  /// **'Requires responders to sign in'**
  String get limitToOneResponseDesc;

  /// No description provided for @editAfterSubmit.
  ///
  /// In en, this message translates to:
  /// **'Edit after submit'**
  String get editAfterSubmit;

  /// No description provided for @editAfterSubmitDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow responders to edit their response after submission'**
  String get editAfterSubmitDesc;

  /// No description provided for @showProgressBar.
  ///
  /// In en, this message translates to:
  /// **'Show progress bar'**
  String get showProgressBar;

  /// No description provided for @showProgressBarDesc.
  ///
  /// In en, this message translates to:
  /// **'Shows a progress bar at the bottom of the form'**
  String get showProgressBarDesc;

  /// No description provided for @shuffleQuestionOrder.
  ///
  /// In en, this message translates to:
  /// **'Shuffle question order'**
  String get shuffleQuestionOrder;

  /// No description provided for @shuffleQuestionOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Questions will appear in a different order for each responder'**
  String get shuffleQuestionOrderDesc;

  /// No description provided for @confirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirmation message'**
  String get confirmationMessage;

  /// No description provided for @confirmationMessageDesc.
  ///
  /// In en, this message translates to:
  /// **'Message shown after form submission'**
  String get confirmationMessageDesc;

  /// No description provided for @enterConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter confirmation message'**
  String get enterConfirmationMessage;

  /// No description provided for @defaultConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your response has been recorded.'**
  String get defaultConfirmationMessage;

  /// No description provided for @addEditor.
  ///
  /// In en, this message translates to:
  /// **'Add editor'**
  String get addEditor;

  /// No description provided for @gmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Gmail address'**
  String get gmailAddress;

  /// No description provided for @gmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@gmail.com'**
  String get gmailHint;

  /// No description provided for @enterGmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Gmail address.'**
  String get enterGmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @removeEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove editor?'**
  String get removeEditorTitle;

  /// No description provided for @removeEditorDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this form? They will no longer be able to edit it.'**
  String removeEditorDesc(String name);

  /// No description provided for @alreadyOwner.
  ///
  /// In en, this message translates to:
  /// **'You are already the owner of this form.'**
  String get alreadyOwner;

  /// No description provided for @alreadyOwnerOther.
  ///
  /// In en, this message translates to:
  /// **'This user is already the owner of this form.'**
  String get alreadyOwnerOther;

  /// No description provided for @alreadyEditor.
  ///
  /// In en, this message translates to:
  /// **'This user is already an editor on this form.'**
  String get alreadyEditor;

  /// No description provided for @failedToAddEditor.
  ///
  /// In en, this message translates to:
  /// **'Failed to add editor.'**
  String get failedToAddEditor;

  /// No description provided for @addedEditor.
  ///
  /// In en, this message translates to:
  /// **'Added {email} as an editor.'**
  String addedEditor(String email);

  /// No description provided for @cannotRemoveOwner.
  ///
  /// In en, this message translates to:
  /// **'The owner cannot be removed.'**
  String get cannotRemoveOwner;

  /// No description provided for @failedToRemoveEditor.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove editor.'**
  String get failedToRemoveEditor;

  /// No description provided for @removedEditor.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}.'**
  String removedEditor(String name);

  /// No description provided for @noOwnerFound.
  ///
  /// In en, this message translates to:
  /// **'No collaborators found for this form.'**
  String get noOwnerFound;

  /// No description provided for @noEditorsYet.
  ///
  /// In en, this message translates to:
  /// **'No editors yet. Tap +Add to invite someone by Gmail.'**
  String get noEditorsYet;

  /// No description provided for @noEditorsOnForm.
  ///
  /// In en, this message translates to:
  /// **'No editors on this form.'**
  String get noEditorsOnForm;

  /// No description provided for @failedToLoadEditors.
  ///
  /// In en, this message translates to:
  /// **'Failed to load editors.'**
  String get failedToLoadEditors;

  /// No description provided for @saveChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Save changes?'**
  String get saveChangesTitle;

  /// No description provided for @breakingChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'This change will affect existing responses: {desc}.\n\nDo you want to continue?'**
  String breakingChangesDesc(String desc);

  /// No description provided for @duplicateChoicesError.
  ///
  /// In en, this message translates to:
  /// **'You can\'t have duplicated choices in a multiple choice question.'**
  String get duplicateChoicesError;

  /// No description provided for @invalidDataError.
  ///
  /// In en, this message translates to:
  /// **'Invalid data. Please check your form and try again.'**
  String get invalidDataError;

  /// No description provided for @permissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please check your Google account access.'**
  String get permissionDeniedError;

  /// No description provided for @addAtLeastOneQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one question before saving.'**
  String get addAtLeastOneQuestion;

  /// No description provided for @failedToUpdateForm.
  ///
  /// In en, this message translates to:
  /// **'Failed to update form.'**
  String get failedToUpdateForm;

  /// No description provided for @failedToLoadCurrentForm.
  ///
  /// In en, this message translates to:
  /// **'Failed to load current form data. Please try again.'**
  String get failedToLoadCurrentForm;

  /// No description provided for @couldNotLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not load form settings: {error}'**
  String couldNotLoadSettings(String error);

  /// No description provided for @linkCopiedToClipboardExclaim.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard!'**
  String get linkCopiedToClipboardExclaim;

  /// No description provided for @userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
