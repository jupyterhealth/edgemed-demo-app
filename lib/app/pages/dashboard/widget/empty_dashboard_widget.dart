import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/gen/assets.gen.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class EmptyDashboardWidget extends StatelessWidget {
  const EmptyDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stepStyle = context.typography.bodyLarge.copyWith(
      color: context.theme.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Assets.images.svg.noDataImage.svg()),
          Text(
            T(context).emptyDashboard,
            style: context.typography.headerLarge,
          ),
          SizedBox(height: 4),
          Text(
            T(context).addFirstObservation,
            style: context.typography.headerSmall,
          ),
          SizedBox(height: 12),
          Text(
            T(context).emptyDashboardPermissionsHint,
            style: stepStyle,
          ),
          if (Platform.isAndroid) ...[
            Text(
              T(context).emptyDashboardStep1Android,
              style: stepStyle,
            ),
            Text(
              T(context).emptyDashboardStep2Android,
              style: stepStyle,
            ),
          ] else ...[
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
              style: stepStyle,
            ),
            Text(
              T(context).emptyDashboardStep2,
              style: stepStyle,
            ),
            Text(
              T(context).emptyDashboardStep3,
              style: stepStyle,
            ),
          ],
        ],
      ),
    );
  }
}
