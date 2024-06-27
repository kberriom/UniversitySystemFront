import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/credentials/login_credentials.dart';
import 'package:university_system_front/Provider/login_provider.dart';

part 'login_widget_test_provider_mocks.g.dart';

@riverpod
class MockOkLogin extends _$MockOkLogin implements Login {
  @override
  Future<BearerToken> build() async {
    return const BearerToken(token: "JWT", mustRedirectLogin: false);
  }

  @override
  Future<bool> setJWT(LoginCredentials? credentials, {http.Client? httpClient}) async {
    final mockClient = MockClient((request) {
      return Future.value(Response('"token": "JWT"', HttpStatus.ok));
    });
    return ref.read(loginProvider.notifier).setJWT(credentials, httpClient: mockClient);
  }
}

@riverpod
class MockUnauthorizedLogin extends _$MockUnauthorizedLogin implements Login {
  @override
  Future<BearerToken> build() async {
    return const BearerToken(token: "", mustRedirectLogin: false);
  }

  @override
  Future<bool> setJWT(LoginCredentials? credentials, {http.Client? httpClient}) async {
    return await Future.value(false);
  }
}

@riverpod
class MockLongLogin extends _$MockLongLogin implements Login {
  @override
  Future<BearerToken> build() async {
    return const BearerToken(token: "", mustRedirectLogin: false);
  }

  @override
  Future<bool> setJWT(LoginCredentials? credentials, {http.Client? httpClient}) async {
    Future<bool> response = Future.delayed(const Duration(milliseconds: 1), () => false);
    return await response;
  }
}

@riverpod
class MockServerErrorLogin extends _$MockServerErrorLogin implements Login {
  @override
  Future<BearerToken> build() async {
    return const BearerToken(token: "", mustRedirectLogin: false);
  }

  @override
  Future<bool> setJWT(LoginCredentials? credentials, {http.Client? httpClient}) async {
    throw const HttpException("setJWT_serverError: 500");
  }
}
