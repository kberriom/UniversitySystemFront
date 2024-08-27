import 'package:flutter/material.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';

class HomeTextTitle extends StatefulWidget {
  final String text;

  const HomeTextTitle({
    super.key,
    required this.text,
  });

  @override
  State<HomeTextTitle> createState() => _HomeTextTitleState();
}

class _HomeTextTitleState extends State<HomeTextTitle> with AnimationMixin {
  final slideTween = Tween(begin: const Offset(-0.4, 0), end: const Offset(0, 0));
  final fadeTween = Tween(begin: 0.0, end: 1.0);
  late final AnimationController fadeInController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SlideTransition(
              position: controller.drive(slideTween),
              child: FadeTransition(
                opacity: fadeInController.drive(fadeTween),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 16),
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    widget.text,
                    style: const TextStyle(fontFamily: 'blazma', fontStyle: FontStyle.italic, fontSize: 32),
                  ),
                ),
              ),
            ),
            SlideTransition(
              position: controller.drive(slideTween),
              child: Divider(color: Theme.of(context).colorScheme.onSurface),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void initState() {
    fadeInController = createController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!controller.isForwardOrCompleted) {
      fadeInController.animateTo(1.0, curve: Curves.easeIn, duration: Durations.extralong1);
      controller.animateTo(1.0, curve: Curves.easeOut, duration: Durations.long1);
    }
  }
}
