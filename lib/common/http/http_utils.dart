import 'dart:io';

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

  static Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final Map<String, dynamic> dataMap = <String, dynamic>{
      'file': await MultipartFile.fromFile(file.path),
    };

    if (data != null) {
      dataMap.addAll(data);
    }

    final FormData formData = FormData.fromMap(dataMap);

    return DioManager.dio.post<T>(path,
        queryParameters: params,
        data: formData,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress);
  }

  static Future<Response<T>> uploadFiles<T>(
    String path,
    List<File> files, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    assert(files.isNotEmpty);

    final Map<String, dynamic> dataMap = <String, dynamic>{
      'files': <MultipartFile>[
        for (final File file in files) await MultipartFile.fromFile(file.path)
      ],
    };

    if (data != null) {
      dataMap.addAll(data);
    }

    final FormData formData = FormData.fromMap(dataMap);

    return DioManager.dio.post<T>(path,
        queryParameters: params,
        data: formData,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress);
  }
}
