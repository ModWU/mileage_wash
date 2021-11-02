// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Mileage Wash`
  String get title {
    return Intl.message(
      'Mileage Wash',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `home`
  String get bottom_navigation_home_title {
    return Intl.message(
      'home',
      name: 'bottom_navigation_home_title',
      desc: '',
      args: [],
    );
  }

  /// `me`
  String get bottom_navigation_me_title {
    return Intl.message(
      'me',
      name: 'bottom_navigation_me_title',
      desc: '',
      args: [],
    );
  }

  /// `Mileage Wash`
  String get home_title {
    return Intl.message(
      'Mileage Wash',
      name: 'home_title',
      desc: '',
      args: [],
    );
  }

  /// `waiting`
  String get home_tab_waiting {
    return Intl.message(
      'waiting',
      name: 'home_tab_waiting',
      desc: '',
      args: [],
    );
  }

  /// `washing`
  String get home_tab_washing {
    return Intl.message(
      'washing',
      name: 'home_tab_washing',
      desc: '',
      args: [],
    );
  }

  /// `done`
  String get home_tab_done {
    return Intl.message(
      'done',
      name: 'home_tab_done',
      desc: '',
      args: [],
    );
  }

  /// `cancelled`
  String get home_tab_cancelled {
    return Intl.message(
      'cancelled',
      name: 'home_tab_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login_title {
    return Intl.message(
      'Login',
      name: 'login_title',
      desc: '',
      args: [],
    );
  }

  /// `phone`
  String get login_phone_text {
    return Intl.message(
      'phone',
      name: 'login_phone_text',
      desc: '',
      args: [],
    );
  }

  /// `Please input phone`
  String get login_phone_hint_text {
    return Intl.message(
      'Please input phone',
      name: 'login_phone_hint_text',
      desc: '',
      args: [],
    );
  }

  /// `Illegal phone number `
  String get login_phone_error {
    return Intl.message(
      'Illegal phone number ',
      name: 'login_phone_error',
      desc: '',
      args: [],
    );
  }

  /// `password`
  String get login_password_text {
    return Intl.message(
      'password',
      name: 'login_password_text',
      desc: '',
      args: [],
    );
  }

  /// `Please input password`
  String get login_password_hint_text {
    return Intl.message(
      'Please input password',
      name: 'login_password_hint_text',
      desc: '',
      args: [],
    );
  }

  /// `The password must contain at least six characters`
  String get login_password_length_error {
    return Intl.message(
      'The password must contain at least six characters',
      name: 'login_password_length_error',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login_submit_text {
    return Intl.message(
      'Login',
      name: 'login_submit_text',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get me_logout_text {
    return Intl.message(
      'Logout',
      name: 'me_logout_text',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
