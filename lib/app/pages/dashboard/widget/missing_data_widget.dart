import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/dashboard_card_widget.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/gen/assets.gen.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class MissingDataWidget extends StatelessWidget {
  const MissingDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCardWidget(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            CircleAvatar(
              backgroundColor: context.theme.backgroundSecondary,
              child: Assets.images.svg.bell.svg(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Some Charts Aren\'t Available',
                    style: context.typography.headerMedium,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Some charts are currently unavailable. You can still view and use the charts that are available. We recommend checking UCSF EdgeMed\'s permissions in Settings:',
                    style: context.typography.bodyMedium.copyWith(
                      color: context.theme.textSecondary,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: T(context).emptyDashboardStep1Prefix),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Assets.images.png.iosSettingsIcon.image(
                            width: 20,
                            height: 20,
                          ),
                        ),
                        TextSpan(text: T(context).emptyDashboardStep1Suffix),
                      ],
                    ),
                    style: context.typography.bodyLarge.copyWith(
                      color: context.theme.textSecondary,
                    ),
                  ),
                  Text(
                    T(context).emptyDashboardStep2,
                    style: context.typography.bodyLarge.copyWith(
                      color: context.theme.textSecondary,
                    ),
                  ),
                  Text(
                    T(context).emptyDashboardStep3,
                    style: context.typography.bodyLarge.copyWith(
                      color: context.theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
