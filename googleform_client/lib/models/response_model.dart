class Answer {
  final String questionId;
  final List<String> textAnswers;

  Answer({
    required this.questionId,
    this.textAnswers = const [],
  });

  factory Answer.fromApiJson(String qId, Map<String, dynamic> json) {
    final answers = json['textAnswers']?['answers'] as List<dynamic>? ?? [];
    final textAnswers = answers
        .map((a) => a['value'] as String? ?? '')
        .where((v) => v.isNotEmpty)
        .toList();

    return Answer(
      questionId: qId,
      textAnswers: textAnswers,
    );
  }
}

class FormResponse {
  final String responseId;
  final String createTime;
  final String lastSubmittedTime;
  final Map<String, Answer> answers; // questionId -> Answer

  FormResponse({
    required this.responseId,
    required this.createTime,
    required this.lastSubmittedTime,
    required this.answers,
  });

  factory FormResponse.fromApiJson(Map<String, dynamic> json) {
    final answersMap = <String, Answer>{};
    final answers = json['answers'] as Map<String, dynamic>? ?? {};
    answers.forEach((key, value) {
      if (value is! Map<String, dynamic>) return;
      try {
        answersMap[key] = Answer.fromApiJson(key, value);
      } catch (_) {
        // Skip malformed answers instead of crashing the whole parse.
      }
    });

    return FormResponse(
      responseId: json['responseId'] as String? ?? '',
      createTime: json['createTime'] as String? ?? '',
      lastSubmittedTime: json['lastSubmittedTime'] as String? ?? '',
      answers: answersMap,
    );
  }

  /// Get answer text for a specific question ID
  String getAnswerForQuestion(String questionId) {
    final answer = answers[questionId];
    if (answer == null) return '';
    return answer.textAnswers.join(', ');
  }
}