import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/failure.dart';

class ErrorScreen extends StatelessWidget {
  final Failure failure;
  final void Function() onRetry;
  const ErrorScreen({super.key, required this.failure, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StyledScaffold(
      appBar: StyledAppBar(),
      body: Column(
        children: [
          Text(failure.errorMessage(context)),
          TextButton(onPressed: onRetry, child: Text(T(context).retry)),
        ],
      ),
    );
  }
}
