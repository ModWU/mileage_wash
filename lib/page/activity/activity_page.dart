import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mileage_wash/common/listener/ob.dart';
import 'package:mileage_wash/common/listener/tap.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
import 'package:mileage_wash/model/notifier/order_push_notifier.dart';
import 'package:mileage_wash/server/controller/activity_controller.dart';
import 'package:mileage_wash/server/plugin/tencent_map_plugin.dart';
import 'package:mileage_wash/server/plugin/third_party_plugin.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../state/app_state.dart';
import '../base.dart';
import 'home/home_page.dart';
import 'me/me_page.dart';

class ActivityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with BootMiXin, ActivityController {
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

  Future<bool> _onWillPop() => bootContext.appHandler.isAllowBack(context);

  bool _debugPositionAnimation = false;

  @override
  Widget build(BuildContext context) {
    // 活动页数据放到活动页面，一旦登出后便不存在。
    // 等以后数据类别较多时需要统一管理，可移动到顶层。
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            IndexedStack(
              index: bootContext.page.value.index,
              children: <Widget>[
                HomePage(),
                MePage(),
              ],
            ),
            /*AndroidViewSurface(
              controller: ThirdPartyPlugin.find<TencentMapPlugin>().mapViewController as SurfaceAndroidViewController,
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                ),
              },
            ),*/
            /*Center(
              child: IgnorePointer(
                child: ObWidget<String>(
                    builder: (Observer<String>? observer) {
                      final String position = observer?.value ?? 'null';
                      _debugPositionAnimation = !_debugPositionAnimation;
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          borderRadius:
                          BorderRadius.all(Radius.circular(6.0)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: AnimatedDefaultTextStyle(
                          style: _debugPositionAnimation
                              ? const TextStyle(
                            color: Colors.white,
                          )
                              : const TextStyle(
                            color: Colors.lightGreenAccent,
                          ),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          child: Text(
                            position,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                    initialValue: ThirdPartyPlugin.find<TencentMapPlugin>()
                        .debugPositionObserver),
              ),
            ),*/
          ],
        ),
        bottomNavigationBar: const _BottomNavigationBarWidget(),
      ),
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
