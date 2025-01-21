import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:university_system_front/Adapter/remote_config.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

///Reactive http client with the appropriate headers and authorization for the UniversitySystem Service.
///
///Do not use for external requests
class UniSystemApiService {
  final _jsonEncoder = const JsonEncoder();
  final _jsonDecoder = const JsonDecoder();
  final Ref _ref;

  UniSystemApiService(this._ref);

  Future<dynamic> makeRequest(UniSystemRequest request) async {
    http.Client httpClient;
    if (GetIt.instance.isRegistered<http.Client>(instanceName: 'UniSystemApi_HttpClient')) {
      httpClient = GetIt.instance.get<http.Client>(instanceName: 'UniSystemApi_HttpClient');
    } else {
      httpClient = http.Client();
    }

    final String? jsonBody = (request.body == null) ? null : _jsonEncoder.convert(request.body);

    final timeLimit = Duration(seconds: RemoteConfig().getRequestTimeoutSeconds());
    final BearerToken jwt = await _ref.read(loginServiceProvider.future);

    Map<String, String> headers = {"Authorization": "Bearer ${jwt.token}", HttpHeaders.contentTypeHeader: "application/json"};

    final uri = Uri.http(RemoteConfig().getServerAddress(), '/${request.endpoint}', request.query);

    Future<http.Response> futureResponse = switch (request.type) {
      UniSysApiRestRequestType.get => httpClient.get(uri, headers: headers),
      UniSysApiRestRequestType.post => httpClient.post(uri, body: jsonBody, headers: headers),
      UniSysApiRestRequestType.put => httpClient.put(uri, body: jsonBody, headers: headers),
      UniSysApiRestRequestType.patch => httpClient.patch(uri, body: jsonBody, headers: headers),
      UniSysApiRestRequestType.delete => httpClient.delete(uri, body: jsonBody, headers: headers)
    }
      ..whenComplete(() => httpClient.close());

    http.Response response = await futureResponse.timeout(timeLimit, onTimeout: () => throw Exception("request_timeout"));
    if (response.statusCode == HttpStatus.tooManyRequests) throw Exception("request_ratelimit");
    if (response.statusCode == HttpStatus.unauthorized || response.statusCode == HttpStatus.forbidden) {
      //Token is expired or using unauthorized endpoint
      //Unauthorized endpoint calls should not happen in production as the login provider self invalidates if the token expires normally.
      //So it can only be an error, manipulated/modified client or a token invalidation initiated by the server
      if (!kDebugMode) {
        _ref.read(loginServiceProvider.notifier).signOut();
      }
      throw Exception("request_invalid");
    }
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      String errorMessage = "request_${response.statusCode}";
      if (request.includeResponseBodyOnException) {
        errorMessage = "$errorMessage => ${response.body}";
      }
      throw Exception(errorMessage);
    }
    return response.body.isNotEmpty ? _jsonDecoder.convert(utf8.decode(response.bodyBytes)) : null;
  }
}

///Reactive http client with the appropriate headers and authorization for the UniversitySystem Service.
///
///Safe to use in a isolate.
///Do not use for external requests.
class UniSystemApiServiceIsolate {
  final _jsonEncoder = const JsonEncoder();
  final _jsonDecoder = const JsonDecoder();
  final BearerToken jwt;

  UniSystemApiServiceIsolate(this.jwt);

  Future<dynamic> makeRequest(UniSystemRequest request, {http.Client? httpClient, RemoteConfig? config}) async {
    httpClient = httpClient ?? http.Client();
    config = config ?? RemoteConfig();

    final String? jsonBody = (request.body == null) ? null : _jsonEncoder.convert(request.body);

    final timeLimit = Duration(seconds: config.getRequestTimeoutSeconds());

    Map<String, String> headers = {"Authorization": "Bearer ${jwt.token}", HttpHeaders.contentTypeHeader: "application/json"};

    final uri = Uri.http(config.getServerAddress(), '/${request.endpoint}', request.query);

    Future<http.Response> futureResponse = switch (request.type) {
      UniSysApiRestRequestType.get => httpClient.get(uri, headers: headers),
      UniSysApiRestRequestType.post => httpClient.post(uri, body: jsonBody, headers: headers),
      UniSysApiRestRequestType.put => httpClient.put(uri, body: jsonBody, headers: headers),
      UniSysApiRestRequestType.patch => httpClient.patch(uri, body: jsonBody, headers: headers),
      UniSysApiRestRequestType.delete => httpClient.delete(uri, body: jsonBody, headers: headers)
    }
      ..whenComplete(() => httpClient?.close());

    http.Response response = await futureResponse.timeout(timeLimit, onTimeout: () => throw Exception("request_timeout"));
    if (response.statusCode == HttpStatus.tooManyRequests) throw Exception("request_ratelimit");
    if (response.statusCode == HttpStatus.unauthorized || response.statusCode == HttpStatus.forbidden) {
      //Token is expired or using unauthorized endpoint
      throw Exception("request_invalid");
    }
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      String errorMessage = "request_${response.statusCode}";
      if (request.includeResponseBodyOnException) {
        errorMessage = "$errorMessage => ${response.body}";
      }
      throw Exception(errorMessage);
    }
    return response.body.isNotEmpty ?  _jsonDecoder.convert(utf8.decode(response.bodyBytes)) : null;
  }
}
