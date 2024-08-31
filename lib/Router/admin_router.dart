import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'go_router_routes.dart';
import 'package:university_system_front/Widget/navigation/base_scaffold_navigation/admin_scaffold_navigation_widget.dart';
import 'package:university_system_front/Widget/navigation/leading_widgets.dart';
import 'package:university_system_front/Widget/home/admin/admin_home_widget.dart';
import 'package:university_system_front/Widget/curriculums/admin/admin_curriculums_widget.dart';
import 'package:university_system_front/Widget/subjects/add_subject_widget.dart';
import 'package:university_system_front/Widget/subjects/admin/admin_subject_widget.dart';
import 'package:university_system_front/Widget/users/admin/admin_users_widget.dart';

StatefulShellRoute getAdminRouteTree(Ref ref) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return AdminScaffoldNavigationWidget(navigationShell: navigationShell);
    },
    branches: <StatefulShellBranch>[
      StatefulShellBranch(routes: [
        GoRoute(
          path: GoRouterRoutes.adminHome.routeName,
          name: GoRouterRoutes.adminHome.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            key: ValueKey(GoRouterRoutes.adminHome.routeName),
            child: const AdminHomeWidget(),
          ),
          routes: const <GoRoute>[],
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: GoRouterRoutes.adminUsers.routeName,
          name: GoRouterRoutes.adminUsers.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            key: ValueKey(GoRouterRoutes.adminUsers.routeName),
            child: const AdminUsersWidget(),
          ),
          routes: const <GoRoute>[],
        )
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: GoRouterRoutes.adminSubjects.routeName,
          name: GoRouterRoutes.adminSubjects.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: ValueKey(GoRouterRoutes.adminSubjects.routeName), child: const AdminSubjectWidget()),
          routes: [
            GoRoute(
              path: GoRouterRoutes.adminAddSubject.routeName,
              name: GoRouterRoutes.adminAddSubject.routeName,
              onExit: (context, state) {
                if (PlatformUtil.isWindows) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
                }
                return true;
              },
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: !PlatformUtil.isWindows
                      ? const AddSubjectWidget()
                      : VisibilityLeadingWrapper(
                          pageKey: state.pageKey,
                          leading: const UniSystemBackButton(),
                          widget: const AddSubjectWidget(),
                        ),
                );
              },
            ),
          ],
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: GoRouterRoutes.adminCurriculums.routeName,
          name: GoRouterRoutes.adminCurriculums.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            key: ValueKey(GoRouterRoutes.adminCurriculums.routeName),
            child: const AdminCurriculumsWidget(),
          ),
          routes: const <GoRoute>[],
        ),
      ]),
    ],
  );
}
