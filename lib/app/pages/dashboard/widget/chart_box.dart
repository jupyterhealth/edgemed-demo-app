import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class ChartBox extends StatelessWidget {
  final Widget child;
  const ChartBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFF4F6F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x62560C33),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    );
  }
}
