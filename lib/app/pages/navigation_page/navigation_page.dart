import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_bottom_navigation_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/cubits/open_wearables/open_wearables_cubit.dart';
import 'package:jupyter_health/config/routing/app_router.gr.dart';

@RoutePage()
class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<OpenWearablesCubit>()..init(),
      child: AutoTabsRouter(
        routes: [const DashboardRoute(), const ProfileRoute()],
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);
          return StyledScaffold(
            appBar: StyledAppBar(),
            bottomNavigationBar: StyledBottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
            body: child,
          );
        },
      ),
    );
  }
}
