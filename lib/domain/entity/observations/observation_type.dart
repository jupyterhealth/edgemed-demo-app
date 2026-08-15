enum ObservationType {
  glucose,
  bloodPressure,
  sleep,
  steps,
  unknown;

  static const _omhSystem = 'https://w3id.org/openmhealth';
  static const _ieeeSystem = 'https://w3id.org/ieee1752';

  /// FHIR search `code` values in `system|code` form.
  List<String> get fhirSearchCodes => switch (this) {
    ObservationType.glucose => ['$_omhSystem|omh:blood-glucose:4.0'],
    ObservationType.bloodPressure => ['$_omhSystem|omh:blood-pressure:4.0'],
    ObservationType.sleep => [
      '$_ieeeSystem|ieee:sleep-episode:1.0',
      '$_omhSystem|omh:sleep-episode:1.1',
    ],
    ObservationType.steps => ['$_ieeeSystem|ieee:physical-activity:1.0'],
    ObservationType.unknown => const [],
  };

  static ObservationType fromOmhCode(String? code) {
    if (code == null || code.isEmpty) return ObservationType.unknown;

    final name = code.contains(':') ? code.split(':')[1] : code;

    return switch (name) {
      'blood-glucose' || 'glucose' => ObservationType.glucose,
      'blood-pressure' => ObservationType.bloodPressure,
      'sleep' || 'sleep-duration' || 'sleep-episode' || 'total-sleep-time' =>
        ObservationType.sleep,
      'step-count' || 'steps' || 'physical-activity' => ObservationType.steps,
      _ => ObservationType.unknown,
    };
  }
}
