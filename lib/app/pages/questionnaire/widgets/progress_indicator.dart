import 'package:flutter/widgets.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class ProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  const ProgressIndicator({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 11,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: context.theme.secondary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 11,
              width: constraints.maxWidth * (currentQuestion / totalQuestions),
              decoration: BoxDecoration(
                color: context.theme.loading,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        );
      },
    );
  }
}
