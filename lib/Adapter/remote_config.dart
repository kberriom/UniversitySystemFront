import 'dart:io';

abstract interface class RemoteConfig {
  String getServerAddress();

  int getRequestTimeoutSeconds();

  factory RemoteConfig() {
    if (Platform.isAndroid) {
      //TODO: FIX
      return DebugRemoteConfig();
    } else if (Platform.isWindows) {
      //TODO: FIX
      return DebugRemoteConfig();
    } else {
      throw Exception("Platform is not supported currently");
    }
  }
}

final class DebugRemoteConfig implements RemoteConfig {
  @override
  String getServerAddress() {
    return const String.fromEnvironment("ENV_ADR", defaultValue: "10.0.2.2:8080");
  }

  @override
  int getRequestTimeoutSeconds() {
    return const int.fromEnvironment("ENV_SERVER_TIMEOUT", defaultValue: 20);
  }
}
