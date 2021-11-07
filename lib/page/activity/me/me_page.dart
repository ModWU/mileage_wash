import 'package:flutter/material.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/server/controller/login_controller.dart';
import 'package:mileage_wash/ui/utils/loading_utils.dart';

import '../../base.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MePageState();
}

class _MePageState extends State<MePage> with BootMiXin {
  final GlobalKey _loadingKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              S.of(context).me_title,
            ),
            Text(
              S.of(context).me_order_state_receiving,
              style: const TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
      body: Column(
        key: _loadingKey,
        children: <Widget>[
          const Divider(
            height: 1.0,
            thickness: 1.0,
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(AppData.instance.loginInfo!.username),
              subtitle: Text(AppData.instance.loginInfo!.phoneNumber),
            ),
          ),
          Expanded(
              child: Align(
            alignment: const Alignment(0.0, 0.88),
            child: TextButton(
              onPressed: _onLogout,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16)),
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)))),
                minimumSize: MaterialStateProperty.all(
                    Size(MediaQuery.of(context).size.width - 24, 0)),
              ),
              child: Text(
                S.of(context).me_logout_text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Future<void> _onLogout() async {
    LoadingUtils.show(context, targetKey: _loadingKey);
    final bool isSuccess = await LoginController.logout(context);
    LoadingUtils.hide();
    if (isSuccess) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          RouteIds.login, (Route<dynamic> route) => false);
    }
  }
}
