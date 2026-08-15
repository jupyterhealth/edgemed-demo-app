import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/cubits/auth_cubit/auth_cubit.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/routing/app_router.gr.dart';

@RoutePage()
class AppStartupPage extends StatelessWidget {
  const AppStartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthCubit>()..fetchUser(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            authenticated: (user) {
              context.router.replace(const WelcomeRoute());
            },
            unauthenticated: () {
              print('unauthenticated');
            },
          );
        },
        builder: (context, state) => Placeholder(),
      ),
    );
  }
}
