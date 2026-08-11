import 'package:flutter/material.dart';
import 'package:jupyter_health/config/theme/theme_extensions.dart';

class ModeSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ModeSwitch({super.key, required this.value, this.onChanged});

  static const _animationDuration = Duration(milliseconds: 220);
  static const _animationCurve = Curves.easeInOut;
  static const _inset = 4.0;
  static const _radius = 10.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final selectedStyle = typography.captionSemiBold.copyWith(
      color: colors.primaryBeige800,
    );
    final unselectedStyle = typography.captionMedium.copyWith(
      color: colors.systemGrey400,
    );

    return Container(
      width: 133,
      decoration: BoxDecoration(
        color: Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_inset),
        child: SizedBox(
          height: 36,
          child: Stack(
            children: [
              AnimatedAlign(
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onChanged == null ? null : () => onChanged!(true),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: _animationDuration,
                          curve: _animationCurve,
                          style: value ? selectedStyle : unselectedStyle,
                          child: const Text('Hourly'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onChanged == null ? null : () => onChanged!(false),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: _animationDuration,
                          curve: _animationCurve,
                          style: value ? unselectedStyle : selectedStyle,
                          child: const Text('Daily'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
