abstract final class FhirConfig {
  static const dataSourceId = 70005;
  static const fhirSourceLabel = 'Example App';
  static const fhirBaseUrl = 'https://example.com/app';
  static const questionnaireCanonical = 'Questionnaire/momentum-intake';

  static String fhirSourceUri(int fhirSourceId) =>
      'https://jupyterhealth.org/fhir/fhir-source/$fhirSourceId';
}
