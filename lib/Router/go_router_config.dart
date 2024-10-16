import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Provider/login_provider.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Widget/login/animated_login_widget.dart';
import 'package:university_system_front/Widget/home_widget.dart';
import 'package:university_system_front/Widget/login/login_splash_widget.dart';
import 'package:university_system_front/Widget/login/login_widget.dart';
import 'package:university_system_front/Widget/login/token_expired_widget.dart';

part 'go_router_config.g.dart';

///Class to get the configured router instance, Use [GetIt.instance.get] to get the registered router instance
abstract base class GoRouterConfig {
  final GoRouter router = GoRouter(
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
      GoRoute(
          path: GoRouterRoutes.home.routeName,
          name: GoRouterRoutes.home.routeName,
          builder: (context, state) => const HomeWidget()),
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
          if (value.mustRedirectLogin ?? false) {
            final sessionExpiredRoute = GoRouterRoutes.tokenExpiredInfo.routeName;
            var currentRute = GetIt.instance.get<GoRouter>().routeInformationProvider.value.uri.path;
            //Redirect only if user is on a screen that's not login / animatedLogin, sessionExpired or the initial loading splash
            if (((currentRute != sessionExpiredRoute) &&
                (currentRute != GoRouterRoutes.login.routeName) &&
                (currentRute != GoRouterRoutes.animatedLogin.routeName) &&
                (currentRute != GoRouterRoutes.loginSplash.routeName))) {
              GetIt.instance.get<GoRouter>().pushNamed(sessionExpiredRoute);
            }
          }
        }
    }
  });
}
