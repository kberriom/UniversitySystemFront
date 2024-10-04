import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_controller_extension/animation_controller_extension.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

///Shows a BackgroundWaitModal that pops when future is completed
Future<T> showBackgroundWaitModal<T>(BuildContext context, Future<T> future) {
  showDialog(
    barrierLabel: "",
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return BackgroundWaitModal(
        future: future,
      );
    },
  );
  return future;
}

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
  final Widget child;
  final bool canPop;

  const DialogModal({super.key, required this.child, required this.canPop});

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
      body: Stack(
        alignment: Alignment.center,
        children: [
          Listener(
            onPointerDown: (_) {
              if (canPop) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const SizedBox.expand(),
            ),
          ),
          Center(child: child)
        ],
      ),
    );
  }
}

class ItemSelectionModal extends StatelessWidget {
  final bool canPop;
  final String title;
  final Widget? headerWidget;
  final Widget child;
  final double widthFactor;
  final double heightFactor;

  const ItemSelectionModal({
    super.key,
    this.canPop = true,
    this.widthFactor = 0.9,
    this.heightFactor = 0.9,
    required this.title,
    this.headerWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DialogModal(
      canPop: canPop,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), icon: const Icon(Icons.close)),
                Flexible(
                  child: AnimatedTextTitle(
                    text: title,
                    widthFactor: 0.9,
                    fontSize: 27,
                  ),
                ),
              ],
            ),
            if (headerWidget != null) headerWidget!,
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadiusBig),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
