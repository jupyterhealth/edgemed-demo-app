import 'package:dartz/dartz.dart';
import 'package:jupyter_health/domain/entity/auth_token.dart';
import 'package:jupyter_health/domain/entity/consents/consent_item.dart';
import 'package:jupyter_health/domain/entity/consents/patient_consents.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/observations/observation_page.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';
import 'package:jupyter_health/domain/entity/questionnaire/question.dart';
import 'package:jupyter_health/domain/entity/ow_credentials.dart';
import 'package:jupyter_health/domain/entity/user.dart';

abstract class ApiRepository {
  Future<Either<Failure, AuthToken>> login(String invitationCode);
  Future<Either<Failure, User>> getUser();
  Future<Either<Failure, PatientConsents>> getPatientConsents({
    required int patientId,
  });
  Future<Either<Failure, Unit>> submitPatientConsents({
    required int patientId,
    required List<ConsentItem> items,
  });
  Future<Either<Failure, ObservationPage>> getObservations({
    required ObservationType type,
    Map<String, String>? nextUrls,
  });
  Future<Either<Failure, Unit>> submitQuestionnaire({
    required int patientId,
    required List<Question> questions,
  });
  Future<Either<Failure, bool>> hasCompletedQuestionnaire({
    required int patientId,
  });
  Future<Either<Failure, OwCredentials>> createOwUser();
}
