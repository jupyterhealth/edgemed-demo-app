import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_progress_indicator.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StyledScaffold(
      appBar: StyledAppBar(),
      body: Center(child: StyledProgressIndicator()),
    );
  }
}
