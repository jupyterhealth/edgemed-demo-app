import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class StyledCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool value)? onChanged;
  final TextStyle? labelStyle;

  const StyledCheckbox({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AbsorbPointer(
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged == null
                  ? null
                  : (checked) => onChanged!(checked ?? false),
              activeColor: context.theme.primary,
              checkColor: context.theme.black,
              side: BorderSide(color: context.theme.borderDark, width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: labelStyle ?? context.typography.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
