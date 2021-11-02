import 'package:mileage_wash/common/storage/storage_manager.dart';
import 'package:mileage_wash/constant/local_storage_keys.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/model/http/login_info.dart';

class AppStorage {
  AppStorage._();

  static late final StorageManager _storageManager = StorageManager.instance;

  static Future<void> updateLoginInfo(LoginInfo? loginInfo) async {
    AppData.instance.loginInfo = loginInfo;

    final LoginInfo? oldStorageUserInfo =
        _readLoginInfo(LocalStorageKeys.loginInfo);

    if (oldStorageUserInfo != loginInfo) {
      await _writeLoginInfo(LocalStorageKeys.loginInfo, loginInfo);
    }

    final LoginInfo? oldStorageLastUserInfo =
        _readLoginInfo(LocalStorageKeys.lastLoginInfo);

    if (oldStorageLastUserInfo != AppData.instance.lastLoginInfo) {
      await _writeLoginInfo(
          LocalStorageKeys.lastLoginInfo, AppData.instance.lastLoginInfo);
    }
  }

  static LoginInfo? _readLoginInfo(String key) {
    final String? userInfoJson = _storageManager.spStorage.getString(key);

    if (userInfoJson == null) {
      return null;
    }

    return LoginInfo.fromJson(userInfoJson);
  }

  static Future<bool> _writeLoginInfo(String key, LoginInfo? loginInfo) {
    if (loginInfo != null) {
      return _storageManager.spStorage.setString(key, loginInfo.toJson);
    } else {
      return _storageManager.spStorage.remove(key);
    }
  }

  static Future<void> initialize() async {
    await StorageManager.instance.initStorage();

    final LoginInfo? loginInfo = _readLoginInfo(LocalStorageKeys.loginInfo);
    AppData.instance.loginInfo = loginInfo;

    final LoginInfo? lastLoginInfo =
        _readLoginInfo(LocalStorageKeys.lastLoginInfo);
    AppData.instance.lastLoginInfo = lastLoginInfo;

    AppData.instance.httpProxy =
        _storageManager.spStorage.getString(LocalStorageKeys.httpProxy);
  }
}
