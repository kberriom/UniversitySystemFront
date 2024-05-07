import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageAdapter {
  late FlutterSecureStorage _storage;

  SecureStorageAdapter() {
    if (Platform.isAndroid || Platform.isWindows) {
      _storage = const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    } else {
      throw Exception("Platform is not supported currently");
    }
  }

  //Do not use/expose _storage.readAll or _storage.deleteAll will break Windows compat

  Future<String?> readValue(String key) async {
    return _storage.read(key: key);
  }

  Future<void> writeValue(String key, String value) async {
    return _storage.write(key: key, value: value);
  }

  void deleteValue(String key) async {
    await _storage.delete(key: key);
  }
}
