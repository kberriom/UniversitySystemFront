import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Widget/login/animated_login_widget.dart';
import 'package:university_system_front/Widget/login/login_splash_widget.dart';
import 'package:university_system_front/Widget/login/login_widget.dart';
import 'package:university_system_front/Widget/login/token_expired_widget.dart';
import 'admin_router.dart';

part 'go_router_config.g.dart';

@Riverpod(keepAlive: true)
class GoRouterInstance extends _$GoRouterInstance {
  @override
  GoRouter build() {
    return GoRouter(
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
        getAdminRouteTree(ref),
      ],
    );
  }

  Widget _fadeTransition(BuildContext context, Animation<double> animation, Animation secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
      child: child,
    );
  }
}

///Redirects the user for login related events such as token expired, sign out or unexpected token expiration from server
///only evaluates on a update event of [loginServiceProvider]
@riverpod
void loginRedirection(LoginRedirectionRef ref) async {
  ref.listen(loginServiceProvider, (previous, next) {
    switch (next) {
      case AsyncValue<BearerToken>(:final value?):
        {
          final goRouter = ref.read(goRouterInstanceProvider);
          if (value.mustRedirectTokenExpired ?? false) {
            var currentRute = goRouter.routeInformationProvider.value.uri.path;
            //Redirect only if user is on a screen that's not login / animatedLogin, sessionExpired or the initial loading splash
            if (_isNotLocatedInLoginRelatedRute(currentRute)) {
              goRouter.pushNamed(GoRouterRoutes.tokenExpiredInfo.routeName);
            }
          }
          if (value.token.isNotEmpty && value.token == InternalTokenMessage.signOut.name) {
            var currentRute = goRouter.routeInformationProvider.value.uri.path;
            if (_isNotLocatedInLoginRelatedRute(currentRute)) {
              goRouter.goNamed(GoRouterRoutes.login.routeName);
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

///Redirects the user to the appropriate nav tree, can be seen as the "entry point" to the application
///If a bearer token has a role it implies that the token is valid
@riverpod
void userRoleRedirection(UserRoleRedirectionRef ref, BearerToken bearerToken) async {
  final goRouter = ref.read(goRouterInstanceProvider);
  switch (bearerToken.role) {
    case UserRole.admin:
      goRouter.goNamed(GoRouterRoutes.adminHome.routeName);
    case UserRole.teacher:
    // TODO: Handle this case.
    case UserRole.student:
    // TODO: Handle this case.
    case null:
      goRouter.goNamed(GoRouterRoutes.animatedLogin.routeName);
  }
}
