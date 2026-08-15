import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class Button extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const Button({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final child = Text(text, style: context.typography.buttonLarge);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: context.theme.primary,
        disabledBackgroundColor: context.theme.disabled,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        child: Center(child: child),
      ),
    );
  }
}
