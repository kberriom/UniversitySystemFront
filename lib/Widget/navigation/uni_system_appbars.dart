import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/navigation/appbar_user_menu_button.dart';
import 'package:university_system_front/Widget/navigation/leading_widgets.dart';
import 'package:window_manager/window_manager.dart';

DynamicUniSystemAppBar? getAppBarAndroid({UniSystemSmartLeadButton? leading}) {
  if (PlatformUtil.isWindows) {
    return null;
  } else {
    if (leading != null) {
      return DynamicUniSystemAppBar(isInLogin: false, androidLeading: leading);
    }
    return const DynamicUniSystemAppBar(isInLogin: false); //There is no appBar in Android login
  }
}

///An App bar that turns into a usable Windows title bar with close/restore/minimize buttons on Desktop.
class DynamicUniSystemAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isInLogin;
  final bool forceShowLogo;
  final bool forceShowUserIcon;
  final bool enableUserIconMenu;
  final UniSystemSmartLeadButton? androidLeading;

  const DynamicUniSystemAppBar({
    super.key,
    required this.isInLogin,
    this.forceShowLogo = false,
    this.forceShowUserIcon = false,
    this.enableUserIconMenu = true,
    this.androidLeading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: context.isAndroid ? true : false,
      centerTitle: true,
      flexibleSpace: _buildChildOrGestureDetectorWithChild(),
      backgroundColor: _appBarBackgroundColor(ref, context),
      leading: PlatformUtil.isAndroid ? androidLeading : _setIfWindows(
        _setIfNotInLogin(
          ref.watch(uniSystemAppBarLeadingProvider),
        ),
      ),
      scrolledUnderElevation: 0,
      title: _setIfNotInLoginOrForceLogo(
        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 110),
          child: _buildChildOrGestureDetectorWithChild(child: Image.asset('assets/logo_full_nobg_v1.png', cacheWidth: 200)),
        ),
      ),
      actions: [
        if (!isInLogin || forceShowUserIcon) UserMenuButton(enabled: enableUserIconMenu),
        if (context.isWindows) ...<Widget>[
          SizedBox(
            height: double.infinity,
            child: MinimizeWindowButton(
              colors: WindowButtonColors(
                  normal: Colors.transparent,
                  iconNormal: Theme.of(context).colorScheme.onSurfaceVariant,
                  mouseOver: Theme.of(context).colorScheme.surfaceContainer,
                  mouseDown: Theme.of(context).colorScheme.surfaceDim,
                  iconMouseOver: Theme.of(context).colorScheme.onSurfaceVariant,
                  iconMouseDown: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          SizedBox(
            height: double.infinity,
            child: RestoreWindowButton(
              colors: WindowButtonColors(
                  normal: Colors.transparent,
                  iconNormal: Theme.of(context).colorScheme.onSurfaceVariant,
                  mouseOver: Theme.of(context).colorScheme.surfaceContainer,
                  mouseDown: Theme.of(context).colorScheme.surfaceDim,
                  iconMouseOver: Theme.of(context).colorScheme.onSurfaceVariant,
                  iconMouseDown: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          SizedBox(
            height: double.infinity,
            child: CloseWindowButton(
              colors: WindowButtonColors(
                normal: Colors.transparent,
                iconNormal: Theme.of(context).colorScheme.onSurfaceVariant,
                mouseOver: const Color(0xFFD32F2F),
                mouseDown: const Color(0xFFB71C1C),
                iconMouseOver: const Color(0xFFFFFFFF),
                iconMouseDown: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget? _setIfWindows(Widget? child) {
    if (PlatformUtil.isWindows && child != null) {
      return child;
    } else {
      return null;
    }
  }

  Widget? _setIfNotInLogin(Widget? child) {
    if (!isInLogin) {
      return child;
    } else {
      return null;
    }
  }

  Widget? _setIfNotInLoginOrForceLogo(Widget? child) {
    if (!isInLogin || forceShowLogo) {
      return child;
    } else {
      return null;
    }
  }

  Widget? _buildChildOrGestureDetectorWithChild({Widget? child}) {
    if (PlatformUtil.isWindows) {
      return GestureDetector(
        child: child,
        onDoubleTap: () => appWindow.maximizeOrRestore(),
        onVerticalDragStart: (_) => WindowManager.instance.startDragging(),
        onHorizontalDragStart: (_) => WindowManager.instance.startDragging(),
      );
    } else {
      return child;
    }
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class UniSystemSliverAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const UniSystemSliverAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: false,
      centerTitle: true,
      backgroundColor: _appBarBackgroundColor(ref, context),
      scrolledUnderElevation: 0,
      title: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 110),
        child: Image.asset('assets/logo_full_nobg_v1.png', cacheWidth: 200),
      ),
      actions: [
        const UserMenuButton(enabled: true),
      ],
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

Color? _appBarBackgroundColor(WidgetRef ref, BuildContext context) {
  return Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.outlineVariant : null;
}
