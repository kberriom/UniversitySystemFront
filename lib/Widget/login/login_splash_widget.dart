import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Widget/login/base_login_widget.dart';

class LoginSplashWidget extends StatefulWidget {
  const LoginSplashWidget({super.key});

  @override
  State<LoginSplashWidget> createState() => _LoginSplashWidgetState();
}

class _LoginSplashWidgetState extends State<LoginSplashWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer(
        const Duration(milliseconds: 100), //Time the initial splash logo remains on screen
        () => GetIt.instance.get<GoRouter>().goNamed(GoRouterRoutes.animatedLogin.routeName),
      );
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
