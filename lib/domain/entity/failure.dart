import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';

part 'failure.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure.unauthorized([String? message]) = _Unauthorized;
  const factory Failure.forbidden([String? message]) = _Forbidden;
  const factory Failure.serverError([String? message]) = _ServerError;
  const factory Failure.unexpected([String? message]) = _Unexpected;
}

extension FailureExtension on Failure {
  String errorMessage(BuildContext context) => map(
    unauthorized: (value) => T(context).unauthorized,
    forbidden: (value) => T(context).forbidden,
    serverError: (value) => T(context).serverError,
    unexpected: (value) => T(context).unexpected,
  );
}
