import 'package:flutter_test/flutter_test.dart';
import 'package:googleform_client/models/form_model.dart';
import 'package:googleform_client/models/question_model.dart';
import 'package:googleform_client/services/google_forms_service.dart';

void main() {
  group('buildMoveItemRequests', () {
    test('returns empty list when order is unchanged', () {
      final current = ['a', 'b', 'c'];
      expect(buildMoveItemRequests(current, List.from(current)), isEmpty);
    });

    test('returns empty list when lengths differ', () {
      expect(buildMoveItemRequests(['a', 'b'], ['a']), isEmpty);
    });

    test('swaps two adjacent items with one move', () {
      final requests = buildMoveItemRequests(
        ['a', 'b', 'c'],
        ['b', 'a', 'c'],
      );

      expect(requests, hasLength(1));
      expect(requests.first['moveItem'], {
        'originalLocation': {'index': 1},
        'newLocation': {'index': 0},
      });
    });

    test('moves item to first position', () {
      final requests = buildMoveItemRequests(
        ['a', 'b', 'c'],
        ['c', 'a', 'b'],
      );

      expect(requests, isNotEmpty);
      expect(requests.first['moveItem'], {
        'originalLocation': {'index': 2},
        'newLocation': {'index': 0},
      });

      var order = ['a', 'b', 'c'];
      for (final req in requests) {
        final move = req['moveItem'] as Map<String, dynamic>;
        final from =
            (move['originalLocation'] as Map)['index'] as int;
        final to = (move['newLocation'] as Map)['index'] as int;
        final item = order.removeAt(from);
        order.insert(to, item);
      }
      expect(order, ['c', 'a', 'b']);
    });

    test('moves item to last position', () {
      final requests = buildMoveItemRequests(
        ['a', 'b', 'c'],
        ['b', 'c', 'a'],
      );

      var order = ['a', 'b', 'c'];
      for (final req in requests) {
        final move = req['moveItem'] as Map<String, dynamic>;
        final from =
            (move['originalLocation'] as Map)['index'] as int;
        final to = (move['newLocation'] as Map)['index'] as int;
        final item = order.removeAt(from);
        order.insert(to, item);
      }
      expect(order, ['b', 'c', 'a']);
    });

    test('reorders after simulated delete and create placeholders', () {
      // Surviving items b, c plus new placeholders at end.
      final postMutation = ['b', 'c', '__new_0'];
      final target = ['__new_0', 'b', 'c'];

      final requests = buildMoveItemRequests(postMutation, target);

      var order = List<String>.from(postMutation);
      for (final req in requests) {
        final move = req['moveItem'] as Map<String, dynamic>;
        final from =
            (move['originalLocation'] as Map)['index'] as int;
        final to = (move['newLocation'] as Map)['index'] as int;
        final item = order.removeAt(from);
        order.insert(to, item);
      }
      expect(order, target);
    });
  });

  group('buildTargetItemOrder', () {
    test('uses item ids for existing questions and placeholders for new ones',
        () {
      final q1 = QuestionItem()..itemId = 'id1'..questionText = 'One';
      final q2 = QuestionItem()..questionText = 'Two';
      final q3 = QuestionItem()..itemId = 'id3'..questionText = 'Three';

      expect(buildTargetItemOrder([q1, q2, q3]), ['id1', '__new_0', 'id3']);
    });

    test('skips empty new questions that would not be created', () {
      final q1 = QuestionItem()..itemId = 'id1'..questionText = 'One';
      final empty = QuestionItem();

      expect(buildTargetItemOrder([q1, empty]), ['id1']);
    });
  });

  group('isCreateableQuestion', () {
    test('rejects empty text questions', () {
      expect(isCreateableQuestion(QuestionItem()), isFalse);
    });

    test('accepts questions with text', () {
      final q = QuestionItem()..questionText = 'Hello';
      expect(isCreateableQuestion(q), isTrue);
    });
  });

  group('reorder-only save pipeline', () {
    test('detectFormChanges flags reorder and move requests are generated', () {
      final service = GoogleFormsService();
      final original = FormModel(questions: [
        QuestionItem()
          ..itemId = 'a'
          ..questionText = 'A',
        QuestionItem()
          ..itemId = 'b'
          ..questionText = 'B',
        QuestionItem()
          ..itemId = 'c'
          ..questionText = 'C',
      ]);
      final updated = FormModel(questions: [
        QuestionItem()
          ..itemId = 'b'
          ..questionText = 'B',
        QuestionItem()
          ..itemId = 'a'
          ..questionText = 'A',
        QuestionItem()
          ..itemId = 'c'
          ..questionText = 'C',
      ]);

      final changes = service.detectFormChanges(original, updated);
      expect(changes.hasOrderChanges, isTrue);
      expect(changes.movedQuestionIndices, isNotEmpty);
      expect(changes.updatedQuestions, isEmpty);

      final postMutation = ['a', 'b', 'c'];
      final target = buildTargetItemOrder(updated.questions);
      final moves = buildMoveItemRequests(postMutation, target);

      expect(moves, isNotEmpty);

      var order = List<String>.from(postMutation);
      for (final req in moves) {
        final move = req['moveItem'] as Map<String, dynamic>;
        final from =
            (move['originalLocation'] as Map)['index'] as int;
        final to = (move['newLocation'] as Map)['index'] as int;
        final item = order.removeAt(from);
        order.insert(to, item);
      }
      expect(order, target);
    });
  });
}
