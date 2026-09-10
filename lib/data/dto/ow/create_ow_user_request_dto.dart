import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_ow_user_request_dto.freezed.dart';
part 'create_ow_user_request_dto.g.dart';

@freezed
abstract class CreateOwUserRequestDto with _$CreateOwUserRequestDto {
  const factory CreateOwUserRequestDto({
    @JsonKey(name: 'include_ow_tokens') @Default(true) bool includeOwTokens,
  }) = _CreateOwUserRequestDto;

  factory CreateOwUserRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateOwUserRequestDtoFromJson(json);
}
