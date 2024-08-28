import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/base_scaffold_navigation/custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:university_system_front/Widget/common_components/uni_system_appbars.dart';

import 'common_scaffold_navigation_widgets.dart';

class AdminScaffoldNavigationWidget extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdminScaffoldNavigationWidget({super.key, required this.navigationShell});

  void _goBranch(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomAdaptiveScaffold(
      //Windows has a permanent appBar that is also the title bar
      appBar: context.isWindows ? const DynamicUniSystemAppBar(isInLogin: false) : null,
      appBarBreakpoint: context.isWindows ? Breakpoints.smallAndUp : null,

      bodyRatio: 1,
      bodyOrientation: Axis.vertical,
      useDrawer: false,
      transitionDuration: Durations.short3,
      internalAnimations: true,
      smallBreakpoint: context.isAndroid ? Breakpoints.small : Breakpoints.smallDesktop,
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
