import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/data/dto/jhe/open_mhealth/omh_data_point_dto.dart';

class Base64JsonConverter extends JsonConverter<OmhDataPointDto?, Object?> {
  const Base64JsonConverter();

  @override
  OmhDataPointDto? fromJson(Object? json) {
    if (json is! String || json.isEmpty) return null;
    try {
      final normalized = json.replaceAll(RegExp(r'\s'), '');
      final decoded = utf8.decode(base64Decode(normalized));
      return OmhDataPointDto.fromJson(
        jsonDecode(decoded) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Object? toJson(OmhDataPointDto? object) {
    if (object == null) return null;
    return base64Encode(utf8.encode(jsonEncode(object.toJson())));
  }
}

class FhirDateTimeConverter extends JsonConverter<DateTime?, Object?> {
  const FhirDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json is String && json.isNotEmpty) {
      return DateTime.tryParse(json);
    }
    if (json is Map) {
      final start = json['start'] ?? json['start_date_time'];
      if (start is String) return DateTime.tryParse(start);
    }
    return null;
  }

  @override
  Object? toJson(DateTime? object) => object?.toIso8601String();
}
