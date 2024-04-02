import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Widget/login_widget.dart';
import 'package:university_system_front/theme.dart';

void main() {
  runApp(const ProviderScope(child: UniversitySystemUi()));
}

final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (context, state) => const LoginWidget()),
]);

class UniversitySystemUi extends StatelessWidget {
  const UniversitySystemUi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'University System UI',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      routerConfig: _router,
    );
  }
}
