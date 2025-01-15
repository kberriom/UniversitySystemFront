import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';

class _AllDeviceScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class UniSystemBaseCarousel extends StatefulWidget {
  final List<Widget> list;
  final void Function(int index)? onTapCallBack;
  final bool isPlaceholder;
  final int placeholderAmount;
  final Size size;

  const UniSystemBaseCarousel({
    super.key,
    this.list = const <Widget>[],
    this.onTapCallBack,
    this.isPlaceholder = false,
    this.placeholderAmount = 5,
    this.size = const Size(100, 100),
  });

  @override
  State<UniSystemBaseCarousel> createState() => _UniSystemBaseCarouselState();
}

class _UniSystemBaseCarouselState extends State<UniSystemBaseCarousel> with AnimationMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = createController(unbounded: true, fps: 60);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height,
      child: ScrollConfiguration(
        behavior: _AllDeviceScrollBehavior(),
        child: CarouselView(
          enableSplash: false,
          shrinkExtent: widget.size.width + (kBodyHorizontalPadding - 4),
          itemExtent: widget.size.width + (kBodyHorizontalPadding - 4),
          padding: const EdgeInsets.only(left: kBodyHorizontalPadding, right: 4, top: 4, bottom: 4),
          itemSnapping: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusBig)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          onTap: widget.onTapCallBack,
          children: widget.isPlaceholder
              ? List.generate(
                  growable: false,
                  widget.placeholderAmount,
                  (index) => SizedBox.expand(
                    child: LoadingShimmerItem(
                      borderRadius: 0,
                      padding: EdgeInsets.zero,
                      itemConstraints: FixedExtentItemConstraints(
                          cardHeight: widget.size.height,
                          cardMinWidthConstraints: double.infinity,
                          cardMaxWidthConstraints: double.infinity,
                          animationController: _animationController),
                    ),
                  ),
                )
              : widget.list,
        ),
      ),
    );
  }
}

class UserListCarousel<T> extends StatelessWidget {
  const UserListCarousel({
    super.key,
    required this.future,
    required this.noAssignedMsg,
    required this.onDataWidgetCallback,
    required this.onTapCallBack,
  });

  final Future<List<T>> future;
  final String noAssignedMsg;
  final Widget Function(T data) onDataWidgetCallback;
  final Function(T data) onTapCallBack;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
          case ConnectionState.active:
            return const UniSystemBaseCarousel(isPlaceholder: true, size: Size(200, 200));
          case ConnectionState.done:
            if (snapshot.data?.isEmpty ?? true) {
              return UniSystemBaseCarousel(list: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline),
                    Text(noAssignedMsg),
                  ],
                )
              ], size: const Size(200, 200));
            }
            //On valid data
            return UniSystemBaseCarousel(
              size: const Size(200, 200),
              list: List<Widget>.generate(growable: false, snapshot.data!.length, (index) {
                var data = snapshot.data![index];
                return onDataWidgetCallback.call(data);
              }),
              onTapCallBack: (index) {
                onTapCallBack(snapshot.data![index]);
              },
            );
        }
      },
    );
  }
}
