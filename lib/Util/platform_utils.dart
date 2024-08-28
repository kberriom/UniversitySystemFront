import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart' show BuildContext;

extension Platform on BuildContext {
  bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
}

final class PlatformUtil {
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
}
