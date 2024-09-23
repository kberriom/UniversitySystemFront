import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_animations/animation_mixin/animation_mixin.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';

part 'carousel_widgets.g.dart';

///Flutter framework bug workaround. See issue https://github.com/flutter/flutter/issues/154701
@riverpod
class UserCarouselOnTap extends _$UserCarouselOnTap {
  @override
  bool build(UserRole userRole, int index) {
    return false;
  }

  void reset() {
    state = false;
  }

  void hasTaped() {
    state = true;
  }
}

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

class UserListCarousel<T> extends ConsumerWidget {
  const UserListCarousel({
    super.key,
    required this.future,
    required this.noAssignedMsg,
    required this.onDataWidgetCallback,
    required this.userRole, //todo remove when flutter/issues/154701 is resolved.
  });

  final Future<List<T>> future;
  final String noAssignedMsg;
  final Widget Function(T data, int index) onDataWidgetCallback; //todo remove [index] when flutter/issues/154701 is resolved.
  final UserRole userRole; //todo remove when flutter/issues/154701 is resolved.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                return onDataWidgetCallback.call(data, index);
              }),
              onTapCallBack: (index) {
                //todo remove when flutter/issues/154701 is resolved.
                ref.read(userCarouselOnTapProvider.call(userRole, index).notifier).hasTaped();
              },
            );
        }
      },
    );
  }
}
