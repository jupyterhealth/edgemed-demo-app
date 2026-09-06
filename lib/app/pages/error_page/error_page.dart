import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/button.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

@RoutePage()
class ErrorPage extends StatelessWidget {
  final Failure failure;
  final void Function(BuildContext ctx) onRetry;
  final bool hideAppBar;
  const ErrorPage({
    super.key,
    required this.failure,
    required this.onRetry,
    this.hideAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return StyledScaffold(
      appBar: hideAppBar ? null : StyledAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Oops!', style: context.typography.headerLarge),
                  SizedBox(height: 8),
                  Text(
                    'Something went wrong',
                    style: context.typography.headerSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Button(
                onPressed: () => onRetry(context),
                text: T(context).retry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
