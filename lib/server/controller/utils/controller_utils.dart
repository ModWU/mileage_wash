import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/error_utils.dart';

class ControllerUtils {
  ControllerUtils._();

  static Future<T?> handleDao<T>(
    BuildContext context, {
    required Future<T> daoFuture,
    required bool allowThrowError,
    required String errorTips,
  }) async {
    try {
      return daoFuture;
    } catch (error, stack) {
      Logger.reportDartError(error, stack);

      if (error is! DioError || error.type != DioErrorType.cancel) {
        ErrorUtils.showToastWhenHttpError(error, errorTips);

        if (allowThrowError) {
          rethrow;
        }
      }
    }
  }
}
