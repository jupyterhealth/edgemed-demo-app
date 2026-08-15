import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/button.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/gen/assets.gen.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledScaffold(
      appBar: StyledAppBar(),
      padding: EdgeInsets.zero,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Assets.images.svg.welcomeImage.svg(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 49),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Assets.images.svg.logo.svg(),
                ),
                SizedBox(height: 4),
                Text(
                  'Your continuous  health  monitoring app',
                  style: context.typography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Button(text: 'Get Started', onPressed: () {}),
          ),
        ],
      ),
    );
  }
}
