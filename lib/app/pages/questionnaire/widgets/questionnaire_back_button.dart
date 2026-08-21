import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class QuestionnaireBackButton extends StatelessWidget {
  final void Function() onPressed;
  const QuestionnaireBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: IconButton(
        style: IconButton.styleFrom(backgroundColor: context.theme.secondary),
        onPressed: onPressed,
        icon: Icon(Icons.arrow_back_ios_new),
      ),
    );
  }
}
