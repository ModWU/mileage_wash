import 'package:dio/dio.dart';
import 'package:mileage_wash/model/global/app_data.dart';

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