import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/styled_checkbox.dart';
import 'package:jupyter_health/app/common/widgets/styled_text_field.dart';
import 'package:jupyter_health/app/common/wrappers/user_wrapper.dart';
import 'package:jupyter_health/app/cubits/consents_cubit/consents_cubit.dart';
import 'package:jupyter_health/app/pages/privacy_terms_permissions/widget/privacy_terms_consent_label.dart';
import 'package:jupyter_health/app/pages/profile/cubit/profile_cubit.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/env/env.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _passcodeController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserWrapper(
      builder: (user, accessToken, refreshToken) => BlocProvider(
        create: (context) => getIt<ProfileCubit>()..init(),
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            _passcodeController.text = state.passcode;
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Your Profile',
                            style: context.typography.headerMedium,
                          ),
                          Text(
                            'Here is your current data and consents.',
                            style: context.typography.bodyLarge,
                          ),
                          SizedBox(height: 32),
                          Text(
                            'Passcode',
                            style: context.typography.headerSmall,
                          ),
                          SizedBox(height: 12),
                          StyledTextField(
                            controller: _passcodeController,
                            obscureText: _obscureText,
                            readOnly: true,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscureText = !_obscureText),
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: context.theme.textSecondary,
                              ),
                            ),
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
                                        for (var consent
                                            in data.freshConsents +
                                                data.oldConsents)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: StyledCheckbox(
                                              value: true,
                                              label: consent.text,
                                            ),
                                          ),
                                      ],
                                    ),
                                    orElse: () => SizedBox(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: StyledCheckbox(
                                      value: true,
                                      labelWidget:
                                          const PrivacyTermsConsentLabel(),
                                    ),
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
                          onTap: () =>
                              launchUrl(Uri.parse(Env.privacyPolicyUrl)),
                          child: Text(
                            'Privacy Policy',
                            style: context.typography.bodyLarge.copyWith(
                              color: context.theme.textSecondary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              launchUrl(Uri.parse(Env.termsAndConditionsUrl)),
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
          },
        ),
      ),
    );
  }
}
