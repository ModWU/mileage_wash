import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mileage_wash/common/log/app_log.dart';
import 'package:mileage_wash/model/http/order_info.dart';
import 'package:mileage_wash/model/notifier/home_state_notifier.dart';
import 'package:mileage_wash/server/controller/home_controller.dart';
import 'package:mileage_wash/ui/utils/loading_utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'home.dart';

class OrderListView<T extends HomeNotifier> extends StatefulWidget {
  const OrderListView(this.homeStateListener);

  final HomeStateListener homeStateListener;

  @override
  State<StatefulWidget> createState() => OrderListState<T>();
}

class OrderListState<T extends HomeNotifier> extends State<OrderListView<T>>
    with AutomaticKeepAliveClientMixin {
  RefreshController? _refreshController;
  ScrollController? _scrollController;

  int? _cacheSize;

  final double _itemHeight = 106;

  final int _cacheScreenLength = 2;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _scrollController = ScrollController();

    widget.homeStateListener.addTabClickListener(_onTabClick);
  }

  void _onTabClick(int clickIndex, int previousIndex) {
    final T homeNotifier = context.read<T>();

    if (clickIndex == homeNotifier.state.index && previousIndex == clickIndex) {
      _scrollController!.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final T homeNotifier = context.read<T>();
    if (homeNotifier.orderData == null) {
      final double screenHeight = MediaQuery.of(context).size.height;
      HomeController.queryOrderList(context,
              orderState: homeNotifier.state,
              curPage: 0,
              pageSize:
                  (screenHeight / _itemHeight).ceil() * _cacheScreenLength,
              allowThrowError: true)
          .then((List<OrderInfo>? orderInfoList) {
        if (mounted && orderInfoList != null) {
          homeNotifier.addData(orderInfoList);
        }
      }).catchError((Object error) {
        if (mounted) {
          homeNotifier.notifyError(error);
        }
      });
    }
  }

  @override
  void dispose() {
    widget.homeStateListener.removeListener(_onTabClick);

    _refreshController?.dispose();
    _scrollController?.dispose();

    _refreshController = null;
    _scrollController = null;
    super.dispose();
  }

  bool _isAllowPullUp(T homeNotifier, double maxHeight) {
    final int visibleCapacity = (maxHeight / _itemHeight).ceil();

    final int orderSize = homeNotifier.size;
    return orderSize >= visibleCapacity;
  }

  Future<void> _onRefresh() async {
    final T homeNotifier = context.read<T>();
    _refreshController!.resetNoData();

    if (!_isAllowPullUp(homeNotifier, _viewportDimension)) {
      _loadData(homeNotifier, onCompleted: () {
        _refreshController!.refreshCompleted();
      }, onNoData: () {
        _refreshController!.loadNoData();
        _refreshController!.refreshCompleted();
      }, onFailed: () {
        _refreshController!.refreshFailed();
      });
    } else {
      _refreshController!.refreshCompleted();
    }
  }

  Future<void> _onLoading() async {
    final T homeNotifier = context.read<T>();

    if (_isAllowPullUp(homeNotifier, _viewportDimension)) {
      _loadData(homeNotifier, onCompleted: () {
        _refreshController!.loadComplete();
      }, onNoData: () {
        _refreshController!.loadNoData();
      }, onFailed: () {
        _refreshController!.loadFailed();
      });
    } else {
      _refreshController!.loadComplete();
    }
  }

  void _loadData(T homeNotifier,
      {VoidCallback? onCompleted,
      VoidCallback? onNoData,
      VoidCallback? onFailed}) {
    HomeController.queryOrderList(context,
            orderState: homeNotifier.state,
            curPage: homeNotifier.curPage! + 1,
            pageSize: _taskCacheSize,
            allowThrowError: true)
        .then((List<OrderInfo>? orderInfoList) {
      if (mounted && orderInfoList != null) {
        homeNotifier.addData(orderInfoList);
        if (orderInfoList.length >= _taskCacheSize) {
          onCompleted?.call();
        } else {
          onNoData?.call();
        }
      }
    }).catchError((Object error) {
      if (mounted) {
        onFailed?.call();
      }
    });
  }

  int get _taskCacheSize => _cacheSize ??= _computerCacheSize();

  double get _viewportDimension {
    final ScrollController scrollController = _scrollController!;
    assert(scrollController.hasClients);
    assert(scrollController.position.hasViewportDimension);
    final double viewportDimension =
        scrollController.position.viewportDimension;
    assert(viewportDimension > 0);

    return viewportDimension;
  }

  int _computerCacheSize() {
    final int numPerScreen = (_viewportDimension / _itemHeight).ceil();
    assert(numPerScreen > 0);

    return numPerScreen * _cacheScreenLength;
  }

  Widget _buildOrderItemView(
      BuildContext context, int index, List<OrderInfo> orderData) {
    final OrderInfo orderInfo = orderData[index];
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${orderInfo.adsName} ${orderInfo.adsDetail}',
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orderInfo.shortName,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orderInfo.washDate,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 13,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          orderInfo.carNumber,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 13,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.assistant_navigation,
                    size: 34,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 64),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(3.2)),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                '已到达',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final T homeNotifier = context.watch<T>();

    final List<OrderInfo>? orderData = homeNotifier.orderData;

    return homeNotifier.hasError || orderData != null
        ? LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
            final double maxHeight = constraints.maxHeight;

            print("=========maxHeight: $maxHeight");

            return SmartRefresher(
              key: ValueKey<String>('smart_refresher_$T'),
              enablePullDown: true,
              enablePullUp: _isAllowPullUp(homeNotifier, constraints.maxHeight),
              controller: _refreshController!,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: homeNotifier.hasData
                  ? ListView.builder(
                      controller: _scrollController!,
                      itemBuilder: (BuildContext context, int index) =>
                          _buildOrderItemView(context, index, orderData!),
                      itemExtent: _itemHeight,
                      itemCount: homeNotifier.size,
                    )
                  : const Center(
                      child: Text(
                        'Empty Data',
                        style: TextStyle(
                            fontSize: 18, fontStyle: FontStyle.italic),
                      ),
                    ),
            );
          })
        : const LoadingWidget();
  }

  @override
  bool get wantKeepAlive => true;
}
