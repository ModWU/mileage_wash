import 'package:dio/dio.dart';

import 'dio_manager.dart';

class HttpUtil {
  HttpUtil._();

  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (headers?.isNotEmpty ?? false) {
      options ??= Options();
      options.headers = headers;
    }
    return DioManager.dio.get<T>(
      path,
      queryParameters: params,
      cancelToken: cancelToken,
      options: options,
    );
  }

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return DioManager.dio.post<T>(
      path,
      queryParameters: params,
      data: data,
      cancelToken: cancelToken,
      options: options,
    );
  }

  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return DioManager.dio.put<T>(
      path,
      queryParameters: params,
      data: data,
      cancelToken: cancelToken,
      options: options,
    );
  }

  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return DioManager.dio.delete<T>(
      path,
      queryParameters: params,
      data: data,
      cancelToken: cancelToken,
      options: options,
    );
  }
}
