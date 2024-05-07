import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Adapter/remote_config.dart';
import 'package:university_system_front/Adapter/secure_storage_adapter.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/credentials/login_credentials.dart';

part 'login_provider.g.dart';

///Reactive Auth for the UniversitySystem Service.
///Gets token from secure storage and checks if token is valid,
///if token is invalid all listeners receive a [mustRedirectLogin] that triggers auth related events.
///For auth routing redirection see [loginRedirectionProvider]
@riverpod
class Login extends _$Login {
  @override
  Future<BearerToken> build() async {
    final String? storedToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
    BearerToken jwt = BearerToken(token: storedToken ?? "", mustRedirectLogin: false);
    late final Duration? remainingTime;

    try {
      if (jwt.token.isNotEmpty) {
        remainingTime = JwtDecoder.getRemainingTime(jwt.token);
      } else {
        //JWT is empty / first app start
        //do not redirect user to login screen
        return jwt;
      }
    } catch (e) {
      //JWT could not be parsed
      //BearerToken is immutable, new instance required
      return const BearerToken(token: "", mustRedirectLogin: true);
    }
    if (remainingTime.isNegative) {
      //JWT is expired
      return const BearerToken(token: "", mustRedirectLogin: true);
    }
    //JWT is valid
    final keepAliveReference = ref.keepAlive();
    final timer = Timer(remainingTime, () {
      ref.invalidateSelf();
    });
    ref.onDispose(timer.cancel);
    ref.onDispose(keepAliveReference.close);
    return jwt;
  }

  ///Get JWT from Server and store in secure storage
  Future<bool> setJWT(LoginCredentials? credentials) async {
    if (credentials != null && (credentials.email.isNotEmpty || credentials.password.isNotEmpty)) {
      final uri = Uri.http(RemoteConfig().getServerAddress(), "/auth/login");
      final jsonBody = const JsonEncoder().convert(credentials.toJson());
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: "application/json"};
      Future<http.Response> request = http.post(uri, body: jsonBody, headers: headers);

      final timeLimit = Duration(seconds: RemoteConfig().getRequestTimeoutSeconds());
      http.Response? response = await request.timeout(timeLimit, onTimeout: () => throw Exception("TIMEOUT"));

      if (response.statusCode == HttpStatus.tooManyRequests) throw Exception("RATE_LIMIT");

      if (response.statusCode == HttpStatus.ok) {
        final BearerToken bearerToken = BearerToken.fromJson(const JsonDecoder().convert(response.body));
        await SecureStorageAdapter().writeValue(BearerTokenType.jwt.name, bearerToken.token);
        ref.invalidateSelf();
      }
      return response.statusCode == HttpStatus.ok;
    }
    return false;
  }
}

enum BearerTokenType {
  jwt(name: "jwt");

  final String name;

  const BearerTokenType({required this.name});
}
