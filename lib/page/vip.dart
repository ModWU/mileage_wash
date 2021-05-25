import 'package:flutter/material.dart';

import 'attr/static_attr.dart';
import 'base/state.dart';
import 'manager/boot_manager.dart';

class VipPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VipPageState();
}

class _VipPageState extends BaseState<VipPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("title: vip",),),
      body: DefaultTextStyle(
        style: bootContext.bodyText,
        child: Center(
          child: Text("vip",),
        ),
      ),
    );;
  }

  @override
  void changedPage() {
    if (isPage(PageCategory.vip)) {
      bootContext.changeThemeStyle(ThemeStyle.light);
    }
  }
}