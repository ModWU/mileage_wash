import 'package:dio/dio.dart';
import 'package:mileage_wash/common/listener/data_notifier.dart';

enum NotificationType { loginPop, notificationPop }

class AppNotifier with DataNotifier {
  void addLoginPopListener(VoidCallback listener) {
    addListener(NotificationType.loginPop, listener);
  }

  void addNotificationPopListener(VoidCallback listener) {
    addListener(NotificationType.notificationPop, listener);
  }

  void doLoginPop() {
    notifyListeners(NotificationType.loginPop);
  }

  void doNotificationPop() {
    notifyListeners(NotificationType.notificationPop);
  }
}
