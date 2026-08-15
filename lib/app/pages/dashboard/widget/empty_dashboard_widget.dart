import 'package:flutter/material.dart';
import 'package:jupyter_health/gen/assets.gen.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class EmptyDashboardWidget extends StatelessWidget {
  const EmptyDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Assets.images.svg.noDataImage.svg(),
        Text('Empty Dashboard', style: context.typography.headerLarge),
        SizedBox(height: 4),
        Text(
          'Add your first observation to get started',
          style: context.typography.headerSmall,
        ),
        SizedBox(height: 12),
        Text(
          'A quick check of UCSF Edge\'s permissions in Settings may help.',
          style: context.typography.bodyLarge.copyWith(
            color: context.theme.textSecondary,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: '1. Go to Settings '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Assets.images.png.iosSettingsIcon.image(
                  width: 20,
                  height: 20,
                ),
              ),
              const TextSpan(text: ' > Privacy & Security.'),
            ],
          ),
          style: context.typography.bodyLarge.copyWith(
            color: context.theme.textSecondary,
          ),
        ),
        Text(
          '2. Tap UCSF Edge app.',
          style: context.typography.bodyLarge.copyWith(
            color: context.theme.textSecondary,
          ),
        ),
        Text(
          '3. Review the app\'s permissions.',
          style: context.typography.bodyLarge.copyWith(
            color: context.theme.textSecondary,
          ),
        ),
      ],
    );
  }
}
