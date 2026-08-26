import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class StyledBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const StyledBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: ColoredBox(
                  color: i == currentIndex
                      ? context.theme.black
                      : context.theme.border,
                  child: const SizedBox(height: 2),
                ),
              ),
          ],
        ),
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: context.theme.surface,
          selectedItemColor: context.theme.black,
          unselectedItemColor: context.theme.textSecondary,
        ),
      ],
    );
  }
}
