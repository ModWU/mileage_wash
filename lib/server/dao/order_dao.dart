import 'package:dio/dio.dart';
import 'package:mileage_wash/common/http/http_result.dart';
import 'package:mileage_wash/common/http/http_utils.dart';
import 'package:mileage_wash/constant/http_apis.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/state/order_state.dart';

class OrderDao {
  OrderDao._();

  static Future<List<OrderInfo>> queryOrderList(
      {required OrderState orderState,
      required int curPage,
      required int pageSize}) async {
    final Response<HttpResult> response = await HttpUtil.post<HttpResult>(
        HTTPApis.orderList,
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
}
