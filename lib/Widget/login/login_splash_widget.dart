import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Router/go_router_config.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Widget/login/base_login_widget.dart';

import 'package:university_system_front/Model/credentials/bearer_token.dart';

class LoginSplashWidget extends ConsumerStatefulWidget {
  const LoginSplashWidget({super.key});

  @override
  ConsumerState<LoginSplashWidget> createState() => _LoginSplashWidgetState();
}

class _LoginSplashWidgetState extends ConsumerState<LoginSplashWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.listenManual(loginServiceProvider, (previous, next) {
        switch (next) {
          case AsyncValue<BearerToken>(:final value?):
            {
              if (value.token.isNotEmpty) {
                ref.read(userRoleRedirectionProvider.call(value));
              } else {
                Timer(
                  const Duration(milliseconds: 100), //Time the initial splash logo remains on screen
                  () => ref.read(goRouterInstanceProvider).goNamed(GoRouterRoutes.animatedLogin.routeName),
                );
              }
            }
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoginWidget(canPop: true, loginWidgetForm: Container(), logoImageWidgetList: const [
      Hero(
        tag: 'login_splash',
        child: Visibility(
          child: Image(image: AssetImage('assets/logo.png')),
        ),
      ),
    ]);
  }
}
