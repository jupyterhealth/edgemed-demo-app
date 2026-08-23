/// Strips the host prefix from deep-link invite codes, e.g.
/// `jhe.fly.dev_K3mR8vQ2xL9pT4wN6bY1zC7hJ5gF0dSa` → `K3mR8vQ2xL9pT4wN6bY1zC7hJ5gF0dSa`.
String normalizeInvitationCode(String invitationCode) {
  final separatorIndex = invitationCode.indexOf('_');
  if (separatorIndex < 0 || separatorIndex + 1 >= invitationCode.length) {
    return invitationCode;
  }
  return invitationCode.substring(separatorIndex + 1);
}

class InvitationLink {
  static const host = 'jhe.fly.dev';
  static const invitationSegment = 'invitation';

  static String? codeFrom(Uri uri) {
    if (uri.host != host) return null;

    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    final invitationIndex = segments.lastIndexOf(invitationSegment);
    if (invitationIndex < 0 || invitationIndex + 1 >= segments.length) {
      return null;
    }

    final code = segments[invitationIndex + 1].trim();
    if (code.isEmpty) return null;

    return normalizeInvitationCode(code);
  }
}
