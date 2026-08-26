import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'app_router.gr.dart';

@LazySingleton()
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AppStartupRoute.page, initial: true),
    AutoRoute(page: WelcomeRoute.page),
    AutoRoute(page: PrivacyTermsPermissionsRoute.page),
    AutoRoute(page: DashboardRoute.page),
    AutoRoute(page: QuestionnaireIntroRoute.page),
    AutoRoute(page: QuestionnaireRoute.page),
    AutoRoute(page: PasscodeRoute.page),
  ];
}
