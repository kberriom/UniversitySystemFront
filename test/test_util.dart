import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

///Initializes all application wide dependencies that require a reset after being used,
///this guarantees that all tests are independent.
///
/// DO NOT REUSE THE [ProviderContainer]
///
/// returns a Riverpod [ProviderContainer]
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  FlutterSecureStorage.setMockInitialValues({});
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  addTearDown(() async {
    container.dispose;
    await GetIt.instance.reset();
  });

  return container;
}
