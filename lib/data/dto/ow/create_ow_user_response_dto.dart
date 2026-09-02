import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_ow_user_response_dto.freezed.dart';
part 'create_ow_user_response_dto.g.dart';

@freezed
abstract class CreateOwUserResponseDto with _$CreateOwUserResponseDto {
  const factory CreateOwUserResponseDto({
    required String owUserId,
  }) = _CreateOwUserResponseDto;

  factory CreateOwUserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CreateOwUserResponseDtoFromJson(json);
}
