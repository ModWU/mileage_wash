import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUtils {
  AppUtils._();

  static Locale getLocalByCode(String code) {
    return Locale.fromSubtags(languageCode: code);
  }

  static void exit() {
    if (Platform.isIOS) {
      exit();
    } else if (Platform.isAndroid) {
      SystemNavigator.pop();
    }
  }
}
