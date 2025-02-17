import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:university_system_front/Adapter/secure_storage_adapter.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Util/provider_utils.dart';
import 'package:university_system_front/main.dart';

import 'integration_test_util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GetIt.instance.allowReassignment = true;
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('Login integration test', () {
    setUpAll(() async {
      await SecureStorageAdapter().deleteValue(BearerTokenType.jwt.name);
    });

    tearDown(() async {
      await SecureStorageAdapter().deleteValue(BearerTokenType.jwt.name);
    });

    testWidgets('show correct login Widgets', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      var imageFinder = find.byType(Image);
      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(imageFinder, findsExactly(2)); //Hero widget image and login image which are the same image
      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

      String currentRute = getGoRouter(widgetTester, filledButtonFinder).routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.animatedLogin.routeName);
      final storedBearerToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
      expect(storedBearerToken, null);
    });

    testWidgets('login with correct credentials', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

      final router = getGoRouter(widgetTester, filledButtonFinder);

      final textFormFieldEmailFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginEmailHint),
          matching: textFormFieldFinder);
      final textFormFieldPasswordFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginPasswordHint),
          matching: textFormFieldFinder);

      await widgetTester.tap(textFormFieldEmailFinder);
      await widgetTester.enterText(textFormFieldEmailFinder, const String.fromEnvironment("INTEG_TEST_USER_MAIL"));

      await widgetTester.tap(textFormFieldPasswordFinder);
      await widgetTester.enterText(textFormFieldPasswordFinder, const String.fromEnvironment("INTEG_TEST_USER_PASSWORD"));

      await widgetTester.ensureVisible(filledButtonFinder);
      await widgetTester.tap(filledButtonFinder);

      await widgetTester.pump();
      final circularProgressIndicatorFinder = find.byType(CircularProgressIndicator);

      expect(circularProgressIndicatorFinder, findsOne);

      await widgetTester.pumpAndSettle();

      var currentRute = router.routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.adminHome.routeName);

      final storedBearerToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
      expect(storedBearerToken, isNotNull);
      expect(storedBearerToken, isNotEmpty);
    });

    testWidgets('sign out', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

      final router = getGoRouter(widgetTester, filledButtonFinder);

      final appLocalizations = AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!;

      final textFormFieldEmailFinder =
          find.ancestor(of: find.text(appLocalizations.loginEmailHint), matching: textFormFieldFinder);
      final textFormFieldPasswordFinder =
          find.ancestor(of: find.text(appLocalizations.loginPasswordHint), matching: textFormFieldFinder);

      await widgetTester.tap(textFormFieldEmailFinder);
      await widgetTester.enterText(textFormFieldEmailFinder, const String.fromEnvironment("INTEG_TEST_USER_MAIL"));

      await widgetTester.tap(textFormFieldPasswordFinder);
      await widgetTester.enterText(textFormFieldPasswordFinder, const String.fromEnvironment("INTEG_TEST_USER_PASSWORD"));

      await widgetTester.ensureVisible(filledButtonFinder);
      await widgetTester.tap(filledButtonFinder);

      await widgetTester.pump();
      final circularProgressIndicatorFinder = find.byType(CircularProgressIndicator);

      expect(circularProgressIndicatorFinder, findsOne);

      await widgetTester.pumpAndSettle();

      var currentRute = router.routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.adminHome.routeName);

      final menuAnchorFinder = find.byType(MenuAnchor);
      expect(menuAnchorFinder, findsOne);

      await widgetTester.tap(menuAnchorFinder);
      await widgetTester.pump();

      final popupMenuItemFinder =
          find.ancestor(of: find.text(appLocalizations.signOutPopupMenu), matching: find.byType(MenuItemButton));
      expect(popupMenuItemFinder, findsOne);

      await widgetTester.tap(popupMenuItemFinder);
      await widgetTester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, GoRouterRoutes.login.routeName);
      final storedBearerToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
      expect(storedBearerToken, InternalTokenMessage.signOut.name);
    });

    testWidgets('"Invalid email" when no email error at login', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

      final router = getGoRouter(widgetTester, filledButtonFinder);

      await widgetTester.ensureVisible(filledButtonFinder);
      await widgetTester.tap(filledButtonFinder);
      await widgetTester.pumpAndSettle();

      //Error when no email
      var invalidEmailTextFinder = find.text(AppLocalizations.of(widgetTester.element(filledButtonFinder))!.loginEmailError);
      expect(invalidEmailTextFinder, findsOne);

      await widgetTester.pumpAndSettle();

      var currentRute = router.routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.animatedLogin.routeName);
      final storedBearerToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
      expect(storedBearerToken, isNull);
    });

    testWidgets('"loginError" when no password error at login', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

      final router = getGoRouter(widgetTester, filledButtonFinder);

      //Error when no password
      final textFormFieldEmailFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginEmailHint),
          matching: textFormFieldFinder);
      await widgetTester.tap(textFormFieldEmailFinder);
      await widgetTester.enterText(textFormFieldEmailFinder, const String.fromEnvironment("INTEG_TEST_USER_MAIL"));

      await widgetTester.ensureVisible(filledButtonFinder);
      await widgetTester.tap(filledButtonFinder);
      await widgetTester.pumpAndSettle();

      var invalidEmailTextFinder = find.text(AppLocalizations.of(widgetTester.element(filledButtonFinder))!.loginError);
      expect(invalidEmailTextFinder, findsOne);

      var currentRute = router.routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.animatedLogin.routeName);

      final storedBearerToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
      expect(storedBearerToken, isNull);
    });

    testWidgets('"loginError" when incorrect password error at login', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

      final router = getGoRouter(widgetTester, filledButtonFinder);

      final textFormFieldEmailFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginEmailHint),
          matching: textFormFieldFinder);
      final textFormFieldPasswordFinder = find.ancestor(
          of: find.text(AppLocalizations.of(widgetTester.element(textFormFieldFinder.first))!.loginPasswordHint),
          matching: textFormFieldFinder);

      await widgetTester.tap(textFormFieldEmailFinder);
      await widgetTester.enterText(textFormFieldEmailFinder, const String.fromEnvironment("INTEG_TEST_USER_MAIL"));

      await widgetTester.tap(textFormFieldPasswordFinder);
      await widgetTester.enterText(textFormFieldPasswordFinder, "incorrectpassword123.");

      await widgetTester.ensureVisible(filledButtonFinder);
      await widgetTester.tap(filledButtonFinder);
      await widgetTester.pumpAndSettle();

      //Error when incorrect password
      final invalidEmailTextFinder = find.text(AppLocalizations.of(widgetTester.element(filledButtonFinder))!.loginError);
      expect(invalidEmailTextFinder, findsOne);

      await widgetTester.pumpAndSettle();

      var currentRute = router.routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.animatedLogin.routeName);

      final storedBearerToken = await SecureStorageAdapter().readValue(BearerTokenType.jwt.name);
      expect(storedBearerToken, isNull);
    });
  });
}
