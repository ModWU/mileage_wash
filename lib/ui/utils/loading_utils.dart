import 'package:flutter/material.dart';

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
    return const CircularProgressIndicator();
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
