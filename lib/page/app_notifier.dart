import 'package:dio/dio.dart';
import 'package:mileage_wash/common/listener/data_notifier.dart';

enum NotificationType { loginPop }

class AppNotifier with DataNotifier {
  void addLoginPopListener(VoidCallback listener) {
    addListener(NotificationType.loginPop, listener);
  }

  void doLoginPop() {
    notifyListeners(NotificationType.loginPop);
  }
}
