import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_progress_indicator.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';

class LoadingScreen extends StatelessWidget {
  final bool hideAppBar;
  const LoadingScreen({super.key, this.hideAppBar = false});

  @override
  Widget build(BuildContext context) {
    return StyledScaffold(
      appBar: hideAppBar ? null : StyledAppBar(),
      body: Center(child: StyledProgressIndicator()),
    );
  }
}
