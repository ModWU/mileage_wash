import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:mileage_wash/constant/http_apis.dart';
import 'package:mileage_wash/model/global/app_data.dart';

class DioManager {
  DioManager._() {
    _init();
  }

  static late final DioManager instance = DioManager._();

  late Dio _rootDio;

  final int connectTimeout = 5000;
  final int sendTimeout = 5000;
  final int receiveTimeout = 3000;

  final AppData appData = AppData.instance;

  DefaultHttpClientAdapter get _defaultHttpClientAdapter =>
      _rootDio.httpClientAdapter as DefaultHttpClientAdapter;

  static Dio get dio => instance._rootDio;

  void _init() {
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
