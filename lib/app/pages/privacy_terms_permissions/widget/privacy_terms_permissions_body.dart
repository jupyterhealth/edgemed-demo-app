import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/button.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/cubits/consents_cubit/consents_cubit.dart';
import 'package:jupyter_health/app/common/widgets/styled_checkbox.dart';
import 'package:jupyter_health/app/pages/privacy_terms_permissions/widget/privacy_terms_consent_label.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/consents/consent_item.dart';
import 'package:jupyter_health/gen/assets.gen.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class PrivacyTermsPermissionsBody extends StatefulWidget {
  final List<ConsentItem> consented;
  final List<ConsentItem> pending;
  final List<ConsentItem> selected;
  final bool isSubmitting;

  const PrivacyTermsPermissionsBody({
    super.key,
    required this.consented,
    required this.pending,
    required this.selected,
    required this.isSubmitting,
  });

  @override
  State<PrivacyTermsPermissionsBody> createState() =>
      _PrivacyTermsPermissionsBodyState();
}

class _PrivacyTermsPermissionsBodyState
    extends State<PrivacyTermsPermissionsBody> {
  bool privacyPolicyConsented = true;

  @override
  Widget build(BuildContext context) {
    final hasConsents =
        widget.consented.isNotEmpty || widget.pending.isNotEmpty;
    final canSubmit =
        !widget.isSubmitting &&
        widget.pending.isNotEmpty &&
        widget.selected.length == widget.pending.length &&
        privacyPolicyConsented;

    return StyledScaffold(
      appBar: const StyledAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            T(context).permissionsAndConsent,
            style: context.typography.headerMedium,
          ),
          const SizedBox(height: 4),
          Text(
            T(context).permissionsDescription,
            style: context.typography.bodyLarge,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: context.theme.secondary,
                border: Border.all(color: context.theme.primary),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Platform.isIOS
                        ? Assets.images.png.appleHealthIcon.image(
                            width: 32,
                            height: 32,
                          )
                        : Assets.images.png.googleHealthIcon.image(
                            width: 32,
                            height: 32,
                          ),
                    const SizedBox(width: 12),
                    Text(
                      Platform.isIOS ? T(context).appleHealth : 'Google Health',
                      style: context.typography.headerSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasConsents)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final item in widget.consented)
                      StyledCheckbox(label: item.text, value: true),
                    for (final item in widget.pending)
                      StyledCheckbox(
                        label: item.text,
                        value: widget.selected.contains(item),
                        onChanged: widget.isSubmitting
                            ? null
                            : (_) => context
                                  .read<ConsentsCubit>()
                                  .togglePending(item),
                      ),
                    StyledCheckbox(
                      labelWidget: const PrivacyTermsConsentLabel(),
                      value: privacyPolicyConsented,
                      onChanged: widget.isSubmitting
                          ? null
                          : (value) =>
                                setState(() => privacyPolicyConsented = value),
                    ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),
          Button(
            text: T(context).connect,
            isLoading: widget.isSubmitting,
            onPressed: canSubmit
                ? () => context.read<ConsentsCubit>().submit()
                : null,
          ),
        ],
      ),
    );
  }
}
