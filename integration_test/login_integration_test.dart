import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/university_system_ui_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:university_system_front/Adapter/secure_storage_adapter.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Util/provider_logger.dart';
import 'package:university_system_front/main.dart';

import 'integration_test_util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    registerGoRouterForIntegrationTest();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('Login integration test', () {
    setUpAll(() async {
      await SecureStorageAdapter().deleteValue("jwt");
    });

    tearDown(() async {
      await SecureStorageAdapter().deleteValue("jwt");
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

      var currentRute = GetIt.instance.get<GoRouter>().routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.animatedLogin.routeName);
      final storedBearerToken = await SecureStorageAdapter().readValue("jwt");
      expect(storedBearerToken, null);
    });

    testWidgets('login with correct credentials', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

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

      var currentRute = GetIt.instance.get<GoRouter>().routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.home.routeName);

      final storedBearerToken = await SecureStorageAdapter().readValue("jwt");
      expect(storedBearerToken, isNotNull);
      expect(storedBearerToken, isNotEmpty);
    });

    testWidgets('"Invalid email" when no email error at login', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

      await widgetTester.ensureVisible(filledButtonFinder);
      await widgetTester.tap(filledButtonFinder);
      await widgetTester.pumpAndSettle();

      //Error when no email
      var invalidEmailTextFinder = find.text(AppLocalizations.of(widgetTester.element(filledButtonFinder))!.loginEmailError);
      expect(invalidEmailTextFinder, findsOne);

      await widgetTester.pumpAndSettle();

      var currentRute = GetIt.instance.get<GoRouter>().routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.animatedLogin.routeName);
      final storedBearerToken = await SecureStorageAdapter().readValue("jwt");
      expect(storedBearerToken, isNull);
    });

    testWidgets('"loginError" when no password error at login', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

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

      var currentRute = GetIt.instance.get<GoRouter>().routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.animatedLogin.routeName);

      final storedBearerToken = await SecureStorageAdapter().readValue("jwt");
      expect(storedBearerToken, isNull);
    });

    testWidgets('"loginError" when incorrect password error at login', (widgetTester) async {
      await widgetTester.pumpWidget(ProviderScope(observers: [ProviderLogger()], child: const UniversitySystemUi()));

      await widgetTester.pumpAndSettle(const Duration(milliseconds: 150));

      final textFormFieldFinder = find.byType(TextFormField);
      final filledButtonFinder = find.byType(FilledButton);

      expect(textFormFieldFinder, findsExactly(2));
      expect(filledButtonFinder, findsOne);

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

      var currentRute = GetIt.instance.get<GoRouter>().routeInformationProvider.value.uri.path;
      expect(currentRute, GoRouterRoutes.animatedLogin.routeName);

      final storedBearerToken = await SecureStorageAdapter().readValue("jwt");
      expect(storedBearerToken, isNull);
    });
  });
}
