part of 'questionnaire_cubit.dart';

@freezed
abstract class QuestionnaireState with _$QuestionnaireState {
  const factory QuestionnaireState({
    required int currentQuestion,
    required List<Question> questions,
  }) = _QuestionnaireState;
}
