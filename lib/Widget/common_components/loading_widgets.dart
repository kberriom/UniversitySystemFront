import 'package:flutter/material.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';

import 'infinite_list_widgets.dart';

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
    return Tooltip(
      message: context.localizations.refreshButtonTooltip,
      child: RotationTransition(
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
      ),
    );
  }

  @override
  void initState() {
    controller.duration = const Duration(milliseconds: 500);
    super.initState();
  }
}

class FixedExtentShimmerList extends StatefulWidget {
  final double itemMaxWidth;
  final double itemMinWidth;
  final double itemsPadding;
  final double itemExtent;
  final int? itemCount;
  final AnimationController? animationController;
  final double borderRadius;

  const FixedExtentShimmerList({
    this.animationController,
    this.itemCount,
    required this.itemsPadding,
    required this.itemExtent,
    required this.itemMinWidth,
    required this.itemMaxWidth,
    this.borderRadius = kBorderRadiusSmall,
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

  @override
  State<FixedExtentShimmerList> createState() => _FixedExtentShimmerListState();
}

class _FixedExtentShimmerListState extends State<FixedExtentShimmerList> with AnimationMixin {
  late AnimationController _shimmerController;
  late BoxConstraints _itemConstraints;
  bool _isVisible = false;
  late LinearGradient _gradient;

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
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: LinearGradient(
                      colors: _gradient.colors,
                      stops: _gradient.stops,
                      begin: _gradient.begin,
                      end: _gradient.end,
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
    _gradient = switch (Theme.of(context).brightness) {
      Brightness.dark => widget.shimmerGradientDarkMode,
      Brightness.light => widget.shimmerGradientLightMode,
    };
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

///A shimmer loading animation for a item in a [SliverFixedExtentList] that uses [itemConstraints]
class LoadingShimmerItem extends StatelessWidget {
  const LoadingShimmerItem({
    super.key,
    required this.itemConstraints,
    this.borderRadius = kBorderRadiusSmall,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final double borderRadius;
  final EdgeInsets padding;
  final FixedExtentItemConstraints itemConstraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.center,
        child: FixedExtentShimmerList(
            borderRadius: borderRadius,
            animationController: itemConstraints.animationController,
            itemCount: 1,
            itemMaxWidth: itemConstraints.cardMaxWidthConstraints,
            itemMinWidth: itemConstraints.cardMinWidthConstraints,
            itemExtent: itemConstraints.cardHeight,
            itemsPadding: 0),
      ),
    );
  }
}
