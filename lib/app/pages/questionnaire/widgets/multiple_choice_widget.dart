import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/styled_checkbox.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class MultipleChoiceWidget extends StatelessWidget {
  final String question;
  final List<String> answers;
  final List<String>? selectedAnswers;
  final void Function(String answer) onAnswerToggled;
  final VoidCallback onNoneToggled;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.answers,
    required this.selectedAnswers,
    required this.onAnswerToggled,
    required this.onNoneToggled,
  });

  @override
  Widget build(BuildContext context) {
    final noneLabel = T(context).none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: context.typography.headerMedium),
        const SizedBox(height: 4),
        Text(
          'Please check any that are true:',
          style: context.typography.bodyLarge,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...answers.map(
                  (answer) => StyledCheckbox(
                    label: answer,
                    labelStyle: context.typography.bodyLarge,
                    value: selectedAnswers?.contains(answer) ?? false,
                    onChanged: (_) => onAnswerToggled(answer),
                  ),
                ),
                StyledCheckbox(
                  label: noneLabel,
                  labelStyle: context.typography.bodyLarge,
                  value: selectedAnswers == null,
                  onChanged: (_) => onNoneToggled(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
