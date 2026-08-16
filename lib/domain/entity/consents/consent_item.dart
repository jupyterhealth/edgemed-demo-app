import 'package:freezed_annotation/freezed_annotation.dart';

part 'consent_item.freezed.dart';

@freezed
abstract class ConsentItem with _$ConsentItem {
  const factory ConsentItem({
    required int studyId,
    required String studyName,
    required int codeId,
    required String text,
    required String codingSystem,
    required String codingCode,
  }) = _ConsentItem;
}
