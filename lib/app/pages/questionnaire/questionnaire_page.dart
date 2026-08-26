import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/button.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/common/wrappers/user_wrapper.dart';
import 'package:jupyter_health/app/pages/questionnaire/cubit/questionnaire_cubit.dart';
import 'package:jupyter_health/app/pages/questionnaire/widgets/multiple_choice_widget.dart';
import 'package:jupyter_health/app/pages/questionnaire/widgets/optional_text_widget.dart';
import 'package:jupyter_health/app/pages/questionnaire/widgets/progress_indicator.dart';
import 'package:jupyter_health/app/pages/questionnaire/widgets/questionnaire_back_button.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/config/routing/app_router.gr.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/questionnaire/question.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

@RoutePage()
class QuestionnairePage extends StatelessWidget {
  const QuestionnairePage({super.key});

  @override
  Widget build(BuildContext context) {
    return UserWrapper(
      builder: (user, _, _) => BlocProvider(
        create: (context) => getIt<QuestionnaireCubit>(),
        child: BlocConsumer<QuestionnaireCubit, QuestionnaireState>(
          listenWhen: (previous, current) =>
              !previous.submitted && current.submitted,
          listener: (context, state) {
            context.replaceRoute(const PrivacyTermsPermissionsRoute());
          },
          builder: (context, state) {
            final cubit = context.read<QuestionnaireCubit>();
            final isLastQuestion =
                state.currentQuestion == state.questions.length - 1;

            return PopScope(
              canPop: !state.isSubmitting,
              child: StyledScaffold(
                appBar: const StyledAppBar(),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    ProgressIndicator(
                      currentQuestion: state.currentQuestion + 1,
                      totalQuestions: state.questions.length,
                    ),
                    QuestionnaireBackButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              if (state.currentQuestion == 0 &&
                                  context.router.canPop()) {
                                context.router.pop();
                              } else {
                                context
                                    .read<QuestionnaireCubit>()
                                    .previousQuestion();
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
                    if (state.failure != null) ...[
                      Text(
                        state.failure!.errorMessage(context),
                        style: context.typography.bodyLarge.copyWith(
                          color: context.theme.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Button(
                      text: isLastQuestion ? T(context).shareAnswers : 'Next',
                      isLoading: state.isSubmitting,
                      onPressed: cubit.canGoNext
                          ? () {
                              if (!isLastQuestion) {
                                cubit.nextQuestion();
                                return;
                              }
                              cubit.submitAnswers(user.id);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
