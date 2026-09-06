import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/loading_screen.dart';
import 'package:jupyter_health/app/common/wrappers/user_wrapper.dart';
import 'package:jupyter_health/app/cubits/consents_cubit/consents_cubit.dart';
import 'package:jupyter_health/app/cubits/open_wearables/open_wearables_cubit.dart';
import 'package:jupyter_health/app/pages/error_page/error_page.dart';
import 'package:jupyter_health/app/pages/privacy_terms_permissions/widget/privacy_terms_permissions_body.dart';
import 'package:jupyter_health/config/routing/app_router.gr.dart';

@RoutePage()
class PrivacyTermsPermissionsPage extends StatelessWidget {
  const PrivacyTermsPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UserWrapper(
      builder: (user, _, _) => BlocProvider.value(
        value: context.read<ConsentsCubit>()..init(user.id),
        child: BlocConsumer<ConsentsCubit, ConsentsState>(
          listener: (context, consentsState) {
            consentsState.mapOrNull(
              consented: (_) async {
                await context.read<OpenWearablesCubit>().init();
                if (context.mounted) {
                  context.router.replaceAll([const NavigationRoute()]);
                }
              },
            );
          },
          builder: (context, consentsState) => consentsState.maybeMap(
            orElse: () => const LoadingScreen(),
            error: (value) => ErrorPage(
              failure: value.failure,
              onRetry: (_) => context.read<ConsentsCubit>().init(user.id),
            ),
            consentsPending: (value) => PrivacyTermsPermissionsBody(
              consented: value.consented,
              pending: value.pending,
              selected: value.selected,
              isSubmitting: value.isSubmitting,
            ),
            consented: (value) => PrivacyTermsPermissionsBody(
              pending: [],
              consented: value.freshConsents,
              selected: value.freshConsents,
              isSubmitting: true,
            ),
          ),
        ),
      ),
    );
  }
}
