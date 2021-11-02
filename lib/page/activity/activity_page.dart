import 'package:flutter/material.dart';
import 'package:mileage_wash/common/listener/tap.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/server/controller/activity_controller.dart';

import '../app_state.dart';
import '../base.dart';
import 'home/home.dart';
import 'me/me.dart';

class ActivityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with BootMiXin, ActivityController {

  @override
  void initState() {
    super.initState();
    bootContext.page.value = PageCategory.home;
    bootContext.page.addListener(_pageChanged);
  }

  @override
  void dispose() {
    bootContext.page.removeListener(_pageChanged);
    super.dispose();
  }

  void _pageChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: bootContext.page.value.index,
        children: <Widget>[
          HomePage(),
          MePage(),
        ],
      ),
      bottomNavigationBar: const _BottomNavigationBarWidget(),
    );
  }
}

class _BottomNavigationBarWidget extends StatefulWidget {
  const _BottomNavigationBarWidget();

  @override
  State<StatefulWidget> createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<_BottomNavigationBarWidget>
    with BootMiXin {
  TapListener? _pageTapListener;

  @override
  void initState() {
    super.initState();
    _pageTapListener = TapListener(bootContext.page.value);
  }

  @override
  void pageChanged() {
    setState(() {
      _pageTapListener!.onTap(bootContext.page.value);
    });
  }

  @override
  void dispose() {
    _pageTapListener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: _getRiveIcon(PageCategory.home, 20),
            tooltip: '',
            label: S.of(context).bottom_navigation_home_title),
        BottomNavigationBarItem(
            icon: _getRiveIcon(PageCategory.me, 20),
            tooltip: '',
            label: S.of(context).bottom_navigation_me_title),
      ],
      currentIndex: bootContext.page.value.index,
      onTap: (int index) {
        bootContext.page.value = PageCategory.values[index];
      },
    );
  }

  Widget _getRiveIcon(PageCategory page, double size) {
    switch (page) {
      case PageCategory.home:
        return Icon(Icons.home, size: size);
      case PageCategory.me:
        return Icon(
          Icons.person,
          size: size,
        );
    }
  }
}
