abstract final class FhirConfig {
  static const dataSourceId = 70005;
  static const fhirSourceLabel = 'UCSF EdgeMed';
  static const fhirBaseUrl = 'https://ucsf.edge.med/fhir';
  static const questionnaireCanonical = 'Questionnaire/momentum-intake';

  static String fhirSourceUri(int fhirSourceId) =>
      'https://jupyterhealth.org/fhir/fhir-source/$fhirSourceId';
}
