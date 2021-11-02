import 'package:flutter/material.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/server/state/http_request_state.dart';

abstract class HomeNotifier with ChangeNotifier {
  HomeNotifier(this.state);

  final OrderState state;

  Object? _error;
  bool get hasError => _error != null;

  bool get hasData => _orderData?.isNotEmpty ?? false;

  int get size => _orderData?.length ?? 0;

  void notifyError(Object? error) {
    if (_error == error) {
      return;
    }

    _error = error;
    notifyListeners();
  }

  int? _curPage;
  int? get curPage => _curPage;

  List<OrderInfo>? _orderData;
  List<OrderInfo>? get orderData => _orderData;

  void addData(List<OrderInfo> data, {int? curPage}) {
    if (data.isEmpty) {
      return;
    }

    _error = null;

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
