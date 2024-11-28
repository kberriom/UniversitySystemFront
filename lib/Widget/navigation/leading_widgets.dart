import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Router/go_router_config.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/theme_mode_provider.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

part 'leading_widgets.g.dart';

@riverpod
class UniSystemAppBarLeading extends _$UniSystemAppBarLeading {
  @override
  Widget? build() {
    if (PlatformUtil.isWindows) {
      return const UniSystemThemeButton();
    }
    return null;
  }

  void setLeading(Widget? leading) {
    if (PlatformUtil.isWindows) {
      state = leading;
    }
  }
}

Widget setLeadingOnWindows(ValueKey<String> key, Widget widget,
    {UniSystemSmartLeadButton leading = const UniSystemBackButton()}) {
  if (PlatformUtil.isWindows) {
    switch (leading) {
      case UniSystemBackButton():
        return VisibilityLeadingWrapper<UniSystemBackButton>(
          pageKey: key,
          leading: leading,
          widget: widget,
        );
      case UniSystemCustomBackButton():
        return VisibilityLeadingWrapper<UniSystemCustomBackButton>(
          pageKey: key,
          leading: leading,
          widget: widget,
        );
    }
  } else {
    return widget;
  }
}

class VisibilityLeadingWrapper<LT extends UniSystemSmartLeadButton> extends ConsumerStatefulWidget {
  final ValueKey pageKey;
  final Widget widget;
  final LT leading;

  const VisibilityLeadingWrapper({super.key, required this.pageKey, required this.leading, required this.widget});

  @override
  ConsumerState<VisibilityLeadingWrapper> createState() => _VisibilityLeadingWrapperState<LT>();
}

class _VisibilityLeadingWrapperState<LT extends UniSystemSmartLeadButton> extends ConsumerState<VisibilityLeadingWrapper> {
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.pageKey,
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction > 0 && ref.read(uniSystemAppBarLeadingProvider) is! LT) {
          _setPostFrameLeadingChange(ref, widget.leading);
        }
      },
      child: Builder(builder: (context) {
        return widget.widget;
      }),
    );
  }

  void _setPostFrameLeadingChange(WidgetRef ref, Widget leading) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(uniSystemAppBarLeadingProvider.notifier).setLeading(leading);
    });
  }

  @override
  void initState() {
    _setPostFrameLeadingChange(ref, widget.leading);
    super.initState();
  }
}

class UniSystemThemeButton extends ConsumerStatefulWidget {
  const UniSystemThemeButton({super.key});

  @override
  ConsumerState<UniSystemThemeButton> createState() => _UniSystemThemeButtonState();
}

class _UniSystemThemeButtonState extends ConsumerState<UniSystemThemeButton> {
  late Brightness _brightness;

  @override
  void didChangeDependencies() {
    _brightness = Theme.of(context).brightness;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          _brightness = ref.read(currentThemeModeProvider.notifier).changeThemeMode(Theme.of(context).brightness);
        });
      },
      icon: Icon(_brightness == Brightness.light ? Icons.sunny : Icons.nightlight_round_sharp),
    );
  }
}

sealed class UniSystemSmartLeadButton implements Widget {}

enum UniSystemSmartLeadButtonIcons {
  close,
  back,
}

///Button that does a simple pop
class UniSystemBackButton extends ConsumerWidget implements UniSystemSmartLeadButton {
  const UniSystemBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackButton(onPressed: () {
      ref.read(goRouterInstanceProvider).routerDelegate.popRoute();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => VisibilityDetectorController.instance.notifyNow());
    });
  }
}

class UniSystemCustomBackButton extends ConsumerWidget implements UniSystemSmartLeadButton {
  final UniSystemSmartLeadButtonIcons icon;
  final String? route;
  final Object? extra;
  final GoRouterRoutes? routerRoute;

  ///Button that returns to a configurable previous page
  const UniSystemCustomBackButton(
      {super.key, this.route, this.extra, this.routerRoute, this.icon = UniSystemSmartLeadButtonIcons.close})
      : assert(route != null || routerRoute != null, "Set a manual route OR auto route (routerRoute) in UniSystemCloseButton");

  void customClose(WidgetRef ref) {
    if (routerRoute != null) {
      GoRouterRoutes? currentParent = routerRoute!;
      String routeString = "${currentParent.routeName.substring(0, 1) == "/" ? "" : "/"}${currentParent.routeName}";

      currentParent = currentParent.parent;
      while (currentParent != null) {
        routeString = "${currentParent.routeName.substring(0, 1) == "/" ? "" : "/"}${currentParent.routeName}$routeString";
        currentParent = currentParent.parent;
      }
      ref.read(goRouterInstanceProvider).pushReplacement(routeString, extra: extra);
    } else if (route != null) {
      ref.read(goRouterInstanceProvider).pushReplacement(route!, extra: extra);
    } else {
      ref.read(goRouterInstanceProvider).routerDelegate.pop();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => VisibilityDetectorController.instance.notifyNow());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (icon) {
      UniSystemSmartLeadButtonIcons.close => CloseButton(onPressed: () => customClose(ref)),
      UniSystemSmartLeadButtonIcons.back => BackButton(onPressed: () => customClose(ref)),
    };
  }
}
