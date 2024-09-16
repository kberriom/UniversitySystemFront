import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

///Current [ThemeMode] of the app, does _not_ returns the current [Brightness]
@riverpod
class CurrentThemeMode extends _$CurrentThemeMode {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  ///Current [Brightness] is required as [ThemeMode] can be [ThemeMode.system] which does not indicate current [Brightness].
  Brightness changeThemeMode(Brightness currentBrightness) {
    switch (state) {
      case ThemeMode.system:
        switch (currentBrightness) {
          case Brightness.dark:
            state = ThemeMode.light;
            return Brightness.light;
          case Brightness.light:
            state = ThemeMode.dark;
            return Brightness.dark;
        }
      case ThemeMode.light:
        state = ThemeMode.dark;
        return Brightness.dark;
      case ThemeMode.dark:
        state = ThemeMode.light;
        return Brightness.light;
    }
  }
}
