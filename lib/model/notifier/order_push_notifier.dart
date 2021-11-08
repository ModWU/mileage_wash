import 'package:flutter/cupertino.dart';
import 'package:mileage_wash/model/notification_order_info.dart';

class OrderPushNotifier with ChangeNotifier {
  List<NotificationOrderInfo>? _notificationInfoList = [
    NotificationOrderInfo(orderNumber: "vc", carAddress: "lkfdjlajlfd", carNumber: "fkla8989", appointmentTime: "2012-10-9 23:01:04"),
    NotificationOrderInfo(orderNumber: "vczvczvc", carAddress: "fdafdafd", carNumber: "vc", appointmentTime: "2012-10-9 23:01:04"),
    NotificationOrderInfo(orderNumber: "cv", carAddress: "fda", carNumber: "fda44", appointmentTime: "2012-10-9 23:01:04"),
    NotificationOrderInfo(orderNumber: "sddfd3435", carAddress: "vdafd", carNumber: "vc23", appointmentTime: "2012-10-9 23:01:04"),
    NotificationOrderInfo(orderNumber: "vcv", carAddress: "vda", carNumber: "vc13", appointmentTime: "2012-10-9 23:01:04"),
    NotificationOrderInfo(orderNumber: "vcz454", carAddress: "vcz", carNumber: "vc3", appointmentTime: "2012-10-9 23:01:04"),
    NotificationOrderInfo(orderNumber: "vc2354", carAddress: "trsr", carNumber: "vczzd5", appointmentTime: "2012-10-9 23:01:04"),
  ];

  int get size => _notificationInfoList?.length ?? 0;

  NotificationOrderInfo? getNotificationInfo(int index) {
    assert(index >= 0);
    final List<NotificationOrderInfo>? notificationInfoList =
        _notificationInfoList;
    if (notificationInfoList == null || notificationInfoList.length <= index) {
      return null;
    }
    return notificationInfoList[index];
  }

  void add(NotificationOrderInfo notificationOrderInfo) {
    _notificationInfoList ??= <NotificationOrderInfo>[];
    _notificationInfoList!.add(notificationOrderInfo);
    notifyListeners();
  }

  void remove(NotificationOrderInfo notificationOrderInfo) {
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
