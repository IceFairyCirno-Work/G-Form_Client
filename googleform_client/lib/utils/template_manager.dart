import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A single template entry used in the template gallery.
class TemplateData {
  final IconData icon;
  final Color iconColor;
  final String translationKey;
  final String formId;
  final String category;

  const TemplateData({
    required this.icon,
    required this.iconColor,
    required this.translationKey,
    required this.formId,
    required this.category,
  });

  bool get isComingSoon => formId.isEmpty;
}

abstract final class TemplateManager {
  static const List<({String id, String labelKey})> categoryOptions = [
    (id: 'all', labelKey: 'all'),
    (id: 'community', labelKey: 'community'),
    (id: 'education', labelKey: 'education'),
    (id: 'health', labelKey: 'health'),
    (id: 'work', labelKey: 'work'),
  ];

  static const List<TemplateData> templates = [
    // ── Community ──────────────────────────────────────
    TemplateData(
      icon: Symbols.volunteer_activism,
      iconColor: Color(0xFFD84315),
      translationKey: 'prayer_request_safety',
      formId: '1nLdAPurmoQtExaPaAIjqquHjNuGO5KdHq3yKFZalMAw',
      category: 'community',
    ),
    TemplateData(
      icon: Symbols.rate_review,
      iconColor: Color(0xFF1565C0),
      translationKey: 'workshop_evaluation',
      formId: '1GMLI7G2rAcs4bVDg7B5u1d8r9t1bjH0Fv9cp6PAwPJM',
      category: 'community',
    ),
    TemplateData(
      icon: Symbols.sports_soccer,
      iconColor: Color(0xFF2E7D32),
      translationKey: 'soccer_tryout_evaluation',
      formId: '1e3nlPe_5F9p6PFM_0cbPWdKbNElM2KpuSVxOgfdutMs',
      category: 'community',
    ),

    // ── Education ──────────────────────────────────────
    TemplateData(
      icon: Symbols.record_voice_over,
      iconColor: Color(0xFFBF360C),
      translationKey: 'oral_presentation_evaluation',
      formId: '1iA1PgJeMIUhEbFGQgFjfWiX0yfqxwX5M78XFLSX7iUc',
      category: 'education',
    ),
    TemplateData(
      icon: Symbols.groups,
      iconColor: Color(0xFF0277BD),
      translationKey: 'peer_feedback',
      formId: '1qfZelnsU_LwzaxaDInSvCU19sCcdx4-g6STMykqL29U',
      category: 'education',
    ),
    TemplateData(
      icon: Symbols.slideshow,
      iconColor: Color(0xFF795548),
      translationKey: 'presentation_feedback',
      formId: '1r6YxPpd5web8GCPsJvQATN7dC0tbxwFWDEhsyRvw954',
      category: 'education',
    ),

    // ── Health & Wellness ──────────────────────────────
    TemplateData(
      icon: Symbols.health_and_safety,
      iconColor: Color(0xFF00796B),
      translationKey: 'patient_feedback',
      formId: '1Nb_jYmEg4Z_jtI9nloq1EJ75IUgZgxgwbSSftHqTpwo',
      category: 'health',
    ),
    TemplateData(
      icon: Symbols.child_care,
      iconColor: Color(0xFFAD1457),
      translationKey: 'childcare_registration',
      formId: '1XQac58I5dzuaPKRp7mytMUiN42A0-pqRuJKzlzYFi30',
      category: 'health',
    ),
    TemplateData(
      icon: Symbols.medication,
      iconColor: Color(0xFF4527A0),
      translationKey: 'medication_order',
      formId: '1j48u0GecbhlG_5OVwFbMTNjEtC8Hu1X_XIlHHRTmomA',
      category: 'health',
    ),

    // ── Work ───────────────────────────────────────────
    TemplateData(
      icon: Symbols.diversity_3,
      iconColor: Color(0xFF00695C),
      translationKey: 'teamwork_collaboration_evaluation',
      formId: '1B4dBSNDRRdI6DIRQoXPbJNVJWlzs6ExzhxPK8nsvLus',
      category: 'work',
    ),
    TemplateData(
      icon: Symbols.school,
      iconColor: Color(0xFF9E9D24),
      translationKey: 'training_development_feedback',
      formId: '1krfh8GUuBdV6XByN2Fe_gUNAhgkwQzpXYJv3zZrW_D8',
      category: 'work',
    ),
    TemplateData(
      icon: Symbols.person_raised_hand,
      iconColor: Color(0xFF283593),
      translationKey: 'annual_employee_performance_review',
      formId: '1H4CgFY8PRVAN_CyEdH8txhDqebB5ArilqV1-v1WSPGk',
      category: 'work',
    ),
  ];

  static List<TemplateData> filtered({
    String category = 'all',
    String searchQuery = '',
  }) {
    var result = templates;
    if (category != 'all') {
      result = result.where((t) => t.category == category).toList();
    }
    return result;
  }
}
