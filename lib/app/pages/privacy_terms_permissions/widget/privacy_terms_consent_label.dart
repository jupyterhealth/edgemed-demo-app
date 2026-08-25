import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyTermsConsentLabel extends StatefulWidget {
  const PrivacyTermsConsentLabel({super.key});

  @override
  State<PrivacyTermsConsentLabel> createState() =>
      PrivacyTermsConsentLabelState();
}

class PrivacyTermsConsentLabelState extends State<PrivacyTermsConsentLabel> {
  static const _privacyPolicyUrl = 'https://example.com/privacy';
  static const _termsUrl = 'https://example.com/terms';

  late final TapGestureRecognizer _privacyPolicyRecognizer;
  late final TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () => _launchUrl(_privacyPolicyUrl);
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _launchUrl(_termsUrl);
  }

  @override
  void dispose() {
    _privacyPolicyRecognizer.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = context.typography.bodyMedium;
    final linkStyle = baseStyle.copyWith(
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'I have read and agree with the '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyPolicyRecognizer,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Terms',
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
        ],
      ),
    );
  }
}
