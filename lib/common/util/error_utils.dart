import 'package:dio/dio.dart';
import 'package:mileage_wash/common/http/http_exception.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';

class ErrorUtils {
  ErrorUtils._();

  static int? showToastWhenHttpError(Object errorObj, String otherErrMsg) {
    if (errorObj is DioError && errorObj.error is HttpResultException) {
      final HttpResultException exception = errorObj.error as HttpResultException;
      ToastUtils.showToast(exception.error);
      return exception.code;
    } else {
      ToastUtils.showToast(otherErrMsg);
    }
  }

}