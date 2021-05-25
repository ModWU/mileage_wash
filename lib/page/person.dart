import 'package:flutter/material.dart';

import 'attr/static_attr.dart';
import 'base/state.dart';
import 'manager/boot_manager.dart';

class PersonPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PersonPageState();
}

class _PersonPageState extends BaseState<PersonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("title: person",),),
      body: DefaultTextStyle(
        style: bootContext.bodyText,
        child: Center(
          child: Text("person",),
        ),
      ),
    );;
  }

  @override
  void changedPage() {
    if (isPage(PageCategory.person)) {
      bootContext.changeThemeStyle(ThemeStyle.light);
    }
  }
}