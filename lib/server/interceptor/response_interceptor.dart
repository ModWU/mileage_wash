import 'package:dio/dio.dart';
import 'package:mileage_wash/common/http/http_result.dart';
import 'package:mileage_wash/constant/http_result_code.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.data is Map) {
      final HttpResult result =
          HttpResult.fromJson(response.data as Map<String, dynamic>);

      if (result.code != HttpResultCode.success) {
        throw result.exception!;
      }

      response.data = result;
    }
    return super.onResponse(response, handler);
  }
}
