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

class UniSystemCarousel extends StatefulWidget {
  final List<Widget> list;
  final void Function(int index)? onTapCallBack;
  final bool isPlaceholder;
  final int placeholderAmount;
  final Size size;

  const UniSystemCarousel({
    super.key,
    this.list = const <Widget>[],
    this.onTapCallBack,
    this.isPlaceholder = false,
    this.placeholderAmount = 5,
    this.size = const Size(100, 100),
  });

  @override
  State<UniSystemCarousel> createState() => _UniSystemCarouselState();
}

class _UniSystemCarouselState extends State<UniSystemCarousel> with AnimationMixin {
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
          itemExtent: widget.size.width,
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
  });

  final Future<List<T>> future;
  final String noAssignedMsg;
  final Widget Function(T data) onDataWidgetCallback;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
          case ConnectionState.active:
            return const UniSystemCarousel(isPlaceholder: true, size: Size(200, 200));
          case ConnectionState.done:
            if (snapshot.data?.isEmpty ?? true) {
              return UniSystemCarousel(list: [
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
            return UniSystemCarousel(
              size: const Size(200, 200),
              list: List<Widget>.generate(growable: false, snapshot.data!.length, (index) {
                var data = snapshot.data![index];
                return onDataWidgetCallback.call(data);
              }),
              onTapCallBack: (index) {},
            );
        }
      },
    );
  }
}

class UserCarouselItem extends StatelessWidget {
  const UserCarouselItem({
    super.key,
    required this.image,
    required this.footer,
  });

  final Widget image;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox.expand(
            child: image,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kBorderRadiusBig, vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: footer,
          ),
        ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  final String text;
  final Icon icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(text),
      style: ButtonStyle(
        fixedSize: const WidgetStatePropertyAll(Size.fromHeight(60)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall))),
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainer),
      ),
    );
  }
}
