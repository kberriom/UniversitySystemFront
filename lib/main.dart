import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Router/go_router_config.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Theme/theme.dart' as theme;
import 'package:university_system_front/Theme/theme_mode_provider.dart';
import 'package:university_system_front/l10n/locale_controller.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Util/provider_utils.dart';
import 'package:university_system_front/Util/snackbar_utils.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatformUtil.isWindows) {
    await WindowManager.instance.ensureInitialized();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    appWindow.minSize = const Size(384, 782);
  }
  DateTimeMapper.encodingMode = DateTimeEncoding.iso8601String;
  runApp(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));
}

class UniversitySystemUi extends ConsumerWidget {
  const UniversitySystemUi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _LoginInitialization(
      child: MaterialApp.router(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'University System UI',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: UniSystemLocale.values.map((localeCode) => localeCode.locale).toList(growable: false),
        locale: ref.watch(currentLocaleProvider),
        theme: const theme.MaterialTheme().light(),
        darkTheme: const theme.MaterialTheme().dark(),
        themeMode: ref.watch(currentThemeModeProvider),
        routerConfig: ref.watch(goRouterInstanceProvider),
      ),
    );
  }
}

///This class initializes the login controller which checks secure storage for a previous JWT,
///and sets up the redirection to login for expired or invalid jwt
class _LoginInitialization extends ConsumerWidget {
  final Widget child;

  const _LoginInitialization({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(loginServiceProvider);
    ref.watch(loginRedirectionProvider);
    return child;
  }
}
