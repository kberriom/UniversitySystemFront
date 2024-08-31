import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:university_system_front/Adapter/secure_storage_adapter.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';

import 'integration_test_util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GetIt.instance.allowReassignment = true;
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('JWT autoLogin integration test', () {
    testWidgets('login / freshLoggedInInstanceHelper test', (widgetTester) async {
      expect(await SecureStorageAdapter().readValue(BearerTokenType.jwt.name), anyOf(isNull, InternalTokenMessage.signOut.name),
          reason: 'Test must be run with no valid JWT saved, do not run this test group randomized');

      await freshLoggedInInstanceHelper(widgetTester, newJwt: true, keepJwt: true, autoLogin: true);
      await widgetTester.pumpAndSettle();

      final currentRute = getGoRouter(widgetTester, find.byType(AppBar)).routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.adminHome.routeName);

      final storedBearerToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
      expect(storedBearerToken, isNotEmpty);
    });

    testWidgets('auto-login with saved credentials', (widgetTester) async {
      expect(await SecureStorageAdapter().readValue(BearerTokenType.jwt.name), isNotEmpty,
          reason: 'Test must be run with valid JWT saved, do not run this test group randomized');

      await freshLoggedInInstanceHelper(widgetTester, newJwt: false, keepJwt: true, autoLogin: false);

      await widgetTester.pumpAndSettle();

      final currentRute = getGoRouter(widgetTester, find.byType(AppBar)).routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.adminHome.routeName);
      expect(await SecureStorageAdapter().readValue(BearerTokenType.jwt.name), isNotEmpty);
    });

    testWidgets('auto-logout with saved credentials', (widgetTester) async {
      String currentJwt = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name) ?? "";
      expect(currentJwt, isNotEmpty, reason: 'Test must be run with valid JWT saved, do not run this test group randomized');
      expect(JwtDecoder.getRemainingTime(currentJwt), lessThan(const Duration(minutes: 1)),
          reason: 'Jwt expiration must not be longer than 1 minute for autoLogin tests');

      await freshLoggedInInstanceHelper(widgetTester, newJwt: false, keepJwt: false, autoLogin: false);

      await widgetTester.pumpAndSettle();

      expect(getGoRouter(widgetTester, find.byType(AppBar)).routeInformationProvider.value.uri.path, GoRouterRoutes.adminHome.routeName);
      expect(await SecureStorageAdapter().readValue(BearerTokenType.jwt.name), isNotEmpty);

      await widgetTester.pumpAndSettle(JwtDecoder.getRemainingTime(currentJwt)); //Wait for JWT expiration

      await widgetTester.pumpAndSettle(); //Wait for animations

      //_RouterState is private in GoRouter, but it's serializable
      Map goRouterState = getGoRouter(widgetTester, find.byType(AppBar)).routeInformationProvider.value.state as Map<dynamic, dynamic>;

      expect(((goRouterState['imperativeMatches'] as List<Map<dynamic, dynamic>>).first['location'] as String),
          GoRouterRoutes.tokenExpiredInfo.routeName);

      final sessionExpiredTextFinder = find.text(AppLocalizations.of(widgetTester.allElements.last)!.sessionExpired);
      final AppLocalizations appLocalizations = AppLocalizations.of(widgetTester.element(sessionExpiredTextFinder))!;
      final sessionExpiredMessageTextFinder = find.text(appLocalizations.sessionExpiredMessage);
      final textButtonFinder = find.byType(TextButton);
      final textButtonWithCorrectTextFinder =
          find.ancestor(of: find.text(appLocalizations.sessionExpiredConfirmation), matching: textButtonFinder);

      expect(sessionExpiredTextFinder, findsOne);
      expect(sessionExpiredMessageTextFinder, findsOne);
      expect(textButtonWithCorrectTextFinder, findsOne);

      await widgetTester.tap(textButtonWithCorrectTextFinder);

      await widgetTester.pumpAndSettle();

      final filledButtonFinder = find.byType(FilledButton);
      expect(getGoRouter(widgetTester, filledButtonFinder).routeInformationProvider.value.uri.path, GoRouterRoutes.login.routeName);
      final providerContainer = ProviderScope.containerOf(widgetTester.element(filledButtonFinder));
      expect(await providerContainer.read(loginServiceProvider.future), const BearerToken(token: "", mustRedirectTokenExpired: true));
    });
  });
}
