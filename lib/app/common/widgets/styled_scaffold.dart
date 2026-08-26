import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class StyledScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final bool scrollBody;
  final EdgeInsets? padding;
  final Widget? bottomNavigationBar;
  const StyledScaffold({
    super.key,
    this.body,
    this.appBar,
    this.scrollBody = false,
    this.padding,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 20),
      child: this.body,
    );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: context.theme.surface,
        body: SafeArea(
          child: scrollBody ? SingleChildScrollView(child: body) : body,
        ),
      ),
    );
  }
}
