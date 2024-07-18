import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

@riverpod
class CurrentThemeMode extends _$CurrentThemeMode {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void changeThemeMode() {
    switch (state) {
      case ThemeMode.system:
        state = ThemeMode.light;
      case ThemeMode.light:
        state = ThemeMode.dark;
      case ThemeMode.dark:
        state = ThemeMode.light;
    }
  }
}
