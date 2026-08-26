import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/styled_checkbox.dart';
import 'package:jupyter_health/app/common/wrappers/user_wrapper.dart';
import 'package:jupyter_health/app/cubits/consents_cubit/consents_cubit.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return UserWrapper(
      builder: (user, accessToken, refreshToken) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text('Profile', style: context.typography.headerMedium),
                  Text(
                    'Here is your current data and consents.',
                    style: context.typography.bodyLarge,
                  ),
                  SizedBox(height: 32),
                  BlocProvider.value(
                    value: context.read<ConsentsCubit>()..init(user.id),
                    child: BlocBuilder<ConsentsCubit, ConsentsState>(
                      builder: (context, state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consents',
                            style: context.typography.headerSmall,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Here are the consents you\'ve granted to UCSF EdgeMed app:',
                            style: context.typography.bodyLarge,
                          ),
                          state.maybeMap(
                            consented: (data) => Column(
                              children: [
                                for (var consent in data.consented)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: StyledCheckbox(
                                      value: true,
                                      label: consent.codingCode,
                                    ),
                                  ),
                              ],
                            ),
                            orElse: () => SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              spacing: 16,
              children: [
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://www.google.com')),
                  child: Text(
                    'Privacy Policy',
                    style: context.typography.bodyLarge.copyWith(
                      color: context.theme.textSecondary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://www.google.com')),
                  child: Text(
                    'Terms & Conditions',
                    style: context.typography.bodyLarge.copyWith(
                      color: context.theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
