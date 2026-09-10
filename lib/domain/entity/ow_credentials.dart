import 'package:freezed_annotation/freezed_annotation.dart';

part 'ow_credentials.freezed.dart';
part 'ow_credentials.g.dart';

@freezed
abstract class OwCredentials with _$OwCredentials {
  const OwCredentials._();
  const factory OwCredentials({
    @JsonKey(name: 'owUserId') required String userId,
    @JsonKey(name: 'owAccessToken') required String accessToken,
    @JsonKey(name: 'owRefreshToken') required String refreshToken,
  }) = _OwCredentials;

  factory OwCredentials.fromJson(Map<String, dynamic> json) =>
      _$OwCredentialsFromJson(json);
}
