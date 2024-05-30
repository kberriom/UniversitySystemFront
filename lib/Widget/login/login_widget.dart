import 'package:flutter/material.dart';
import 'package:university_system_front/Widget/login/base_login_widget.dart';
import 'package:university_system_front/Widget/login/login_widget_form.dart';

class LoginWidget extends StatelessWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseLoginWidget(
        logoImageWidgetList: [Image(image: AssetImage('assets/logo_full_nobg_v1.png'))],
        loginWidgetForm: LoginWidgetForm());
  }
}
