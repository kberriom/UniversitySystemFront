import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Provider/login_provider.dart';
import 'package:university_system_front/Theme/theme_mode_provider.dart';
import 'package:university_system_front/Util/university_system_ui_localizations_helper.dart';
import 'package:window_manager/window_manager.dart';

DynamicUniSystemAppBar? getAppBarAndroid() {
  if (Platform.isWindows) {
    return null;
  } else {
    return const DynamicUniSystemAppBar(isInLogin: false); //There is no appBar in Android login
  }
}

///An App bar that turns into a usable Windows title bar with close/restore/minimize buttons on Desktop.
class DynamicUniSystemAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isInLogin;

  const DynamicUniSystemAppBar({super.key, required this.isInLogin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      centerTitle: true,
      flexibleSpace: _buildChildOrGestureDetectorWithChild(),
      backgroundColor: _appBarBackgroundColor(ref, context),
      leading: _setIfWindows(_setIfNotInLogin(
        IconButton(
          onPressed: () {
            ref.read(currentThemeModeProvider.notifier).changeThemeMode();
          },
          icon: Icon(Theme.of(context).colorScheme.brightness == Brightness.light ? Icons.sunny : Icons.nightlight_round_sharp),
        ),
      )),
      title: _setIfNotInLogin(
        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 110),
          child: _buildChildOrGestureDetectorWithChild(child: Image.asset('assets/logo_full_nobg_v1.png', cacheWidth: 200)),
        ),
      ),
      actions: [
        if (!isInLogin)
          IconButton(
            //Keep IconButton to maintain built-in padding to the left
            iconSize: 32,
            icon: PopupMenuButton(
              child: const Icon(Icons.account_circle_sharp),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                    child: Text(context.localizations.signOutPopupMenu), onTap: () => ref.read(loginProvider.notifier).signOut()),
              ],
            ),
            onPressed: () {},
          ),
        if (Platform.isWindows) ...<Widget>[
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
    if (Platform.isWindows && child != null) {
      return child;
    } else {
      return null;
    }
  }

  Widget? _setIfNotInLogin(Widget child) {
    if (!isInLogin) {
      return child;
    } else {
      return null;
    }
  }

  Widget? _buildChildOrGestureDetectorWithChild({Widget? child}) {
    if (Platform.isWindows) {
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

  Color? _appBarBackgroundColor(WidgetRef ref, BuildContext context) {
    if (ref.watch(currentThemeModeProvider) == ThemeMode.light) {
      return Theme.of(context).colorScheme.outlineVariant;
    } else {
      return null; //Use default color of theme
    }
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
