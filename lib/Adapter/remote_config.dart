import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get_it/get_it.dart';
import 'package:university_system_front/Adapter/remote_config_android_adapter.dart';
import 'package:university_system_front/Adapter/remote_config_debug_adapter.dart';
import 'package:university_system_front/Adapter/remote_config_windows_adapter.dart';
import 'package:university_system_front/Util/platform_utils.dart';

abstract interface class RemoteConfig {
  String getServerAddress();

  int getRequestTimeoutSeconds();

  factory RemoteConfig() {
    if (kDebugMode) {
      if (GetIt.instance.isRegistered<DebugRemoteConfig>()) {
        return GetIt.instance.get<DebugRemoteConfig>();
      } else {
        return GetIt.instance.registerSingleton<DebugRemoteConfig>(DebugRemoteConfig());
      }
    }
    if (PlatformUtil.isAndroid) {
      return AndroidRemoteConfigAdapter();
    } else if (PlatformUtil.isWindows) {
      return RemoteConfigWindowsAdapter();
    } else {
      throw Exception("Platform is not currently supported");
    }
  }
}
