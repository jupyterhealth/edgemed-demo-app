import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/auth_token.dart';

part 'oauth_token_response_dto.freezed.dart';
part 'oauth_token_response_dto.g.dart';

@freezed
abstract class OAuthTokenResponseDto with _$OAuthTokenResponseDto {
  const OAuthTokenResponseDto._();

  const factory OAuthTokenResponseDto({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') @Default('') String refreshToken,
  }) = _OAuthTokenResponseDto;

  factory OAuthTokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OAuthTokenResponseDtoFromJson(json);

  AuthToken toDomain() =>
      AuthToken(accessToken: accessToken, refreshToken: refreshToken);
}
