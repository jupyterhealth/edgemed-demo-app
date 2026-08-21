import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/button.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/pages/questionnaire/cubit/questionnaire_cubit.dart';
import 'package:jupyter_health/app/pages/questionnaire/widgets/multiple_choice_widget.dart';
import 'package:jupyter_health/app/pages/questionnaire/widgets/optional_text_widget.dart';
import 'package:jupyter_health/app/pages/questionnaire/widgets/progress_indicator.dart';
import 'package:jupyter_health/app/pages/questionnaire/widgets/questionnaire_back_button.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/config/routing/app_router.gr.dart';
import 'package:jupyter_health/domain/entity/questionnaire/question.dart';

@RoutePage()
class QuestionnairePage extends StatelessWidget {
  const QuestionnairePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<QuestionnaireCubit>(),
      child: BlocBuilder<QuestionnaireCubit, QuestionnaireState>(
        builder: (context, state) {
          final cubit = context.read<QuestionnaireCubit>();
          final isLastQuestion =
              state.currentQuestion == state.questions.length - 1;

          return StyledScaffold(
            appBar: StyledAppBar(automaticallyImplyLeading: false),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                ProgressIndicator(
                  currentQuestion: state.currentQuestion + 1,
                  totalQuestions: state.questions.length,
                ),
                QuestionnaireBackButton(
                  onPressed: () {
                    if (state.currentQuestion == 0 && context.router.canPop()) {
                      context.router.pop();
                    } else {
                      context.read<QuestionnaireCubit>().previousQuestion();
                    }
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: state.currentQuestion,
                    children: state.questions
                        .map(
                          (question) => question.map(
                            optionalMultipleChoice: (value) =>
                                MultipleChoiceWidget(
                                  question: value.question,
                                  answers: value.answers,
                                  selectedAnswers: value.selectedAnswers,
                                  onAnswerToggled: (answer) => context
                                      .read<QuestionnaireCubit>()
                                      .toggleMultipleChoiceAnswer(answer),
                                  onNoneToggled: () => context
                                      .read<QuestionnaireCubit>()
                                      .toggleMultipleChoiceNone(),
                                ),
                            optionalText: (value) => OptionalTextWidget(
                              key: ValueKey(value.id),
                              question: value.question,
                              description: value.description,
                              answer: value.answer,
                              onAnswerChanged: (answer) => context
                                  .read<QuestionnaireCubit>()
                                  .updateOptionalTextAnswer(answer),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Button(
                  text: isLastQuestion ? T(context).shareAnswers : 'Next',
                  onPressed: cubit.canGoNext
                      ? () {
                          if (isLastQuestion) {
                            context.router.push(
                              const PrivacyTermsPermissionsRoute(),
                            );
                          } else {
                            cubit.nextQuestion();
                          }
                        }
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
