import 'package:mileage_wash/common/listener/data_notifier.dart';

import '../http/login_info.dart';

enum AppDataType { httpProxy, loginInfo, lastLoginInfo }

class AppData with DataNotifier {
  AppData._();

  static late final AppData instance = AppData._();

  String? httpBaseURL;

  String? _httpProxy;
  String? get httpProxy => _httpProxy;
  set httpProxy(String? value) {
    if (_httpProxy == value) return;
    _httpProxy = value;
    notifyListeners(AppDataType.httpProxy);
  }

  LoginInfo? _loginInfo;
  LoginInfo? get loginInfo => _loginInfo;
  set loginInfo(LoginInfo? value) {
    if (_loginInfo == value) return;

    if (value != null) {
      lastLoginInfo = value;
    }

    _loginInfo = value;
    notifyListeners(AppDataType.loginInfo);
  }

  LoginInfo? _lastLoginInfo;
  LoginInfo? get lastLoginInfo => _lastLoginInfo;
  set lastLoginInfo(LoginInfo? value) {
    if (_lastLoginInfo == value) return;

    _lastLoginInfo = value;
    notifyListeners(AppDataType.lastLoginInfo);
  }

  bool get isLogin => loginInfo != null;
}
