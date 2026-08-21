import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class SleepStageRow extends StatelessWidget {
  final Color color;
  final String duration;
  final String label;
  final String percent;

  const SleepStageRow({
    super.key,
    required this.color,
    required this.duration,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: duration, style: context.typography.headerMedium),
              TextSpan(text: ' $label', style: context.typography.bodyMedium),
            ],
          ),
        ),
        const Spacer(),
        Text(
          percent,
          style: context.typography.bodyMedium.copyWith(
            color: context.theme.textTertiary,
          ),
        ),
      ],
    );
  }
}
