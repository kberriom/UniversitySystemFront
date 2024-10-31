import 'package:flutter/material.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';

///Requires a [Flexible] or [Expanded] if it shares width with other widgets
class AnimatedTextTitle extends StatefulWidget {
  final String text;
  final double fontSize;
  final TextOverflow textOverflow;
  final double widthFactor;
  final BoxConstraints constraints;

  const AnimatedTextTitle({
    super.key,
    required this.text,
    this.fontSize = 32,
    this.textOverflow = TextOverflow.ellipsis,
    this.widthFactor = 0.7,
    this.constraints = const BoxConstraints(maxWidth: 650),
  });

  @override
  State<AnimatedTextTitle> createState() => _AnimatedTextTitleState();
}

class _AnimatedTextTitleState extends State<AnimatedTextTitle> with AnimationMixin {
  final slideTween = Tween(begin: const Offset(-0.4, 0), end: const Offset(0, 0));
  final fadeTween = Tween(begin: 0.0, end: 1.0);
  late final AnimationController fadeInController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: widget.constraints,
        child: FractionallySizedBox(
          widthFactor: widget.widthFactor,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SlideTransition(
              position: controller.drive(slideTween),
              child: FadeTransition(
                opacity: fadeInController.drive(fadeTween),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 16),
                  child: Text(
                    overflow: widget.textOverflow,
                    maxLines: 1,
                    widget.text,
                    style: TextStyle(fontFamily: 'blazma', fontStyle: FontStyle.italic, fontSize: widget.fontSize),
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

class AnimatedComboTextTitle extends StatefulWidget {
  final Widget? upWidget;
  final Widget? downWidget;
  final String? upText;
  final String? downText;
  final Widget? underlineWidget;
  final double widthFactor;

  const AnimatedComboTextTitle(
      {super.key, this.upWidget, this.downWidget, this.upText, this.downText, required this.widthFactor, this.underlineWidget});

  @override
  State<AnimatedComboTextTitle> createState() => _AnimatedComboTextTitleState();
}

class _AnimatedComboTextTitleState extends State<AnimatedComboTextTitle> with AnimationMixin {
  final slideTween = Tween(begin: const Offset(-0.4, 0), end: const Offset(0, 0));
  final fadeTween = Tween(begin: 0.0, end: 1.0);
  late final AnimationController fadeInController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widget.widthFactor,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SlideTransition(
            position: controller.drive(slideTween),
            child: FadeTransition(
              opacity: fadeInController.drive(fadeTween),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.upText != null)
                          Expanded(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              widget.upText!,
                              style: const TextStyle(fontFamily: 'blazma', fontStyle: FontStyle.italic, fontSize: 20),
                            ),
                          ),
                        if (widget.upWidget != null) widget.upWidget!
                      ],
                    ),
                    Row(
                      children: [
                        if (widget.downText != null)
                          Expanded(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              widget.downText!,
                              style: const TextStyle(fontFamily: 'blazma', fontStyle: FontStyle.italic, fontSize: 32, height: 1),
                            ),
                          ),
                        if (widget.downWidget != null) widget.downWidget!
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SlideTransition(
            position: controller.drive(slideTween),
            child: Divider(color: Theme.of(context).colorScheme.onSurface),
          ),
          if (widget.underlineWidget != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: widget.underlineWidget!,
            )
        ]),
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
