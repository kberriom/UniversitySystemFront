import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Model/credentials/login_credentials.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Theme/theme.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:university_system_front/Widget/common_components/form_widgets.dart';

class LoginWidgetForm extends ConsumerStatefulWidget {
  const LoginWidgetForm({super.key});

  @override
  ConsumerState createState() => _LoginWidgetFormState();
}

class _LoginWidgetFormState extends ConsumerState<LoginWidgetForm> {
  final _emailFormKey = GlobalKey<FormFieldState>();
  final _emailValidationRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _loginButtonFocusNode = FocusNode();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoginIncorrect = false;
  Future<bool>? _pendingLogin;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginButtonFocusNode.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: const MaterialTheme().dark(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 85),
            child: Column(
              children: [
                TextFormField(
                  controller: _emailTextController,
                  key: _emailFormKey,
                  autocorrect: false,
                  focusNode: _emailFocusNode,
                  onEditingComplete: () => _passwordFocusNode.requestFocus(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: buildUniSysInputDecoration(
                          context.localizations.loginEmailHint, Theme.of(context).colorScheme.onSurfaceVariant)
                      .copyWith(
                    contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  ),
                  validator: (String? value) => _validateEmailOrErrorString(value, context),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _passwordTextController,
                  obscureText: _isPasswordObscured,
                  enableSuggestions: false,
                  autocorrect: false,
                  onEditingComplete: () => _loginButtonFocusNode.requestFocus(),
                  focusNode: _passwordFocusNode,
                  decoration: buildUniSysInputDecoration(
                          context.localizations.loginPasswordHint, Theme.of(context).colorScheme.onSurfaceVariant)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: _getPasswordVisibilityIcon(),
                      onPressed: () => setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      }),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            focusNode: _loginButtonFocusNode,
            //Flutter framework bug workaround (github.com/flutter/flutter/issues/136745)
            onFocusChange: (gainedFocus) {
              if (gainedFocus) {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              }
            },
            onPressed: () {
              _isLoginIncorrect = false;
              if (_emailFormKey.currentState!.validate() && _pendingLogin == null) {
                final loginCredentials =
                    LoginCredentials(email: _emailTextController.text, password: _passwordTextController.text);
                final Future<bool> futureLogin = ref.read(loginServiceProvider.notifier).signIn(loginCredentials);

                futureLogin.then((result) {
                  //Success callback
                  _isLoginIncorrect = !result;
                  _emailFormKey.currentState!.validate();
                  _pendingLogin = null;
                }, onError: (e) {
                  //Error callback
                  if (context.mounted) {
                    context.showTextSnackBar(context.localizations.veryVerboseErrorTryAgain);
                  }
                  _pendingLogin = null;
                });
                setState(() {
                  _pendingLogin = futureLogin;
                });
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(286, 67),
            ),
            child: FutureBuilder(
              future: _pendingLogin,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                      height: 45,
                      width: 45,
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.inversePrimary));
                }
                return Text(AppLocalizations.of(context)!.loginButton);
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmailOrErrorString(String? value, BuildContext context) {
    if (value != null && _emailValidationRegex.hasMatch(value) && !_isLoginIncorrect) {
      return null;
    } else {
      if (_isLoginIncorrect) {
        return context.localizations.loginError;
      }
      return context.localizations.loginEmailError;
    }
  }

  Widget _getPasswordVisibilityIcon() {
    if (_isPasswordObscured) {
      return const Icon(Icons.remove_red_eye);
    }
    return const Icon(Icons.remove_red_eye_outlined);
  }
}
