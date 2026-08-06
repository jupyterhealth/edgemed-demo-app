import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.unauthorized([String? message]) = _Unauthorized;
  const factory Failure.forbidden([String? message]) = _Forbidden;
  const factory Failure.serverError([String? message]) = _ServerError;
  const factory Failure.unexpected([String? message]) = _Unexpected;
}
