import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/app/pages/questionnaire/data/questionnaire.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/questionnaire/question.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';

part 'questionnaire_state.dart';
part 'questionnaire_cubit.freezed.dart';

@injectable
class QuestionnaireCubit extends Cubit<QuestionnaireState> {
  final ApiRepository _apiRepository;

  QuestionnaireCubit(this._apiRepository)
    : super(QuestionnaireState(currentQuestion: 0, questions: questionnaire));

  bool get canGoNext => state.questions[state.currentQuestion].map(
    optionalMultipleChoice: (question) {
      final selectedAnswers = question.selectedAnswers;
      return selectedAnswers == null || selectedAnswers.isNotEmpty;
    },
    optionalText: (question) {
      final answer = question.answer;
      return answer == null || answer.length <= 300;
    },
  );

  void toggleMultipleChoiceNone() {
    if (state.isSubmitting) return;

    final index = state.currentQuestion;
    final question = state.questions[index];

    question.map(
      optionalMultipleChoice: (multipleChoiceQuestion) {
        final selectedAnswers = multipleChoiceQuestion.selectedAnswers == null
            ? <String>[]
            : null;

        final updatedQuestions = [...state.questions];
        updatedQuestions[index] = multipleChoiceQuestion.copyWith(
          selectedAnswers: selectedAnswers,
        );

        emit(state.copyWith(questions: updatedQuestions));
      },
      optionalText: (_) {},
    );
  }

  void toggleMultipleChoiceAnswer(String answer) {
    if (state.isSubmitting) return;

    final index = state.currentQuestion;
    final question = state.questions[index];

    question.map(
      optionalMultipleChoice: (multipleChoiceQuestion) {
        final currentAnswers =
            multipleChoiceQuestion.selectedAnswers ?? <String>[];
        final updatedAnswers = Set<String>.from(currentAnswers);

        if (updatedAnswers.contains(answer)) {
          updatedAnswers.remove(answer);
        } else {
          updatedAnswers.add(answer);
        }

        final updatedQuestions = [...state.questions];
        updatedQuestions[index] = multipleChoiceQuestion.copyWith(
          selectedAnswers: updatedAnswers.toList(),
        );

        emit(state.copyWith(questions: updatedQuestions));
      },
      optionalText: (_) {},
    );
  }

  void updateOptionalTextAnswer(String answer) {
    if (state.isSubmitting) return;

    final index = state.currentQuestion;
    final question = state.questions[index];

    question.map(
      optionalMultipleChoice: (_) {},
      optionalText: (optionalTextQuestion) {
        final updatedQuestions = [...state.questions];
        updatedQuestions[index] = optionalTextQuestion.copyWith(
          answer: answer.isEmpty ? null : answer,
        );

        emit(state.copyWith(questions: updatedQuestions));
      },
    );
  }

  void nextQuestion() {
    if (!canGoNext || state.isSubmitting) {
      return;
    }

    emit(state.copyWith(currentQuestion: state.currentQuestion + 1));
  }

  void previousQuestion() {
    if (state.currentQuestion == 0 || state.isSubmitting) {
      return;
    }

    emit(state.copyWith(currentQuestion: state.currentQuestion - 1));
  }

  Future<void> submitAnswers(int patientId) async {
    if (!canGoNext || state.isSubmitting) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, failure: null));
    final result = await _apiRepository.submitQuestionnaire(
      patientId: patientId,
      questions: state.questions,
    );
    await result.fold(
      (failure) async =>
          emit(state.copyWith(isSubmitting: false, failure: failure)),
      (_) async => emit(state.copyWith(isSubmitting: false, submitted: true)),
    );
  }
}
