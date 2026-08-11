import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/data/dto/jhe/open_mhealth/omh_data_point_dto.dart';

class Base64JsonConverter extends JsonConverter<OmhDataPointDto?, Object?> {
  const Base64JsonConverter();

  @override
  OmhDataPointDto? fromJson(Object? json) {
    if (json is! String || json.isEmpty) return null;
    final decoded = utf8.decode(base64Decode(json));
    return OmhDataPointDto.fromJson(
      jsonDecode(decoded) as Map<String, dynamic>,
    );
  }

  @override
  Object? toJson(OmhDataPointDto? object) {
    if (object == null) return null;
    return base64Encode(utf8.encode(jsonEncode(object.toJson())));
  }
}
