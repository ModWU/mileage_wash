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

  /// `arrived`
  String get home_order_item_waiting_btn {
    return Intl.message(
      'arrived',
      name: 'home_order_item_waiting_btn',
      desc: '',
      args: [],
    );
  }

  /// `washed`
  String get home_order_item_washing_btn {
    return Intl.message(
      'washed',
      name: 'home_order_item_washing_btn',
      desc: '',
      args: [],
    );
  }

  /// `done`
  String get home_order_item_done_btn {
    return Intl.message(
      'done',
      name: 'home_order_item_done_btn',
      desc: '',
      args: [],
    );
  }

  /// `cancelled`
  String get home_order_item_cancelled_btn {
    return Intl.message(
      'cancelled',
      name: 'home_order_item_cancelled_btn',
      desc: '',
      args: [],
    );
  }

  /// `Check vehicle condition before washing`
  String get washing_review_title {
    return Intl.message(
      'Check vehicle condition before washing',
      name: 'washing_review_title',
      desc: '',
      args: [],
    );
  }

  /// `Before washing, please check the appearance of the vehicle for scratches and bumps, and take photos of the front 45° Angle and rear 45° Angle of the vehicle! `
  String get washing_review_tip {
    return Intl.message(
      'Before washing, please check the appearance of the vehicle for scratches and bumps, and take photos of the front 45° Angle and rear 45° Angle of the vehicle! ',
      name: 'washing_review_tip',
      desc: '',
      args: [],
    );
  }

  /// `*Car Status:`
  String get washing_review_car_status_title {
    return Intl.message(
      '*Car Status:',
      name: 'washing_review_car_status_title',
      desc: '',
      args: [],
    );
  }

  /// `well`
  String get washing_review_car_status_well {
    return Intl.message(
      'well',
      name: 'washing_review_car_status_well',
      desc: '',
      args: [],
    );
  }

  /// `a scratch`
  String get washing_review_car_status_scratch {
    return Intl.message(
      'a scratch',
      name: 'washing_review_car_status_scratch',
      desc: '',
      args: [],
    );
  }

  /// `a collision`
  String get washing_review_car_status_collision {
    return Intl.message(
      'a collision',
      name: 'washing_review_car_status_collision',
      desc: '',
      args: [],
    );
  }

  /// `Photos have reached their limit!`
  String get washing_review_car_pick_picture_limit_error {
    return Intl.message(
      'Photos have reached their limit!',
      name: 'washing_review_car_pick_picture_limit_error',
      desc: '',
      args: [],
    );
  }

  /// `*Please upload photos of vehicle condition:`
  String get washing_review_car_photo_upload_title {
    return Intl.message(
      '*Please upload photos of vehicle condition:',
      name: 'washing_review_car_photo_upload_title',
      desc: '',
      args: [],
    );
  }

  /// `Take a close-up of the scratches and bumps, please`
  String get washing_review_car_photo_upload_tip {
    return Intl.message(
      'Take a close-up of the scratches and bumps, please',
      name: 'washing_review_car_photo_upload_tip',
      desc: '',
      args: [],
    );
  }

  /// `Load fail`
  String get washing_review_car_photo_upload_fail_tip {
    return Intl.message(
      'Load fail',
      name: 'washing_review_car_photo_upload_fail_tip',
      desc: '',
      args: [],
    );
  }

  /// `Upload photos for washing`
  String get washing_review_car_submit_button {
    return Intl.message(
      'Upload photos for washing',
      name: 'washing_review_car_submit_button',
      desc: '',
      args: [],
    );
  }

  /// `Please take pictures!`
  String get washing_review_car_submit_no_data {
    return Intl.message(
      'Please take pictures!',
      name: 'washing_review_car_submit_no_data',
      desc: '',
      args: [],
    );
  }

  /// `Please remove or reload the failed loading photos first!`
  String get washing_review_car_submit_progress_error {
    return Intl.message(
      'Please remove or reload the failed loading photos first!',
      name: 'washing_review_car_submit_progress_error',
      desc: '',
      args: [],
    );
  }

  /// `Please wait, photos are being uploaded...`
  String get washing_review_car_submit_progress_uploading_tip {
    return Intl.message(
      'Please wait, photos are being uploaded...',
      name: 'washing_review_car_submit_progress_uploading_tip',
      desc: '',
      args: [],
    );
  }

  /// `Pick photo error!`
  String get washing_review_car_pick_photo_error {
    return Intl.message(
      'Pick photo error!',
      name: 'washing_review_car_pick_photo_error',
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

  /// `personal center`
  String get me_title {
    return Intl.message(
      'personal center',
      name: 'me_title',
      desc: '',
      args: [],
    );
  }

  /// `order receiving`
  String get me_order_state_receiving {
    return Intl.message(
      'order receiving',
      name: 'me_order_state_receiving',
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

  /// `notification`
  String get notification_title {
    return Intl.message(
      'notification',
      name: 'notification_title',
      desc: '',
      args: [],
    );
  }

  /// `You have a new order!`
  String get notification_item_tips {
    return Intl.message(
      'You have a new order!',
      name: 'notification_item_tips',
      desc: '',
      args: [],
    );
  }

  /// `order number: `
  String get notification_item_order_number_title {
    return Intl.message(
      'order number: ',
      name: 'notification_item_order_number_title',
      desc: '',
      args: [],
    );
  }

  /// `car address: `
  String get notification_item_car_address_title {
    return Intl.message(
      'car address: ',
      name: 'notification_item_car_address_title',
      desc: '',
      args: [],
    );
  }

  /// `car number: `
  String get notification_item_car_number_title {
    return Intl.message(
      'car number: ',
      name: 'notification_item_car_number_title',
      desc: '',
      args: [],
    );
  }

  /// `appointment time：`
  String get notification_item_appointment_time_title {
    return Intl.message(
      'appointment time：',
      name: 'notification_item_appointment_time_title',
      desc: '',
      args: [],
    );
  }

  /// `details`
  String get notification_item_order_details_title {
    return Intl.message(
      'details',
      name: 'notification_item_order_details_title',
      desc: '',
      args: [],
    );
  }

  /// `Press exit again`
  String get exit_tip_twice_click {
    return Intl.message(
      'Press exit again',
      name: 'exit_tip_twice_click',
      desc: '',
      args: [],
    );
  }

  /// `Login error!`
  String get login_error {
    return Intl.message(
      'Login error!',
      name: 'login_error',
      desc: '',
      args: [],
    );
  }

  /// `Logout error!`
  String get logout_error {
    return Intl.message(
      'Logout error!',
      name: 'logout_error',
      desc: '',
      args: [],
    );
  }

  /// `Error querying order!`
  String get order_query_error {
    return Intl.message(
      'Error querying order!',
      name: 'order_query_error',
      desc: '',
      args: [],
    );
  }

  /// `Error saving order!`
  String get order_save_error {
    return Intl.message(
      'Error saving order!',
      name: 'order_save_error',
      desc: '',
      args: [],
    );
  }

  /// `Error uploading photo!`
  String get photo_upload_error {
    return Intl.message(
      'Error uploading photo!',
      name: 'photo_upload_error',
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
