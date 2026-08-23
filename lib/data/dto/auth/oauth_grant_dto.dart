import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth_grant_dto.freezed.dart';
part 'oauth_grant_dto.g.dart';

@freezed
abstract class OAuthGrantDto with _$OAuthGrantDto {
  const factory OAuthGrantDto({
    @JsonKey(name: 'grant_type') required String grantType,
    required String code,
    @JsonKey(name: 'redirect_uri') required String redirectUri,
    @JsonKey(name: 'client_id') required String clientId,
  }) = _OAuthGrantDto;

  factory OAuthGrantDto.fromJson(Map<String, dynamic> json) =>
      _$OAuthGrantDtoFromJson(json);
}
