import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/app/pages/questionnaire/data/questionnaire.dart';
import 'package:jupyter_health/domain/entity/questionnaire/question.dart';

part 'questionnaire_state.dart';
part 'questionnaire_cubit.freezed.dart';

@injectable
class QuestionnaireCubit extends Cubit<QuestionnaireState> {
  QuestionnaireCubit()
    : super(QuestionnaireState(currentQuestion: 0, questions: questionnaire));

  bool get canGoNext => state.questions[state.currentQuestion].map(
    optionalMultipleChoice: (question) {
      final selectedAnswers = question.selectedAnswers;
      return selectedAnswers == null || selectedAnswers.isNotEmpty;
    },
    optionalText: (_) => true,
  );

  void toggleMultipleChoiceNone() {
    final index = state.currentQuestion;
    final question = state.questions[index];

    question.map(
      optionalMultipleChoice: (multipleChoiceQuestion) {
        final selectedAnswers =
            multipleChoiceQuestion.selectedAnswers == null ? <String>[] : null;

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
    if (!canGoNext) {
      return;
    }

    emit(state.copyWith(currentQuestion: state.currentQuestion + 1));
  }

  void previousQuestion() {
    if (state.currentQuestion == 0) {
      return;
    }

    emit(state.copyWith(currentQuestion: state.currentQuestion - 1));
  }
}
