import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Model/credentials/login_credentials.dart';
import 'package:university_system_front/Provider/login_provider.dart';

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
    return Column(
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
                decoration: InputDecoration(
                  helperText: "",
                  hintText: AppLocalizations.of(context)!.loginEmailHint,
                  filled: true,
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
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: _getPasswordVisibilityIcon(),
                    onPressed: () => setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    }),
                  ),
                  helperText: "",
                  hintText: AppLocalizations.of(context)!.loginPasswordHint,
                  filled: true,
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
              final Future<bool> futureLogin = ref.read(loginProvider.notifier).setJWT(loginCredentials);

              futureLogin.then((result) {
                //Success callback
                _isLoginIncorrect = !result;
                _emailFormKey.currentState!.validate();
                _pendingLogin = null;
              }, onError: (e) {
                //Error callback
                _getLoginErrorSnackBar(context);
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
    );
  }

  void _getLoginErrorSnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.loginServerError));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
  }

  String? _validateEmailOrErrorString(String? value, BuildContext context) {
    if (value != null && _emailValidationRegex.hasMatch(value) && !_isLoginIncorrect) {
      return null;
    } else {
      if (_isLoginIncorrect) {
        return AppLocalizations.of(context)!.loginError;
      }
      return AppLocalizations.of(context)!.loginEmailError;
    }
  }

  Widget _getPasswordVisibilityIcon() {
    if (_isPasswordObscured) {
      return const Icon(Icons.remove_red_eye);
    }
    return const Icon(Icons.remove_red_eye_outlined);
  }
}
