import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_controller_extension/animation_controller_extension.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

///Shows a barrier that blocks user input and cannot be dismissed while [future] is active, shows an appropriate Windows title bar when required.
///
///Pops when [future] is completed with value or error.
class BackgroundWaitModal extends ConsumerStatefulWidget {
  final Future future;
  final Widget? centerChild;

  const BackgroundWaitModal({super.key, required this.future, this.centerChild});

  @override
  ConsumerState<BackgroundWaitModal> createState() => _AnimatedBackgroundDecorationState();
}

class _AnimatedBackgroundDecorationState extends ConsumerState<BackgroundWaitModal> with AnimationMixin {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: PlatformUtil.isWindows
            ? const DynamicUniSystemAppBar(
                isInLogin: true,
                forceShowLogo: true,
              )
            : null,
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: controller.drive(Tween(begin: 0, end: 1)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: controller.value * 5, sigmaY: controller.value * 5),
            child: Align(
              alignment: Alignment.center,
              child: widget.centerChild ?? const SizedBox(height: 45, width: 45, child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.future.whenComplete(() {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
    if (!controller.isForwardOrCompleted) {
      controller.play(duration: const Duration(milliseconds: 500));
    }
  }
}

class DialogModal extends StatelessWidget {
  final AlertDialog child;

  const DialogModal({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformUtil.isWindows
          ? const DynamicUniSystemAppBar(
              isInLogin: true,
              forceShowLogo: true,
            )
          : null,
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: child,
      ),
    );
  }
}
