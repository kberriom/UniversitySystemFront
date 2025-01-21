import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Service/uni_system_client/uni_system_api_request.dart';

part 'request_mode_provider.g.dart';

@Riverpod(keepAlive: true)
class RequestMode extends _$RequestMode {
  @override
  UniSysApiRequestMethod build() {
    return UniSysApiRequestMethod.rest;
  }

  void changeRequestMode(UniSysApiRequestMethod requestMethod) {
    state = requestMethod;
  }
}
