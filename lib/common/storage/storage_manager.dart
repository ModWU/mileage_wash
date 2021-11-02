import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  StorageManager._();

  static late final StorageManager instance = StorageManager._();

  late final SharedPreferences spStorage;

  Future<void> initStorage() async {
    spStorage = await SharedPreferences.getInstance();
  }

}