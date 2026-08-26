import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/button.dart';
import 'package:jupyter_health/app/common/widgets/loading_screen.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/common/widgets/styled_text_field.dart';
import 'package:jupyter_health/app/pages/passcode/cubit/passcode_cubit.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/config/routing/app_router.gr.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

@RoutePage()
class PasscodePage extends StatefulWidget {
  const PasscodePage({super.key});

  @override
  State<PasscodePage> createState() => _PasscodePageState();
}

class _PasscodePageState extends State<PasscodePage> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PasscodeCubit>()..init(),
      child: BlocConsumer<PasscodeCubit, PasscodeState>(
        listenWhen: (previous, current) =>
            previous.nextRoute == null && current.nextRoute != null,
        listener: (context, state) {
          final route = switch (state.nextRoute!) {
            PasscodeNextRoute.questionnaire => const QuestionnaireIntroRoute(),
            PasscodeNextRoute.consents => const PrivacyTermsPermissionsRoute(),
            PasscodeNextRoute.dashboard => const DashboardRoute(),
          };
          context.router.replace(route);
        },
        builder: (context, state) {
          final flow = state.flow;
          if (flow == null) return const LoadingScreen();

          final cubit = context.read<PasscodeCubit>();
          final l10n = T(context);
          final (title, description, buttonText) = switch (flow) {
            PasscodeFlow.setup => (
              l10n.setPasscode,
              l10n.setPasscodeDescription,
              l10n.save,
            ),
            PasscodeFlow.unlock => (
              l10n.enterPasscode,
              l10n.enterPasscodeDescription,
              l10n.unlock,
            ),
          };

          return StyledScaffold(
            appBar: const StyledAppBar(),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(title, style: context.typography.headerMedium),
                        const SizedBox(height: 4),
                        Text(description, style: context.typography.bodyLarge),
                        const SizedBox(height: 16),
                        StyledTextField(
                          hintText: l10n.passcodeHint,
                          keyboardType: TextInputType.number,
                          obscureText: _obscureText,
                          maxLength: 6,
                          suffixIcon: GestureDetector(
                            onTap: () =>
                                setState(() => _obscureText = !_obscureText),
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: context.theme.textSecondary,
                            ),
                          ),

                          errorText: state.hasError
                              ? l10n.incorrectPasscode
                              : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: cubit.updatePasscode,
                        ),
                      ],
                    ),
                  ),
                ),
                Button(
                  text: buttonText,
                  isLoading: state.isSubmitting,
                  onPressed: cubit.canSubmit ? cubit.submit : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
