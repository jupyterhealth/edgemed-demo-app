import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/config/env/fhir_config.dart';
import 'package:jupyter_health/domain/entity/questionnaire/question.dart';

part 'questionnaire_response_dto.freezed.dart';
part 'questionnaire_response_dto.g.dart';

@freezed
abstract class QuestionnaireResponseDto with _$QuestionnaireResponseDto {
  const QuestionnaireResponseDto._();

  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory QuestionnaireResponseDto({
    required String resourceType,
    required String status,
    required String questionnaire,
    required QuestionnaireResponseSubjectDto subject,
    required String authored,
    required List<QuestionnaireResponseItemDto> item,
    QuestionnaireResponseMetaDto? meta,
  }) = _QuestionnaireResponseDto;

  factory QuestionnaireResponseDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireResponseDtoFromJson(json);

  factory QuestionnaireResponseDto.fromQuestions({
    required int patientId,
    required int fhirSourceId,
    required List<Question> questions,
    required DateTime authored,
  }) {
    return QuestionnaireResponseDto(
      resourceType: 'QuestionnaireResponse',
      status: 'completed',
      questionnaire: FhirConfig.questionnaireCanonical,
      subject: QuestionnaireResponseSubjectDto(reference: 'Patient/$patientId'),
      authored: authored.toUtc().toIso8601String(),
      meta: QuestionnaireResponseMetaDto(
        source: FhirConfig.fhirSourceUri(fhirSourceId),
      ),
      item: [for (final question in questions) _itemFromQuestion(question)],
    );
  }

  static QuestionnaireResponseItemDto _itemFromQuestion(Question question) {
    return question.map(
      optionalMultipleChoice: (value) {
        final selectedAnswers = value.selectedAnswers;
        return QuestionnaireResponseItemDto(
          linkId: value.id,
          answer: selectedAnswers
              ?.map(
                (answer) => QuestionnaireResponseAnswerDto(valueString: answer),
              )
              .toList(),
        );
      },
      optionalText: (value) {
        final answer = value.answer;
        return QuestionnaireResponseItemDto(
          linkId: value.id,
          answer: answer == null
              ? null
              : [QuestionnaireResponseAnswerDto(valueString: answer)],
        );
      },
    );
  }
}

@freezed
abstract class QuestionnaireResponseSubjectDto
    with _$QuestionnaireResponseSubjectDto {
  const factory QuestionnaireResponseSubjectDto({required String reference}) =
      _QuestionnaireResponseSubjectDto;

  factory QuestionnaireResponseSubjectDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireResponseSubjectDtoFromJson(json);
}

@freezed
abstract class QuestionnaireResponseMetaDto
    with _$QuestionnaireResponseMetaDto {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory QuestionnaireResponseMetaDto({String? source}) =
      _QuestionnaireResponseMetaDto;

  factory QuestionnaireResponseMetaDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireResponseMetaDtoFromJson(json);
}

@freezed
abstract class QuestionnaireResponseItemDto
    with _$QuestionnaireResponseItemDto {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory QuestionnaireResponseItemDto({
    required String linkId,
    List<QuestionnaireResponseAnswerDto>? answer,
  }) = _QuestionnaireResponseItemDto;

  factory QuestionnaireResponseItemDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireResponseItemDtoFromJson(json);
}

@freezed
abstract class QuestionnaireResponseAnswerDto
    with _$QuestionnaireResponseAnswerDto {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory QuestionnaireResponseAnswerDto({String? valueString}) =
      _QuestionnaireResponseAnswerDto;

  factory QuestionnaireResponseAnswerDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireResponseAnswerDtoFromJson(json);
}
