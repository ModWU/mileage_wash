import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/error_utils.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/http/upload_result.dart';
import 'package:mileage_wash/server/dao/order_dao.dart';
import 'package:mileage_wash/server/dao/upload_dao.dart';
import 'package:mileage_wash/state/car_state.dart';
import 'package:mileage_wash/state/order_state.dart';

mixin HomeController {
  static Future<List<OrderInfo>?> queryOrderList(
    BuildContext context, {
    required OrderState orderState,
    required int curPage,
    required int pageSize,
    bool allowThrowError = false,
  }) async {
    try {
      final List<OrderInfo> orderInfo = await OrderDao.queryOrderList(
          orderState: orderState, curPage: curPage, pageSize: pageSize);

      return orderInfo;
    } catch (error, stack) {
      Logger.reportDartError(error, stack);
      ErrorUtils.showToastWhenHttpError(error, S.of(context).order_query_error);

      if (allowThrowError) {
        rethrow;
      }
    }
  }

  static Future<UploadResult?> uploadPhoto(
    BuildContext context, {
    required String type,
    required XFile file,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    bool allowThrowError = false,
  }) async {
    try {
      return UploadDao.uploadPhoto(
          type: type,
          file: File(file.path),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress);
    } catch (error, stack) {
      Logger.reportDartError(error, stack);

      if (error is! DioError || error.type != DioErrorType.cancel) {
        ErrorUtils.showToastWhenHttpError(error, S.of(context).photo_upload_error);
      }

      if (allowThrowError) {
        rethrow;
      }
    }
    return null;
  }

  static Future<void> saveOrder(
    BuildContext context, {
    required OrderInfo orderInfo,
    required List<String> filePaths,
    required String photoListType,
    required CarState carState,
    CancelToken? cancelToken,
    bool allowThrowError = false,
  }) async {
    try {
      final int data = await OrderDao.saveOrder(
        orderInfo: orderInfo,
        filePaths: filePaths.join(';'),
        photoListType: photoListType,
        carState: carState,
        cancelToken: cancelToken,
      );
    } catch (error, stack) {
      Logger.reportDartError(error, stack);

      if (error is! DioError || error.type != DioErrorType.cancel) {
        ErrorUtils.showToastWhenHttpError(error, S.of(context).order_save_error);
      }

      if (allowThrowError) {
        rethrow;
      }
    }
  }
}
