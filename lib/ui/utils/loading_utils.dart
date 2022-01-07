import 'package:flutter/material.dart';
import 'package:mileage_wash/common/listener/ob.dart';

enum LoadingType { normal }

class LoadingUtils {
  LoadingUtils._();

  static OverlayEntry? _overlay;

  static void show(BuildContext context,
      {LoadingType type = LoadingType.normal, GlobalKey? targetKey}) {
    _removeLoadingWindow();
    _addLoadingWindow(context, type, targetKey: targetKey);
  }

  static void hide() {
    _removeLoadingWindow();
  }

  static void _addLoadingWindow(BuildContext context, LoadingType type,
      {GlobalKey? targetKey}) {
    if (_overlay != null) return;

    _overlay = OverlayEntry(
      builder: (BuildContext context) => LoadingWidget(
          loadingType: type, targetContext: context, targetKey: targetKey),
    );
    Overlay.of(context)!.insert(_overlay!);
  }

  static void _removeLoadingWindow() {
    if (_overlay == null) return;

    _overlay!.remove();
    _overlay = null;
  }

  static Widget build({
    required Widget child,
    required Observer<bool> observer,
  }) {
    return Stack(
      children: <Widget>[
        child,
        ObWidget<bool>(
            builder: (Observer<bool>? observer) {
              final bool show = observer?.value ?? false;
              return Offstage(
                offstage: !show,
                child: const LoadingWidget(),
              );
            },
            observer: observer),
      ],
    );
  }
}

class LoadingWidget extends StatefulWidget {
  const LoadingWidget(
      {this.loadingType = LoadingType.normal,
      this.targetContext,
      this.targetKey});

  final LoadingType loadingType;
  final GlobalKey? targetKey;
  final BuildContext? targetContext;

  @override
  State<StatefulWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  RenderBox? _targetRenderBox;

  @override
  void dispose() {
    _targetRenderBox = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.targetKey != null) {
      _targetRenderBox =
          widget.targetKey!.currentContext!.findRenderObject() as RenderBox;
    } else {
      _targetRenderBox = widget.targetContext?.findRenderObject() as RenderBox?;
    }
  }

  Widget _buildLoadingView() {
    return Container(
      width: 86,
      height: 86,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.6,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildByPosition() {
    final RenderBox targetRenderBox = _targetRenderBox!;

    final Offset targetPosition = targetRenderBox.localToGlobal(Offset.zero);
    final Size targetSize = targetRenderBox.size;

    return Positioned(
        left: targetPosition.dx,
        top: targetPosition.dy,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: targetSize.width,
            height: targetSize.height,
            alignment: Alignment.center,
            child: _buildLoadingView(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRenderBox == null) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: _buildLoadingView(),
        ),
      );
    }
    return _buildByPosition();
  }
}
