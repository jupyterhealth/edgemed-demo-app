import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/button.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/cubits/consents_cubit/consents_cubit.dart';
import 'package:jupyter_health/app/pages/privacy_terms_permissions/widget/consent_checkbox.dart';
import 'package:jupyter_health/domain/entity/consents/consent_item.dart';
import 'package:jupyter_health/gen/assets.gen.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class PrivacyTermsPermissionsBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasConsents = consented.isNotEmpty || pending.isNotEmpty;
    final canSubmit =
        !isSubmitting &&
        pending.isNotEmpty &&
        selected.length == pending.length;

    return StyledScaffold(
      appBar: const StyledAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Permissions & Consent', style: context.typography.headerMedium),
          const SizedBox(height: 4),
          Text(
            'One last step before you continue. Allow access to Apple Health to view your Blood Glucose.',
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
                    Assets.images.png.appleHealthIcon.image(
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 12),
                    Text('Apple Health', style: context.typography.headerSmall),
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
                    for (final item in consented)
                      ConsentCheckbox(label: item.text, value: true),
                    for (final item in pending)
                      ConsentCheckbox(
                        label: item.text,
                        value: selected.contains(item),
                        onChanged: isSubmitting
                            ? null
                            : (_) => context
                                  .read<ConsentsCubit>()
                                  .togglePending(item),
                      ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),
          Button(
            text: 'Connect',
            isLoading: isSubmitting,
            onPressed: canSubmit
                ? () => context.read<ConsentsCubit>().submit()
                : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
