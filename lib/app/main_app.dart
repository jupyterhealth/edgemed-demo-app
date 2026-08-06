import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/cubits/auth_cubit/auth_cubit.dart';
import 'package:jupyter_health/app/cubits/locale_cubit/locale_cubit.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/config/routing/app_router.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<LocaleCubit>()..init()),
        BlocProvider(create: (context) => getIt<AuthCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: FocusScope.of(context).unfocus,
          child: MaterialApp.router(
            localizationsDelegates: L10n.localizationDelegates,
            supportedLocales: L10n.supported,
            locale: localeState.locale,
            // theme: AppTheme.light().toThemeData(),
            routerConfig: router.config(
              navigatorObservers: () => [AutoRouteObserver()],
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}
