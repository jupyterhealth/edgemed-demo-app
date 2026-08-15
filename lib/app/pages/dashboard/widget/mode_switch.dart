import 'package:flutter/material.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class ModeSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ModeSwitch({super.key, required this.value, this.onChanged});

  static const _animationDuration = Duration(milliseconds: 220);
  static const _animationCurve = Curves.easeInOut;
  static const _inset = 2.0;
  static const _radius = 10.0;
  static const _labelVerticalPadding = 5.0;
  static const _labelHorizontalPadding = 12.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme;

    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_inset),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedAlign(
                duration: _animationDuration,
                curve: _animationCurve,
                alignment: value ? Alignment.centerLeft : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: BorderRadius.circular(_radius - _inset),
                      boxShadow: [
                        BoxShadow(
                          color: colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onChanged == null ? null : () => onChanged!(true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: _labelVerticalPadding,
                        horizontal: _labelHorizontalPadding,
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: _animationDuration,
                          curve: _animationCurve,
                          style: context.typography.bodyMedium.copyWith(
                            color: value ? colors.black : colors.textSecondary,
                          ),
                          child: Text(T(context).hourly),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onChanged == null ? null : () => onChanged!(false),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: _labelVerticalPadding,
                        horizontal: _labelHorizontalPadding,
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: _animationDuration,
                          curve: _animationCurve,
                          style: context.typography.bodyMedium.copyWith(
                            color: value ? colors.textSecondary : colors.black,
                          ),
                          child: Text(T(context).daily),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
