import 'package:flutter/material.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/state/order_state.dart';

abstract class HomeNotifier with ChangeNotifier {
  HomeNotifier(this.state);

  final OrderState state;

  bool get hasData => _orderData?.isNotEmpty ?? false;

  int get size => _orderData?.length ?? 0;

  int? _curPage;
  int? get curPage => _curPage;

  int get index => state.index;

  List<OrderInfo>? _orderData;
  List<OrderInfo>? get orderData => _orderData;

  void resetData() {
    if (_orderData == null) {
      return;
    }

    _orderData = null;
    // notifyListeners();
  }

  void refreshData(List<OrderInfo> data) {
    List<OrderInfo>? orderData = _orderData;
    if (orderData != null) {
      orderData.clear();
    }
    _curPage = 0;

    orderData ??= _orderData = <OrderInfo>[];

    orderData.addAll(data);
    notifyListeners();
  }

  void addData(List<OrderInfo> data, {int? curPage}) {
    if (data.isEmpty) {
      return;
    }

    curPage ??= (_curPage ?? -1) + 1;
    _curPage = curPage;

    List<OrderInfo>? orderData = _orderData;
    orderData ??= _orderData = <OrderInfo>[];
    orderData.addAll(data);
    notifyListeners();
  }
}

class HomeWaitingNotifier extends HomeNotifier {
  HomeWaitingNotifier() : super(OrderState.waiting);
}

class HomeWashingNotifier extends HomeNotifier {
  HomeWashingNotifier() : super(OrderState.washing);
}

class HomeDoneNotifier extends HomeNotifier {
  HomeDoneNotifier() : super(OrderState.done);
}

class HomeCancelledNotifier extends HomeNotifier {
  HomeCancelledNotifier() : super(OrderState.cancelled);
}
