import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_video/common/listener/tap.dart';
import 'package:tencent_video/generated/l10n.dart';
import 'package:tencent_video/page/manager/boot_manager.dart';
import 'package:tencent_video/page/person.dart';
import 'package:tencent_video/page/vip.dart';
import 'package:tencent_video/ui/state/rive_state.dart';
import 'base/state.dart';
import 'doki.dart';
import 'home.dart';
import 'message.dart';

class Boot extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BootState();
}

class _BootState extends State<Boot> with BootManager {

  @override
  void initState() {
    super.initState();
    page.addListener(_rebuild);
    themeStyle.addListener(_rebuild);
  }

  @override
  void dispose() {
    page.removeListener(_rebuild);
    themeStyle.removeListener(_rebuild);
    super.dispose();
  }


  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return startBoot(
      child: Theme(
        data: themeData,
        child: Scaffold(
          bottomNavigationBar: _BottomNavigationBarWidget(),
          body: IndexedStack(
            index: page.value!.index,
            children: [
              HomePage(),
              DokiPage(),
              VipPage(),
              MessagePage(),
              PersonPage(),
            ],
          ),
        ),
      ),
    );
  }

}

class _BottomNavigationBarWidget extends StatefulWidget {

  const _BottomNavigationBarWidget();

  @override
  State<StatefulWidget> createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState
    extends BaseState<_BottomNavigationBarWidget> {

  TapListener? _pageTapListener;

  @override
  void updateBootContext(BootContext? oldBootContext) {
    _pageTapListener = new TapListener(bootContext.page.value!);
  }

  @override
  void changedPage() {
    _pageTapListener!.onTap(bootContext.page.value!);
  }


  @override
  void dispose() {
    _pageTapListener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData localTheme = Theme.of(context);
    return Theme(
      data: localTheme.copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: _getRiveIcon(PageCategory.home, 20),
              label: S.of(context).home_tle),
          BottomNavigationBarItem(
              icon: _getRiveIcon(PageCategory.doki, 20),
              label: S.of(context).doki_tle),
          BottomNavigationBarItem(
              icon: _getRiveIcon(PageCategory.vip, 20),
              label: S.of(context).vip_tle),
          BottomNavigationBarItem(
              icon: _getRiveIcon(PageCategory.message, 20),
              label: S.of(context).message_tle),
          BottomNavigationBarItem(
              icon: _getRiveIcon(PageCategory.person, 20),
              label: S.of(context).person_tle),
        ],
        currentIndex: bootContext.page.value!.index,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.red,
        backgroundColor: bootContext.themeData.appBarTheme.backgroundColor,
        selectedLabelStyle: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
        iconSize: 20,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 4,
        onTap: (int index) {
          bootContext.page.value = PageCategory.values[index];
        },
      ),
    );
  }

  Widget _getRiveIcon(PageCategory page, double size) {
    switch (page) {
      case PageCategory.home:
        return RiveSimpleStateMachineWidget(
            uri: "assets/mr-help.riv",
            stateMachineName: "State Machine 1",
            input: "Wrong",
            size: size,
            tapListener: _pageTapListener!,
            value: PageCategory.home);
      case PageCategory.doki:
        return RiveSimpleWidget(
            uri: "assets/landing-animation.riv",
            animationName: "Landing",
            size: size,
            useArtboardSize: true,
            tapListener: _pageTapListener!,
            value: PageCategory.doki);
      case PageCategory.vip:
        return RiveSimpleStateMachineWidget(
            uri: "assets/mr-help.riv",
            stateMachineName: "State Machine 1",
            input: "Speak",
            size: size,
            tapListener: _pageTapListener!,
            value: PageCategory.vip);
      case PageCategory.message:
        return RiveSimpleStateMachineWidget(
            uri: "assets/mr-help.riv",
            stateMachineName: "State Machine 1",
            input: "Speak",
            size: size,
            tapListener: _pageTapListener!,
            value: PageCategory.message);
      case PageCategory.person:
        return RiveSimpleStateMachineWidget(
            uri: "assets/mr-help.riv",
            stateMachineName: "State Machine 1",
            input: "Happy",
            size: size,
            tapListener: _pageTapListener!,
            value: PageCategory.person);
    }
  }
}
