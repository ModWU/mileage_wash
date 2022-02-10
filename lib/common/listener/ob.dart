import 'package:flutter/material.dart';

typedef WidgetCallback<T> = Widget Function(Observer<T>);

extension ObExtension<T> on T {
  Observer<T> get ob => Observer<T>(this);
}

class Observer<T> with ChangeNotifier {
  Observer(this._value);

  T? _value;

  T? get value => _value;

  set value(T? value) {
    if (_value == value) {
      return;
    }
    _value = value;
    notifyListeners();
  }

  void alwaysNotifyValue(T? value) {
    _value = value;
    notifyListeners();
  }

  T? call([T? v]) {
    if (v != null) {
      value = v;
    }
    return _value;
  }

  /*@override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(dynamic other) {
    if (other is T) return value == other;
    if (other is Observer<T>) return value == other.value;
    return false;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _value.hashCode;*/
}

class ObWidget<T> extends StatefulWidget {
  const ObWidget({
    required this.builder,
    required this.observer,
  });

  final Observer<T> observer;
  final WidgetCallback<T> builder;

  Widget _buildWidget(dynamic data) {
    return builder(data as Observer<T>);
  }

  @override
  State<StatefulWidget> createState() => _ObsWidgetState<T>();
}

class _ObsWidgetState<T> extends State<ObWidget<T>> {
  Observer<T>? _data;

  @override
  void initState() {
    super.initState();
    _data = widget.observer;
    _data!.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant ObWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    /*if (!identical(widget.observer, _data)) {
      _data?.removeListener(_rebuild);
      widget.observer.addListener(_rebuild);
      _data = widget.observer;
    }*/
    if (widget.observer != _data) {
      _data?.removeListener(_rebuild);
      widget.observer.addListener(_rebuild);
      _data = widget.observer;
    }
  }

  @override
  void dispose() {
    _data!.removeListener(_rebuild);
    _data = null;
    super.dispose();
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget._buildWidget(_data!);
}
