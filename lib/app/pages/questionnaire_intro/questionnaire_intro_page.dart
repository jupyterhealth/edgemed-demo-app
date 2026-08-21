import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/button.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/config/routing/app_router.gr.dart';
import 'package:jupyter_health/gen/assets.gen.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

@RoutePage()
class QuestionnaireIntroPage extends StatelessWidget {
  const QuestionnaireIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StyledScaffold(
      appBar: StyledAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Assets.images.svg.questionnaireIntro.svg(),
                Column(
                  spacing: 4,
                  children: [
                    Text(T(context).welcome, style: context.typography.headerMedium),
                    Text(
                      T(context).questionnaireIntroDescription,
                      style: context.typography.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Button(
            text: T(context).startQuestionnaire,
            onPressed: () => context.pushRoute(QuestionnaireRoute()),
          ),
        ],
      ),
    );
  }
}
