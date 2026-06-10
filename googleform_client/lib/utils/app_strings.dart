import 'package:flutter/material.dart';
import 'package:googleform_client/l10n/app_localizations.dart';
import '../models/question_model.dart';

/// Localization helpers for templates and question types.
class AppStrings {
  AppStrings._();

  static AppLocalizations of(BuildContext context) =>
      AppLocalizations.of(context);

  static String categoryLabel(BuildContext context, String categoryId) {
    final l10n = of(context);
    return switch (categoryId) {
      'all' => l10n.categoryAll,
      'community' => l10n.categoryCommunity,
      'education' => l10n.categoryEducation,
      'health' => l10n.categoryHealth,
      'work' => l10n.categoryWork,
      _ => categoryId,
    };
  }

  static String templateName(BuildContext context, String templateKey) {
    final l10n = of(context);
    return switch (templateKey) {
      'prayer_request_safety' => l10n.tplPrayerRequestSafety,
      'workshop_evaluation' => l10n.tplWorkshopEvaluation,
      'soccer_tryout_evaluation' => l10n.tplSoccerTryoutEvaluation,
      'oral_presentation_evaluation' => l10n.tplOralPresentationEvaluation,
      'peer_feedback' => l10n.tplPeerFeedback,
      'presentation_feedback' => l10n.tplPresentationFeedback,
      'patient_feedback' => l10n.tplPatientFeedback,
      'childcare_registration' => l10n.tplChildcareRegistration,
      'medication_order' => l10n.tplMedicationOrder,
      'teamwork_collaboration_evaluation' =>
        l10n.tplTeamworkCollaborationEvaluation,
      'training_development_feedback' => l10n.tplTrainingDevelopmentFeedback,
      'annual_employee_performance_review' =>
        l10n.tplAnnualEmployeePerformanceReview,
      _ => templateKey,
    };
  }

  static String templateDescription(BuildContext context, String templateKey) {
    final l10n = of(context);
    return switch (templateKey) {
      'prayer_request_safety' => l10n.tplPrayerRequestSafetyDesc,
      'workshop_evaluation' => l10n.tplWorkshopEvaluationDesc,
      'soccer_tryout_evaluation' => l10n.tplSoccerTryoutEvaluationDesc,
      'oral_presentation_evaluation' =>
        l10n.tplOralPresentationEvaluationDesc,
      'peer_feedback' => l10n.tplPeerFeedbackDesc,
      'presentation_feedback' => l10n.tplPresentationFeedbackDesc,
      'patient_feedback' => l10n.tplPatientFeedbackDesc,
      'childcare_registration' => l10n.tplChildcareRegistrationDesc,
      'medication_order' => l10n.tplMedicationOrderDesc,
      'teamwork_collaboration_evaluation' =>
        l10n.tplTeamworkCollaborationEvaluationDesc,
      'training_development_feedback' =>
        l10n.tplTrainingDevelopmentFeedbackDesc,
      'annual_employee_performance_review' =>
        l10n.tplAnnualEmployeePerformanceReviewDesc,
      _ => templateKey,
    };
  }

  static String questionTypeLabel(BuildContext context, QuestionType type) {
    final l10n = of(context);
    return switch (type) {
      QuestionType.multipleChoice => l10n.qTypeMultipleChoice,
      QuestionType.checkbox => l10n.qTypeCheckboxes,
      QuestionType.shortAnswer => l10n.qTypeShortAnswer,
      QuestionType.paragraph => l10n.qTypeParagraph,
      QuestionType.dropdown => l10n.qTypeDropdown,
      QuestionType.image => l10n.qTypeImage,
      QuestionType.video => l10n.qTypeVideo,
      QuestionType.linearScale => l10n.qTypeLinearScale,
      QuestionType.multipleChoiceGrid => l10n.qTypeMultipleChoiceGrid,
      QuestionType.checkboxGrid => l10n.qTypeCheckboxGrid,
      QuestionType.date => l10n.qTypeDate,
      QuestionType.time => l10n.qTypeTime,
      QuestionType.info => l10n.qTypeInfo,
      QuestionType.section => l10n.qTypeSection,
    };
  }
}
