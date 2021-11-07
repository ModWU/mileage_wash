import 'package:dio/dio.dart';
import 'package:mileage_wash/common/http/http_result.dart';
import 'package:mileage_wash/common/http/http_utils.dart';
import 'package:mileage_wash/constant/http_apis.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/state/car_state.dart';
import 'package:mileage_wash/state/order_state.dart';

class OrderDao {
  OrderDao._();

  static Future<List<OrderInfo>> queryOrderList({
    required OrderState orderState,
    required int curPage,
    required int pageSize,
    CancelToken? cancelToken,
  }) async {
    final Response<HttpResult> response = await HttpUtil.post<HttpResult>(
        HTTPApis.orderList,
        cancelToken: cancelToken,
        data: <String, dynamic>{
          'state': orderState.httpRequestCode,
          'curPage': curPage,
          'pageSize': pageSize
        });

    final HttpResult httpResult = response.data!;

    final List<OrderInfo> orderInfoList = <OrderInfo>[];

    final List<dynamic> orderInfoDataList = httpResult.data as List<dynamic>;

    for (final dynamic orderInfoData in orderInfoDataList) {
      orderInfoList
          .add(OrderInfo.fromJson(orderInfoData as Map<String, dynamic>));
    }

    return orderInfoList;
  }

  static Future<int> saveOrder({
    required OrderInfo orderInfo,
    required String filePaths,
    required String photoListType,
    required CarState carState,
    CancelToken? cancelToken,
  }) async {
    final Response<HttpResult> response =
        await HttpUtil.post(HTTPApis.saveOrder, data: <String, dynamic>{
      'id': orderInfo.id,
      'state': orderInfo.state,
      'carInfo': carState.value,
      photoListType: filePaths,
    });

    final HttpResult httpResult = response.data!;

    final int data = httpResult.data as int;
    return data;
  }
}
