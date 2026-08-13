import 'package:flutter/material.dart';
import 'package:jupyter_health/gen/assets.gen.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class StyledAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StyledAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Assets.images.svg.logo.svg(),
      backgroundColor: context.theme.primary,
      centerTitle: false,
      notificationPredicate: (_) => false,
    );
  }
}
