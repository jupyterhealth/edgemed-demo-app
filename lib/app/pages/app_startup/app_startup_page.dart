import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/cubits/auth_cubit/auth_cubit.dart';
import 'package:jupyter_health/app/pages/app_startup/cubit/app_startup_cubit.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/routing/app_router.gr.dart';

@RoutePage()
class AppStartupPage extends StatelessWidget {
  const AppStartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AppStartupCubit>()..initialize(),
        ),
        BlocProvider.value(value: getIt<AuthCubit>()..fetchUser()),
      ],
      child: BlocConsumer<AppStartupCubit, AppStartupState>(
        listener: (context, state) {
          state.mapOrNull(
            passcodeSetupMissing: (_) {
              FlutterNativeSplash.remove();
              context.router.replace(const PasscodeRoute());
            },
            passcodeConfirmationRequired: (_) {
              FlutterNativeSplash.remove();
              context.router.replace(const PasscodeRoute());
            },
            welcomePage: (_) {
              FlutterNativeSplash.remove();
              context.router.replace(const WelcomeRoute());
            },
          );
        },
        builder: (context, state) => StyledScaffold(),
      ),
    );
  }
}
