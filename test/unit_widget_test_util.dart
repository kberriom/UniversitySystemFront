import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/credentials/login_credentials.dart';

///Initializes all application wide dependencies that require a reset after being used,
///this guarantees that all tests are independent.
///
/// DO NOT REUSE THE [ProviderContainer]
///
/// returns a Riverpod [ProviderContainer]
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  FlutterSecureStorage.setMockInitialValues({});
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  addTearDown(() async {
    container.dispose;
    await GetIt.instance.reset();
  });

  return container;
}

String getMockJwt(LoginCredentials mockCredentials) {
  final dateTime = DateTime.now();
  final jwt = JWT({
    "sub": "USER DETAILS",
    "iss": "UNIVERSITY_SYSTEM",
    "role": UserRole.admin.roleName,
    "exp": dateTime.add(const Duration(days: 1)).millisecondsSinceEpoch,
    "iat": dateTime.millisecondsSinceEpoch,
    "email": mockCredentials.email
  });
  final jwtStringFromMockServer = jwt.sign(SecretKey("SECRET_VERY_SECRET_FOR_JWT"));
  return jwtStringFromMockServer;
}
