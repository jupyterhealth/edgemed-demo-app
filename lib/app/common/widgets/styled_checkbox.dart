import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class StyledCheckbox extends StatelessWidget {
  final String? label;
  final Widget? labelWidget;
  final bool value;
  final void Function(bool value)? onChanged;
  final TextStyle? labelStyle;

  const StyledCheckbox({
    super.key,
    this.label,
    this.labelWidget,
    required this.value,
    this.onChanged,
    this.labelStyle,
  }) : assert(label != null || labelWidget != null);

  @override
  Widget build(BuildContext context) {
    final labelContent =
        labelWidget ??
        Text(label!, style: labelStyle ?? context.typography.bodyMedium);

    final tappableLabel = labelWidget != null
        ? labelContent
        : GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(!value),
            behavior: HitTestBehavior.opaque,
            child: labelContent,
          );

    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged == null
              ? null
              : (checked) => onChanged!(checked ?? false),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (!states.contains(WidgetState.selected)) {
              return context.theme.transparent;
            }
            if (states.contains(WidgetState.disabled)) {
              return context.theme.successSecondary;
            }
            return context.theme.primary;
          }),
          checkColor: onChanged == null
              ? context.theme.success
              : context.theme.black,
          side: BorderSide(color: context.theme.borderDark, width: 1.5),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 12),
        Expanded(child: tappableLabel),
      ],
    );
  }
}
