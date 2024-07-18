import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Provider/login_provider.dart';
import 'package:university_system_front/Theme/theme_mode_provider.dart';
import 'package:university_system_front/Util/university_system_ui_localizations_helper.dart';

import 'common_scaffold_navigation_widgets.dart';

class AdminScaffoldNavigationWidget extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdminScaffoldNavigationWidget({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        return AdaptiveScaffold(
          appBar: AppBar(
            primary: true,
            leading: Platform.isWindows
                ? IconButton(
                    onPressed: () {
                      ref.read(currentThemeModeProvider.notifier).changeThemeMode();
                    },
                    icon: Icon(Theme.of(context).colorScheme.brightness == Brightness.light
                        ? Icons.sunny
                        : Icons.nightlight_round_sharp))
                : null,
            title: ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 110),
                child: Image.asset('assets/logo_full_nobg_v1.png', cacheWidth: 200)),
            centerTitle: true,
            actions: [
              IconButton(
                //Keep IconButton to maintain built-in padding to the left
                iconSize: 32,
                icon: PopupMenuButton(
                  child: const Icon(Icons.account_circle_sharp),
                  itemBuilder: (context) => <PopupMenuEntry>[
                    PopupMenuItem(
                        child: Text(context.localizations.signOutPopupMenu),
                        onTap: () => ref.read(loginProvider.notifier).signOut()),
                  ],
                ),
                onPressed: () {},
              ),
            ],
          ),
          appBarBreakpoint: Breakpoints.smallAndUp,
          useDrawer: false,
          internalAnimations: false,
          smallBreakpoint: Platform.isAndroid ? Breakpoints.small : Breakpoints.smallDesktop,
          body: (_) => navigationShell,
          destinations: [
            buildNavigationDestinationHome(context),
            buildNavigationDestinationUsers(context),
            buildNavigationDestinationSubjects(context),
            buildNavigationDestinationCurriculums(context),
          ],
          selectedIndex: navigationShell.currentIndex,
          onSelectedIndexChange: _goBranch,
        );
      },
    );
  }
}
