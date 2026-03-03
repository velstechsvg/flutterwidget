import 'dart:ui';

import 'package:get/get.dart';

import 'lang/ar.dart';
import 'lang/en.dart';
import 'lang/es.dart';
import 'lang/fr.dart';
import 'lang/hr.dart';
import 'lang/id.dart';
import 'lang/ja.dart';
import 'lang/ru.dart';


class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', '');

  // fallbackLocale saves the day when the locale gets in trouble
  static const fallbackLocale = Locale('es', '');

  // Supported languages
  // Needs to be same order with locales
  static final langs = [
    'en',
    'es',
    'fr',
    'hr',
    'id',
    'ja',
    'ru',
    'ar'
  ];

  // Supported locales
  // Needs to be same order with langs
  static final locales = [
    const Locale('en', ''),
    const Locale('es', ''),
    const Locale('fr', ''),
    const Locale('hr', ''),
    const Locale('id', ''),
    const Locale('ja', ''),
    const Locale('ru', ''),
    const Locale('ar', ''),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
    'en': enLang,
    'es': esLang,
    'fr': frLang,
    'hr': hrLang,
    'id': idLang,
    'ja': jaLang,
    'ru': ruLang,
    'ar': arLang,
  };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    Get.updateLocale(locale);
  }

  // Finds language in `langs` list and returns it as Locale
  Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale!;
  }
}
