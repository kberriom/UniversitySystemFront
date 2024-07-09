import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:university_system_front/Adapter/remote_config_debug_adapter.dart';
import 'package:university_system_front/Adapter/secure_storage_adapter.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/credentials/login_credentials.dart';
import 'package:university_system_front/Provider/login_provider.dart';

import '../unit_widget_test_util.dart';

void main() {
  group('Login Provider tests', () {
    test('Provider on first App start', () async {
      final container = createContainer();
      AsyncValue<BearerToken>? firstProviderValue;

      container.listen(loginProvider, (previous, next) {
        if (previous != null && firstProviderValue == null) {
          firstProviderValue = previous;
        }
      }, fireImmediately: true);
      final actual = await container.read(loginProvider.future);

      expect(firstProviderValue, const AsyncLoading<BearerToken>());
      expect(actual, const BearerToken(token: "", mustRedirectLogin: false));
    });

    test('Provider is tested from initial state', () async {
      final container = createContainer();
      AsyncValue<BearerToken>? firstProviderValue;

      container.listen(loginProvider, (previous, next) {
        if (previous != null && firstProviderValue == null) {
          firstProviderValue = previous;
        }
      }, fireImmediately: true);
      await container.read(loginProvider.future);

      expect(firstProviderValue, const AsyncLoading<BearerToken>(), reason: 'Provider must be tested from initial state');
    });

    test('Saved invalid JWT', () async {
      final container = createContainer();
      FlutterSecureStorage.setMockInitialValues({BearerTokenType.jwt.name: "not a JWT"});

      container.listen(loginProvider, (_, __) {}, fireImmediately: true);
      final actual = await container.read(loginProvider.future);

      expect(actual, const BearerToken(token: "", mustRedirectLogin: true));
    });

    test('Saved expired JWT', () async {
      final container = createContainer();
      String jwt =
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJVU0VSIERFVEFJTFMiLCJpc3MiOiJVTklWRVJTSVRZX1NZU1RFTSIsImV4cCI6MTcxODIxNTg5OSwiaWF0IjoxNzE4MjE1Nzk5LCJlbWFpbCI6ImFkbWluQHVuaXZlcnNpdHlTeXN0ZW0uY29tIn0.-hdVHYKRR8drHO_FIDQ14cdrp98Somz_2chVIxehpDE";
      FlutterSecureStorage.setMockInitialValues({BearerTokenType.jwt.name: jwt});

      container.listen(loginProvider, (_, __) {}, fireImmediately: true);
      final actual = await container.read(loginProvider.future);

      expect(actual, const BearerToken(token: "", mustRedirectLogin: true));
    });

    test('Saved existing valid JWT', () async {
      final container = createContainer();
      final jwtString = getMockJwt(const LoginCredentials(email: "test@test.com", password: "test"));
      FlutterSecureStorage.setMockInitialValues({BearerTokenType.jwt.name: jwtString});

      container.listen(loginProvider, (_, __) {}, fireImmediately: true);
      final actual = await container.read(loginProvider.future);

      expect(actual, BearerToken(token: jwtString, role: UserRole.admin, mustRedirectLogin: false));
    });

    test('New valid JWT with valid credentials', () async {
      final container = createContainer();
      LoginCredentials mockCredentials = const LoginCredentials(email: "test@test.com", password: "test");
      String jwtStringFromMockServer = getMockJwt(mockCredentials);
      final mockClient = MockClient((request) {
        return Future.value(Response(jsonEncode({"token": jwtStringFromMockServer}), 200));
      });

      container.listen(loginProvider, (_, __) {}, fireImmediately: true);
      final isSetCompletedOk = await container.read(loginProvider.notifier).setJWT(mockCredentials, httpClient: mockClient);
      final savedValue = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);

      expect(isSetCompletedOk, true);
      expect(savedValue, jwtStringFromMockServer);
    });

    test('Invalid credentials', () async {
      final container = createContainer();
      LoginCredentials mockCredentials = const LoginCredentials(email: "test@test.com", password: "noBuenoPassword");
      final mockClient = MockClient((request) {
        return Future.value(Response("", 401));
      });

      container.listen(loginProvider, (_, __) {}, fireImmediately: true);
      final isSetCompletedOk = await container.read(loginProvider.notifier).setJWT(mockCredentials, httpClient: mockClient);
      final savedValue = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);

      expect(isSetCompletedOk, false);
      expect(savedValue, null);
    });

    test('Request timeout', () async {
      final debugRemoteConfig = DebugRemoteConfig();
      debugRemoteConfig.requestTimeoutSeconds = 0;
      GetIt.instance.registerSingleton(debugRemoteConfig);
      final container = createContainer();
      LoginCredentials mockCredentials = const LoginCredentials(email: "test@test.com", password: "noBuenoPassword");
      final mockClient = MockClient((request) {
        return Future.delayed(const Duration(hours: 1), () => Response("", 500));
      });

      container.listen(loginProvider, (_, __) {}, fireImmediately: true);

      await expectLater(() => container.read(loginProvider.notifier).setJWT(mockCredentials, httpClient: mockClient),
          throwsA(isA<TimeoutException>()));
      await expectLater(await SecureStorageAdapter().readValue(BearerTokenType.jwt.name), null);
    });

    test('Too many requests', () async {
      final container = createContainer();
      LoginCredentials mockCredentials = const LoginCredentials(email: "test@test.com", password: "test");
      final mockClient = MockClient((request) {
        return Future.value(Response("", HttpStatus.tooManyRequests));
      });

      container.listen(loginProvider, (_, __) {}, fireImmediately: true);
      final isSetCompletedOk = await container.read(loginProvider.notifier).setJWT(mockCredentials, httpClient: mockClient);
      final savedValue = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);

      expect(isSetCompletedOk, false);
      expect(savedValue, null);
    });
  });
}
