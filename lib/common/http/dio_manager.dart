import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mileage_wash/constant/http_apis.dart';
import 'package:mileage_wash/model/global/app_data.dart';

import 'dio_Interceptors.dart';

class DioManager {
  DioManager._() {
    _init(successCode: successCode);
  }

  static late final DioManager instance = DioManager._();

  late Dio _rootDio;

  final int connectTimeout = 5000;
  final int sendTimeout = 5000;
  final int receiveTimeout = 3000;

  final AppData appData = AppData.instance;

  static int successCode = 0;

  DefaultHttpClientAdapter get _defaultHttpClientAdapter =>
      _rootDio.httpClientAdapter as DefaultHttpClientAdapter;

  static Dio get dio => instance._rootDio;

  void _init({int successCode = 0, List<Interceptor>? interceptors}) {
    final BaseOptions options = BaseOptions(
      baseUrl: HTTPApis.beta,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      responseType: ResponseType.json,
    );
    final Dio dio = Dio(options);
    _rootDio = dio;

    _setHttpClientCreate(appData.httpProxy);

    dio.interceptors.addAll(<Interceptor>[
      HeaderInterceptor(),
      if (kDebugMode) MyLogInterceptor(requestBody: true, responseBody: true),
      ResponseInterceptor(successCode),
      if (interceptors != null) ...interceptors,
    ]);
  }

  void _setHttpClientCreate(String? proxy) {
    if (proxy != null) {
      _defaultHttpClientAdapter.onHttpClientCreate = (HttpClient client) {
        client.findProxy = (Uri uri) => 'PROXY $proxy';

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };
    }
  }
}
