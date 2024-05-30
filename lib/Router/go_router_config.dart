import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Provider/login_provider.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Widget/home_widget.dart';
import 'package:university_system_front/Widget/token_expired_widget.dart';
import 'package:university_system_front/Widget/login/login_widget.dart';

part 'go_router_config.g.dart';

///Singleton class to get the router instance, intended to only be used in [MaterialApp.router] and navigation cases described in [go_router_config.dart]
///
///Do not use for regular routing, use [BuildContext.go_router] to navigate
final class GoRouterConfig {
  static final GoRouterConfig _instance = GoRouterConfig._internal();

  GoRouterConfig._internal();

  factory GoRouterConfig() {
    return _instance;
  }

  final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: GoRouterRoutes.login.routeName,
        name: GoRouterRoutes.login.routeName,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: ValueKey(GoRouterRoutes.login.routeName),
            child: const LoginWidget(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
          path: GoRouterRoutes.home.routeName,
          name: GoRouterRoutes.home.routeName,
          builder: (context, state) => const HomeWidget()),
      GoRoute(
        path: GoRouterRoutes.tokenExpiredInfo.routeName,
        name: GoRouterRoutes.tokenExpiredInfo.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
            key: ValueKey(GoRouterRoutes.tokenExpiredInfo.routeName),
            fullscreenDialog: true,
            opaque: false,
            child: const TokenExpiredWidget(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
                child: child,
              );
            }),
      ),
    ],
  );
}

@riverpod
void loginRedirection(LoginRedirectionRef ref) async {
  ref.listen(loginProvider, (previous, next) {
    switch (next) {
      case AsyncValue<BearerToken>(:final value?):
        {
          if (value.mustRedirectLogin ?? false) {
            final sessionExpiredRoute = GoRouterRoutes.tokenExpiredInfo.routeName;
            var currentRute = GoRouterConfig().router.routeInformationProvider.value.uri.path;
            //Redirect only if user is on a screen that's not login or sessionExpired
            if (((currentRute != sessionExpiredRoute) && (currentRute != GoRouterRoutes.login.routeName))) {
              GoRouterConfig().router.pushNamed(sessionExpiredRoute);
            }
          }
        }
    }
  });
}
