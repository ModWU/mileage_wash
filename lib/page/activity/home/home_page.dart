import 'package:flutter/material.dart';
import 'package:mileage_wash/common/listener/data_notifier.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';

import '../../base.dart';
import 'order_list_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with BootMiXin, TickerProviderStateMixin {
  TabController? _tabController;

  HomeStateListener? homeStateListener;

  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: _previousIndex, length: 4, vsync: this);
    _tabController!.addListener(_onTabChange);

    homeStateListener = HomeStateListener(_tabController!);
  }

  void _onTabClick(int index) {
    homeStateListener!
        .notifyListeners(HomeState.tabClick, index, _previousIndex);
    _previousIndex = index;
  }

  void _onTabChange() {
    final int currentIndex = _tabController!.index;
    if (currentIndex == _tabController!.animation?.value) {
      homeStateListener!.notifyListeners(HomeState.tabChange, currentIndex);
    }
  }

  @override
  void dispose() {
    HomeState.values.forEach(homeStateListener!.removeAllListenerByKey);
    homeStateListener!.dispose();
    homeStateListener = null;

    _tabController!.removeListener(_onTabChange);
    _tabController!.dispose();
    _tabController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverAppBar(
          pinned: false,
          floating: false,
          snap: false,
          automaticallyImplyLeading: false,
          title: Text(S.of(context).home_title),
          centerTitle: false,
          bottom: TabBar(
            controller: _tabController,
            onTap: _onTabClick,
            tabs: <Widget>[
              Tab(
                text: S.of(context).home_tab_waiting,
                icon: const Icon(Icons.location_on),
              ),
              Tab(
                text: S.of(context).home_tab_washing,
                icon: const Icon(Icons.motorcycle),
              ),
              Tab(
                text: S.of(context).home_tab_done,
                icon: const Icon(Icons.done_all),
              ),
              Tab(
                text: S.of(context).home_tab_cancelled,
                icon: const Icon(Icons.clear_all),
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              OrderListView<HomeWaitingNotifier>(homeStateListener!),
              OrderListView<HomeWashingNotifier>(homeStateListener!),
              OrderListView<HomeDoneNotifier>(homeStateListener!),
              OrderListView<HomeCancelledNotifier>(homeStateListener!),
            ],
          ),
        ),
      ],
    );
  }
}

enum HomeState { tabClick, tabChange }

class HomeStateListener with DataNotifier {
  HomeStateListener(this.tabController);

  TabController? tabController;

  void addTabClickListener(
      void Function(int clickIndex, int previousIndex) listener) {
    addListener(HomeState.tabClick, listener);
  }

  void addTabChangeListener(void Function(int index) listener) {
    addListener(HomeState.tabChange, listener);
  }

  bool isTabAt(int index) => index == tabController!.index;

  @override
  void dispose() {
    tabController = null;
    super.dispose();
  }
}
