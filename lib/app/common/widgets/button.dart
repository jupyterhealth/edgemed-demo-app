import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/styled_progress_indicator.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class Button extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final bool isLoading;
  const Button({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
          width: 24,
          height: 24,
          child: StyledProgressIndicator())
        : Text(text, style: context.typography.buttonLarge);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: context.theme.primary,
        disabledBackgroundColor: context.theme.disabled,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: isLoading ? null : onPressed,
      child: SizedBox(
        width: double.infinity,
        child: Center(child: child),
      ),
    );
  }
}
