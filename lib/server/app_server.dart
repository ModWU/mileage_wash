import 'package:mileage_wash/common/http/dio_manager.dart';
import 'package:mileage_wash/constant/http_result_code.dart';
import 'package:mileage_wash/server/storage/app_storage.dart';

class AppServer {
  AppServer._();

  static Future<void> initialize() async {
    DioManager.successCode = HttpResultCode.success;
    await AppStorage.initialize();
  }
}
