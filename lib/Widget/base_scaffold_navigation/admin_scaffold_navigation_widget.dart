import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Widget/base_scaffold_navigation/dynamic_uni_system_appbar.dart';

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
    return AdaptiveScaffold(
      //Windows has a permanent appBar that is also the title bar
      appBar: Platform.isWindows ? const DynamicUniSystemAppBar(isInLogin: false) : null,
      appBarBreakpoint: Platform.isWindows ? Breakpoints.smallAndUp : null,

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
  }
}
