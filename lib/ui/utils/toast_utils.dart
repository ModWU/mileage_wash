import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  ToastUtils._();

  static void showToast(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        //backgroundColor: Colors.red,
        //textColor: Colors.white,
        //fontSize: 16.0
    );
  }
  
}