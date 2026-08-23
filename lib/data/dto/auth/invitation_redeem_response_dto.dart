import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/data/dto/auth/oauth_grant_dto.dart';

part 'invitation_redeem_response_dto.freezed.dart';
part 'invitation_redeem_response_dto.g.dart';

@freezed
abstract class InvitationRedeemResponseDto with _$InvitationRedeemResponseDto {
  const factory InvitationRedeemResponseDto({
    required OAuthGrantDto grant,
  }) = _InvitationRedeemResponseDto;

  factory InvitationRedeemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$InvitationRedeemResponseDtoFromJson(json);
}
