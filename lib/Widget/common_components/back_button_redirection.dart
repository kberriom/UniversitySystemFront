import 'package:flutter/material.dart';
import 'package:university_system_front/Util/platform_utils.dart';

class SystemBackButtonRedirection extends StatelessWidget {
  final Widget child;
  final bool canPop;
  final VoidCallback onRedirect;

  const SystemBackButtonRedirection({
    super.key,
    required this.child,
    required this.onRedirect,
    this.canPop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtil.isAndroid) {
      return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              onRedirect();
            }
          },
          child: child);
    } else {
      return child;
    }
  }
}
