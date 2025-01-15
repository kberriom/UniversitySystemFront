import 'dart:ui' show clampDouble;

import 'package:flutter/material.dart';
import 'package:university_system_front/Util/platform_utils.dart';

class UniSystemKeyboardBottomInset extends StatelessWidget {
  final Widget child;

  ///Remember to set resizeToAvoidBottomInset = true on the corresponding Scaffold.
  const UniSystemKeyboardBottomInset({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtil.isAndroid) {
      return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            viewInsets: MediaQuery.viewInsetsOf(context).copyWith(
              bottom: clampDouble(MediaQuery.viewInsetsOf(context).bottom - 86, 0, double.infinity),
            ),
          ),
          child: child);
    } else {
      return child;
    }
  }
}
