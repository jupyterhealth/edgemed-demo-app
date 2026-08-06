import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

enum _Key { languageCode, encryptionKey, accessToken }

@LazySingleton(as: LocalStorageRepository)
class LocalStorageRepositoryImpl implements LocalStorageRepository {
  static const String _boxName = 'jupyter_health';
  late final Box _box;
  late final FlutterSecureStorage _secureStorage;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    // Hive.registerAdapters();
    _secureStorage = FlutterSecureStorage();
    _box = await _openEncryptedBox();
  }

  Future<Box> _openEncryptedBox() async {
    final encryptionKey = await _getOrCreateEncryptionKey();
    try {
      return await Hive.openBox(
        _boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
    } catch (_) {
      await Hive.deleteBoxFromDisk(_boxName);
      await _secureStorage.delete(key: _Key.encryptionKey.name);
      final freshKey = await _getOrCreateEncryptionKey();
      return Hive.openBox(
        'neurotap',
        encryptionCipher: HiveAesCipher(freshKey),
      );
    }
  }

  Future<List<int>> _getOrCreateEncryptionKey() async {
    final storedKey = await _secureStorage.read(key: _Key.encryptionKey.name);
    if (storedKey != null) {
      return base64Url.decode(storedKey);
    }
    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _Key.encryptionKey.name,
      value: base64UrlEncode(newKey),
    );
    return newKey;
  }

  // Hive
  @override
  Locale? getLocale() {
    final languageCode = _box.get(_Key.languageCode.name);
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return null;
  }

  @override
  Future<void> setLocale(Locale locale) async =>
      _box.put(_Key.languageCode.name, locale.languageCode);

  @override
  Future<String?> getAccessToken() async =>
      await _secureStorage.read(key: _Key.accessToken.name);

  @override
  Future<void> setAccessToken(String accessToken) async => await _secureStorage
      .write(key: _Key.accessToken.name, value: accessToken);
}
