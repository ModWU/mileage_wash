import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mileage_wash/common/http/dio_manager.dart';
import 'package:mileage_wash/server/interceptor/response_interceptor.dart';
import 'package:mileage_wash/server/storage/app_storage.dart';

import 'interceptor/header_interceptor.dart';
import 'interceptor/log_interceptor.dart';

class AppServer {
  AppServer._();

  static Future<void> initialize() async {
    DioManager.dio.interceptors.addAll(<Interceptor>[
      HeaderInterceptor(),
      if (kDebugMode) MyLogInterceptor(requestBody: true, responseBody: true),
      ResponseInterceptor(),
    ]);
    await AppStorage.initialize();
  }
}
