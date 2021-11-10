import 'package:flutter/cupertino.dart';
import 'package:mileage_wash/model/notification_order_info.dart';
import 'package:mileage_wash/state/order_push_state.dart';

class OrderPushNotifier with ChangeNotifier {
  List<NotificationOrderInfo>? _notificationInfoList;

  int get size => _notificationInfoList?.length ?? 0;

  late NotificationState _notificationState = NotificationState.hide;
  NotificationState get notificationState => _notificationState;
  set notificationState(NotificationState value) {
    if (value == _notificationState) {
      return;
    }
    _notificationState = value;
    notifyListeners();
  }

  NotificationOrderInfo? getNotificationInfo(int index) {
    assert(index >= 0);
    final List<NotificationOrderInfo>? notificationInfoList =
        _notificationInfoList;
    if (notificationInfoList == null || notificationInfoList.length <= index) {
      return null;
    }
    return notificationInfoList[index];
  }

  void push(NotificationOrderInfo notificationOrderInfo) {
    _notificationInfoList ??= <NotificationOrderInfo>[];
    _notificationInfoList!.add(notificationOrderInfo);
    _notificationInfoList!.sort();
    if (notificationOrderInfo.orderPushState == OrderPushState.add) {
      _notificationState = NotificationState.newAdd;
    } else {
      _notificationState = NotificationState.newCancel;
    }
    notifyListeners();
  }

  void removeAllNotifications() {
    _notificationInfoList = null;

    if (_notificationState != NotificationState.hide) {
      _notificationState = NotificationState.hide;
    }
    notifyListeners();
  }

  void removeNotification(NotificationOrderInfo notificationOrderInfo) {
    final List<NotificationOrderInfo>? notificationInfoList =
        _notificationInfoList;
    if (notificationInfoList == null) {
      return;
    }
    final bool isRemoved = notificationInfoList.remove(notificationOrderInfo);
    if (isRemoved) {
      notifyListeners();
    }
  }
}

enum NotificationState { newAdd, newCancel, hide }
