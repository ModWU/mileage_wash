import 'package:dio/dio.dart';
import 'package:mileage_wash/common/http/http_result.dart';
import 'package:mileage_wash/constant/http_result_code.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/server/storage/app_storage.dart';

typedef TokenExpiredCallback = void Function(int code, String oldToken);

class TokenInterceptor extends Interceptor {
  TokenInterceptor([this.onTokenExpired]);

  final TokenExpiredCallback? onTokenExpired;

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    HttpResult? httpResult;
    if (response.data is Map) {
      httpResult = HttpResult.fromJson(response.data as Map<String, dynamic>);
    } else if (response.data is HttpResult) {
      httpResult = response.data as HttpResult;
    }

    if (httpResult != null &&
        httpResult.code == HttpResultCode.tokenExpired &&
        AppData.instance.loginInfo != null) {
      final String oldToken = AppData.instance.loginInfo!.token;
      AppStorage.updateLoginInfo(null);
      onTokenExpired?.call(httpResult.code, oldToken);
    }

    return super.onResponse(response, handler);
  }
}
