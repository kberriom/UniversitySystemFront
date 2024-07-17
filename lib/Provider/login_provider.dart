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
///
///Do not use the raw JWT saved in storage, expired tokens are not removed until a new valid login.
///[loginProvider] will return a [BearerToken] that reflects this without exposing the old JWT value.
///
///For auth routing redirection see:
///[loginRedirectionProvider] for expired token redirection.
///[AnimatedLoginWidget] for auto-login redirection entrypoint
///[BaseLoginWidget] for new login redirection to /home
@riverpod
class Login extends _$Login {
  @override
  Future<BearerToken> build() async {
    final String? storedToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
    BearerToken jwt = BearerToken(token: storedToken ?? "", mustRedirectTokenExpired: false);
    late final Duration? remainingTime;
    late final Map<String, dynamic> decodedToken;

    try {
      if (jwt.token.isNotEmpty) {
        if (jwt.token == InternalTokenMessage.signOut.name) {
          //User has sign out
          return BearerToken(token: jwt.token, mustRedirectTokenExpired: false);
        }
        decodedToken = JwtDecoder.decode(jwt.token);
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(0).add(Duration(seconds: decodedToken['exp'].toInt()));
        remainingTime = expirationDate.difference(DateTime.now());
      } else {
        //JWT is empty / first app start
        //do not redirect user to login screen
        return jwt;
      }
    } catch (e) {
      //JWT could not be parsed
      //BearerToken is immutable, new instance required
      return const BearerToken(token: "", mustRedirectTokenExpired: true);
    }
    if (remainingTime.isNegative) {
      //JWT is expired
      return const BearerToken(token: "", mustRedirectTokenExpired: true);
    }
    //JWT is valid
    final keepAliveReference = ref.keepAlive();
    final timer = Timer(remainingTime, () {
      ref.invalidateSelf();
    });
    ref.onDispose(timer.cancel);
    ref.onDispose(keepAliveReference.close);
    return jwt.copyWith(
        role: UserRole.values.firstWhere((posibleRole) => posibleRole.roleName == decodedToken["role"]));
  }

  ///Get JWT from Server and store in secure storage
  Future<bool> setJWT(LoginCredentials? credentials, {http.Client? httpClient}) async {
    httpClient ??= http.Client();
    if (credentials != null && (credentials.email.isNotEmpty || credentials.password.isNotEmpty)) {
      final uri = Uri.http(RemoteConfig().getServerAddress(), "/auth/login");
      final jsonBody = const JsonEncoder().convert(credentials.toJson());
      Map<String, String> headers = {HttpHeaders.contentTypeHeader: "application/json"};
      Future<http.Response> request =
          httpClient.post(uri, body: jsonBody, headers: headers).whenComplete(() => httpClient!.close());

      final timeLimit = Duration(seconds: RemoteConfig().getRequestTimeoutSeconds());
      http.Response? response = await request.timeout(timeLimit, onTimeout: () => throw TimeoutException("setJWT_timeout"));

      if (response.statusCode == HttpStatus.ok) {
        final BearerToken bearerToken = BearerToken.fromJson(const JsonDecoder().convert(response.body));
        await SecureStorageAdapter().writeValue(BearerTokenType.jwt.name, bearerToken.token);
        ref.invalidateSelf();
        return true;
      }
      if (response.statusCode >= 400 && response.statusCode <= 499) {
        return false;
      }
      throw HttpException("setJWT_serverError: ${response.statusCode}");
    }
    return false;
  }

  Future<void> signOut() async {
    await SecureStorageAdapter().writeValue(BearerTokenType.jwt.name, InternalTokenMessage.signOut.name);
    ref.invalidateSelf();
  }
}
