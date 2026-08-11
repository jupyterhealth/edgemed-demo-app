enum ObservationType {
  glucose,
  bloodPressure,
  sleep,
  steps,
  unknown;

  static ObservationType fromOmhCode(String? code) {
    if (code == null || code.isEmpty) return ObservationType.unknown;

    final name = code.contains(':') ? code.split(':')[1] : code;

    return switch (name) {
      'blood-glucose' || 'glucose' => ObservationType.glucose,
      'blood-pressure' => ObservationType.bloodPressure,
      'sleep' || 'sleep-duration' => ObservationType.sleep,
      'step-count' || 'steps' => ObservationType.steps,
      _ => ObservationType.unknown,
    };
  }
}
