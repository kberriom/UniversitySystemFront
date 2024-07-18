import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Provider/login_provider.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Widget/base_scaffold_navigation/admin_scaffold_navigation_widget.dart';
import 'package:university_system_front/Widget/curriculums/admin/admin_curriculums_widget.dart';
import 'package:university_system_front/Widget/home/admin/admin_home_widget.dart';
import 'package:university_system_front/Widget/login/animated_login_widget.dart';
import 'package:university_system_front/Widget/login/login_splash_widget.dart';
import 'package:university_system_front/Widget/login/login_widget.dart';
import 'package:university_system_front/Widget/login/token_expired_widget.dart';
import 'package:university_system_front/Widget/subjects/admin/admin_subject_widget.dart';
import 'package:university_system_front/Widget/users/admin/admin_users_widget.dart';

part 'go_router_config.g.dart';

///Class to get the configured router instance, Use [GetIt.instance.get] to get the registered router instance
abstract base class GoRouterConfig {
  final GoRouter router = GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'rootNavigator'),
    initialLocation: GoRouterRoutes.loginSplash.routeName,
    routes: [
      GoRoute(
          path: GoRouterRoutes.loginSplash.routeName,
          name: GoRouterRoutes.loginSplash.routeName,
          builder: (context, state) => const LoginSplashWidget()),
      GoRoute(
        path: GoRouterRoutes.animatedLogin.routeName,
        name: GoRouterRoutes.animatedLogin.routeName,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            transitionDuration: AnimatedLoginTimers.heroAnimation.duration,
            key: ValueKey(GoRouterRoutes.animatedLogin.routeName),
            child: const AnimatedLoginWidget(),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: GoRouterRoutes.login.routeName,
        name: GoRouterRoutes.login.routeName,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: ValueKey(GoRouterRoutes.login.routeName),
            child: const LoginWidget(),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: GoRouterRoutes.tokenExpiredInfo.routeName,
        name: GoRouterRoutes.tokenExpiredInfo.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
            key: ValueKey(GoRouterRoutes.tokenExpiredInfo.routeName),
            fullscreenDialog: true,
            opaque: false,
            child: const TokenExpiredWidget(),
            transitionsBuilder: _fadeTransition),
      ),
      //ADMIN ROUTE TREE
      StatefulShellRoute.indexedStack(
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
              routes: const [],
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
              routes: const [],
            )
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: GoRouterRoutes.adminSubjects.routeName,
              name: GoRouterRoutes.adminSubjects.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: ValueKey(GoRouterRoutes.adminSubjects.routeName),
                child: const AdminSubjectWidget(),
              ),
              routes: const [],
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
              routes: const [],
            ),
          ]),
        ],
      ),
    ],
  );

  static Widget _fadeTransition(context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
      child: child,
    );
  }
}

@riverpod
void loginRedirection(LoginRedirectionRef ref) async {
  ref.listen(loginProvider, (previous, next) {
    switch (next) {
      case AsyncValue<BearerToken>(:final value?):
        {
          if (value.mustRedirectTokenExpired ?? false) {
            var currentRute = GetIt.instance.get<GoRouter>().routeInformationProvider.value.uri.path;
            //Redirect only if user is on a screen that's not login / animatedLogin, sessionExpired or the initial loading splash
            if (_isNotLocatedInLoginRelatedRute(currentRute)) {
              GetIt.instance.get<GoRouter>().pushNamed(GoRouterRoutes.tokenExpiredInfo.routeName);
            }
          }
          if (value.token.isNotEmpty && value.token == InternalTokenMessage.signOut.name) {
            var currentRute = GetIt.instance.get<GoRouter>().routeInformationProvider.value.uri.path;
            if (_isNotLocatedInLoginRelatedRute(currentRute)) {
              GetIt.instance.get<GoRouter>().goNamed(GoRouterRoutes.login.routeName);
            }
          }
        }
    }
  });
}

bool _isNotLocatedInLoginRelatedRute(String currentRute) {
  return ((currentRute != GoRouterRoutes.tokenExpiredInfo.routeName) &&
      (currentRute != GoRouterRoutes.login.routeName) &&
      (currentRute != GoRouterRoutes.animatedLogin.routeName) &&
      (currentRute != GoRouterRoutes.loginSplash.routeName));
}

@riverpod
void userRoleRedirection(UserRoleRedirectionRef ref, BearerToken bearerToken) async {
  switch (bearerToken.role) {
    case UserRole.admin:
      GetIt.instance.get<GoRouter>().goNamed(GoRouterRoutes.adminHome.routeName);
    case UserRole.teacher:
    // TODO: Handle this case.
    case UserRole.student:
    // TODO: Handle this case.
    case null:
      GetIt.instance.get<GoRouter>().goNamed(GoRouterRoutes.animatedLogin.routeName);
  }
}
