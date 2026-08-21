import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';

@freezed
abstract class Question with _$Question {
  const factory Question.optionalMultipleChoice({
    required String id,
    required String question,
    required List<String> answers,
    @Default([]) List<String>? selectedAnswers,
  }) = _MultipleChoice;
  const factory Question.optionalText({
    required String id,
    required String question,
    required String description,
    String? answer,
  }) = _OptionalText;
}
