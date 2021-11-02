import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mileage_wash/resource/colors.dart';
import 'package:mileage_wash/resource/styles.dart';

class AppUtils {
  AppUtils._();

  static Locale getLocalByCode(String code) {
    return Locale.fromSubtags(languageCode: code);
  }
}
