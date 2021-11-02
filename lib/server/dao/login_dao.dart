import 'package:dio/dio.dart';
import 'package:mileage_wash/common/http/http_result.dart';
import 'package:mileage_wash/common/http/http_utils.dart';
import 'package:mileage_wash/constant/http_apis.dart';
import 'package:mileage_wash/model/http/login_info.dart';
import 'package:mileage_wash/server/storage/app_storage.dart';

class LoginDao {
  LoginDao._();

  static Future<LoginInfo> login(
      {required String username, required String password}) async {
    final Response<HttpResult> response =
        await HttpUtil.post<HttpResult>(HTTPApis.login, data: <String, String>{
      'userName': username,
      'userPwd': password,
    });

    final HttpResult httpResult = response.data!;

    final Map<String, dynamic> loginInfoData =
        httpResult.data as Map<String, dynamic>;

    final String _token = loginInfoData['token']! as String;
    final String _username = loginInfoData['userName']! as String;
    final String _phoneNumber = loginInfoData['phoneNumber']! as String;

    final LoginInfo loginInfo = LoginInfo(
        username: _username,
        phoneNumber: _phoneNumber,
        password: password,
        token: _token);

    AppStorage.updateLoginInfo(loginInfo);

    return loginInfo;
  }

  static Future<void> logout(LoginInfo loginInfo) async {
    await HttpUtil.post<HttpResult>(HTTPApis.logout, data: <String, String>{
      'mobile': loginInfo.phoneNumber,
    });

    AppStorage.updateLoginInfo(null);
  }
}
