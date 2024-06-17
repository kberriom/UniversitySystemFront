import 'package:university_system_front/Adapter/remote_config.dart';

final class DebugRemoteConfig implements RemoteConfig {

  String serverAddress = const String.fromEnvironment("ENV_ADR", defaultValue: "10.0.2.2:8080");
  int requestTimeoutSeconds = const int.fromEnvironment("ENV_SERVER_TIMEOUT", defaultValue: 20);

  @override
  String getServerAddress() {
    return serverAddress;
  }

  @override
  int getRequestTimeoutSeconds() {
    return requestTimeoutSeconds;
  }
}
