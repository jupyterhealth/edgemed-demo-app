import 'dart:convert';

import 'package:jupyter_health/utils/invitation_utils.dart';

String invitationCodeVerifier(String invitationCode) {
  return base64Url
      .encode(utf8.encode(normalizeInvitationCode(invitationCode)))
      .replaceAll('=', '');
}
