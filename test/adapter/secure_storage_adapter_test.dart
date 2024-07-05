import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test/test.dart';
import 'package:university_system_front/Adapter/secure_storage_adapter.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';

void main() {
  group('Test mock secure storage', () {
    final key = BearerTokenType.jwt.name;
    const expectedResult = "expectedResult";

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({"": "", key: expectedResult});
    });

    test('read from storage', () async {
      final notSavedValue = await SecureStorageAdapter().readValue("random");
      final savedValue = await SecureStorageAdapter().readValue(key);

      expect(notSavedValue, null);
      expect(savedValue, expectedResult);
    });

    test('write in storage', () async {
      const otherResult = "other expectedResult";
      await SecureStorageAdapter().writeValue(key, otherResult);

      final savedValue = await SecureStorageAdapter().readValue(key);

      expect(savedValue, otherResult);
    });

    test('delete from storage', () async {
      await SecureStorageAdapter().deleteValue(key);

      final savedValue = await SecureStorageAdapter().readValue(key);

      expect(savedValue, null);
    });
  });
}
