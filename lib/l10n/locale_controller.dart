import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

enum UniSystemLocale {
  en(locale: Locale("en"), localeString: "en", localeName: "English"),
  es(locale: Locale("es"), localeString: "es", localeName: "Español"),
  ;

  final Locale locale;
  final String localeString;
  final String localeName;

  const UniSystemLocale({
    required this.locale,
    required this.localeString,
    required this.localeName,
  });
}

@Riverpod(keepAlive: true)
class CurrentLocale extends _$CurrentLocale {
  static final HashSet<Locale> _allLocales = HashSet.of(UniSystemLocale.values.map((e) => e.locale));

  @override
  Locale build() {
    findSystemLocale();
    final locale = Locale(Locale(Intl.systemLocale).toLanguageTag().substring(0, 2));

    if (_allLocales.contains(locale)) {
      return locale;
    } else {
      return UniSystemLocale.en.locale;
    }
  }

  void changeLocale(UniSystemLocale newLocale) {
    state = newLocale.locale;
  }
}
