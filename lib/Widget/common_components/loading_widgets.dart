import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Theme/theme_mode_provider.dart';

typedef FutureCallback = Future Function();

class AnimatedRefreshButton extends StatefulWidget {
  const AnimatedRefreshButton({required this.onPressed, super.key});

  final FutureCallback onPressed;

  @override
  State<AnimatedRefreshButton> createState() => _AnimatedRefreshState();
}

class _AnimatedRefreshState extends State<AnimatedRefreshButton> with AnimationMixin {
  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(controller),
      child: IconButton(
          onPressed: () {
            final Future future = widget.onPressed.call();
            controller.repeat();
            future.whenComplete(() => controller
              ..stop(canceled: true)
              ..reset());
          },
          icon: const Icon(Icons.refresh)),
    );
  }

  @override
  void initState() {
    controller.duration = const Duration(milliseconds: 500);
    super.initState();
  }
}

class FixedExtentShimmerList extends ConsumerStatefulWidget {
  const FixedExtentShimmerList({
    this.animationController,
    this.itemCount,
    required this.itemsPadding,
    required this.itemExtent,
    required this.itemMinWidth,
    required this.itemMaxWidth,
    super.key,
  });

  final shimmerGradientDarkMode = const LinearGradient(
    colors: [
      Color(0xFF1B211D),
      Color(0xFF353B36),
      Color(0xFF1B211D),
    ],
    stops: [
      0.1,
      0.3,
      0.4,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );

  final shimmerGradientLightMode = const LinearGradient(
    colors: [
      Color(0xFFEAEFE8),
      Color(0xFFC0C9C0),
      Color(0xFFEAEFE8),
    ],
    stops: [
      0.1,
      0.3,
      0.4,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );

  final double itemMaxWidth;
  final double itemMinWidth;
  final double itemsPadding;
  final double itemExtent;
  final int? itemCount;
  final AnimationController? animationController;

  @override
  ConsumerState<FixedExtentShimmerList> createState() => _FixedExtentShimmerListState();
}

class _FixedExtentShimmerListState extends ConsumerState<FixedExtentShimmerList> with AnimationMixin {
  late AnimationController _shimmerController;
  late BoxConstraints _itemConstraints;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 80),
      opacity: _isVisible ? 1.0 : 0.0,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        itemExtent: widget.itemExtent + widget.itemsPadding,
        itemBuilder: (context, index) => Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: widget.itemsPadding),
            child: ConstrainedBox(
              constraints: _itemConstraints,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: (ref.watch(currentThemeModeProvider) == ThemeMode.light
                              ? widget.shimmerGradientLightMode
                              : widget.shimmerGradientDarkMode)
                          .colors,
                      stops: (ref.watch(currentThemeModeProvider) == ThemeMode.light
                              ? widget.shimmerGradientLightMode
                              : widget.shimmerGradientDarkMode)
                          .stops,
                      begin: (ref.watch(currentThemeModeProvider) == ThemeMode.light
                              ? widget.shimmerGradientLightMode
                              : widget.shimmerGradientDarkMode)
                          .begin,
                      end: (ref.watch(currentThemeModeProvider) == ThemeMode.light
                              ? widget.shimmerGradientLightMode
                              : widget.shimmerGradientDarkMode)
                          .end,
                      transform: _SlidingGradientTransform(slidePercent: _shimmerController.value),
                    )),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    if (!_isVisible) {
      Future.delayed(
        const Duration(milliseconds: 30),
        () {
          if (mounted) {
            setState(() {
              _isVisible = true;
            });
          }
        },
      );
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _itemConstraints = BoxConstraints(
        minHeight: widget.itemExtent, maxHeight: widget.itemExtent, minWidth: widget.itemMinWidth, maxWidth: widget.itemMaxWidth);
    if (widget.animationController != null) {
      _shimmerController = widget.animationController!;
    } else {
      _shimmerController = createController(unbounded: true, fps: 60);
    }
    super.initState();
    if (!_shimmerController.isAnimating) {
      _shimmerController.repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
    }
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
