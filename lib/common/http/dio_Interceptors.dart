import 'package:dio/dio.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';

import 'http_result.dart';

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll(_createHeaders());
    super.onRequest(options, handler);
  }

  static Map<String, dynamic> _createHeaders() {
    final Map<String, dynamic> headers = <String, dynamic>{};

    final String? token = AppData.instance.loginInfo?.token;
    if (token != null) {
      headers['token'] = token;
    }

    return headers;
  }
}

class ResponseInterceptor extends Interceptor {
  ResponseInterceptor(this.successCode);

  final int successCode;

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.data is Map) {
      final HttpResult result =
          HttpResult.fromJson(response.data as Map<String, dynamic>);

      if (result.code != successCode) {
        throw result.exception!;
      }

      response.data = result;
    }
    return super.onResponse(response, handler);
  }
}

class MyLogInterceptor extends Interceptor {
  MyLogInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
    this.logPrint = print,
  });

  /// Print request [Options]
  final bool request;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool error;

  /// Log printer; defaults print log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file, for example:
  ///```dart
  ///  var file=File("./log.txt");
  ///  var sink=file.openWrite();
  ///  dio.interceptors.add(LogInterceptor(logPrint: sink.writeln));
  ///  ...
  ///  await sink.close();
  ///```
  final void Function(Object object) logPrint;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logPrint('*** Request ***');
    _printKV('uri', options.uri);
    //options.headers;

    if (request) {
      _printKV('method', options.method);
      _printKV('responseType', options.responseType.toString());
      _printKV('followRedirects', options.followRedirects);
      _printKV('connectTimeout', options.connectTimeout);
      _printKV('sendTimeout', options.sendTimeout);
      _printKV('receiveTimeout', options.receiveTimeout);
      _printKV(
          'receiveDataWhenStatusError', options.receiveDataWhenStatusError);
      _printKV('extra', options.extra);
    }
    if (requestHeader) {
      Logger.logHttp('headers:');
      options.headers.forEach((String key, dynamic v) => _printKV(' $key', v));
    }
    if (requestBody) {
      Logger.logHttp('data:');
      if (options.data != null) _printAll(options.data);
    }
    Logger.logHttp('');

    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    Logger.logHttp('*** Response ***');
    _printResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (error) {
      Logger.logHttp('*** DioError ***:');
      Logger.logHttp('uri: ${err.requestOptions.uri}');
      Logger.logHttp('$err');
      if (err.response != null) {
        _printResponse(err.response!);
      }
      Logger.logHttp('');
    }

    handler.next(err);
  }

  void _printResponse(Response<dynamic> response) {
    _printKV('uri', response.requestOptions.uri);
    if (responseHeader) {
      _printKV('statusCode', response.statusCode);
      if (response.isRedirect == true) {
        _printKV('redirect', response.realUri);
      }

      Logger.logHttp('headers:');
      response.headers.forEach(
          (String key, dynamic v) => _printKV(' $key', v.join('\r\n\t')));
    }
    if (responseBody) {
      Logger.logHttp('Response Text:');
      _printAll(response.toString());
    }
    Logger.logHttp('');
  }

  void _printKV(String key, Object? v) {
    Logger.logHttp('$key: $v');
  }

  void _printAll(dynamic msg) {
    msg.toString().split('\n').forEach(Logger.logHttp);
  }
}
