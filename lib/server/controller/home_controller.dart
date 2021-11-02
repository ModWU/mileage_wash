import 'package:flutter/material.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/common/util/error_utils.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/server/dao/order_dao.dart';
import 'package:mileage_wash/server/state/http_request_state.dart';

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
      ErrorUtils.showToastWhenHttpError(error, '查询订单异常!');

      if (allowThrowError) {
        rethrow;
      }
    }
  }
}
