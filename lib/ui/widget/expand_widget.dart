import 'package:flutter/material.dart';

typedef TitleBuilder = Widget Function(BuildContext context, Widget? child,
    Animation<double> animation, AnimationStatus status);

typedef ExpandBuilder = Widget Function(
    BuildContext context, Widget? child, Animation<double> animation);

enum TitleStyleType {
  above,
  below,
}

class ExpandWidget extends StatefulWidget {
  const ExpandWidget({
    Key? key,
    this.title,
    this.titleBuilder,
    this.builder,
    this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.fastOutSlowIn,
    this.alignment = Alignment.center,
    this.reverse = false,
    this.changeFade = true,
    this.titleAlignment,
    this.titlePadding,
    this.padding,
    this.titleStyleType = TitleStyleType.above,
    this.direction = Axis.vertical,
  })  : assert(title != null || titleBuilder != null),
        assert(child != null || builder != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ExpandWidgetState();

  final Widget? title;
  final TitleBuilder? titleBuilder;
  final ExpandBuilder? builder;
  final Widget? child;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry? titleAlignment;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? padding;
  final TitleStyleType titleStyleType;
  final bool changeFade;
  final bool reverse;
  final Axis direction;
}

class _ExpandWidgetState extends State<ExpandWidget>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  AnimationStatus? _status;

  @override
  void didUpdateWidget(covariant ExpandWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration ||
        widget.curve != oldWidget.curve) {
      _updateAnimation(widget.duration, widget.curve);
    }
  }

  void _updateAnimation(Duration duration, Curve curve) {
    AnimationController? animationController = _animationController;
    final AnimationStatus? oldStatus = _status;
    final double? currentValue = animationController?.value;

    if (animationController != null) {
      animationController.removeStatusListener(_onAnimationStatus);
      animationController.stop();
      animationController.dispose();
    }

    animationController =
        AnimationController(vsync: this, duration: widget.duration);
    animationController.addStatusListener(_onAnimationStatus);
    _animation = CurveTween(curve: Curves.easeIn).animate(animationController);

    _status = animationController.status;
    if (oldStatus != null) {
      switch (oldStatus) {
        case AnimationStatus.forward:
          animationController.forward(from: currentValue);
          break;

        case AnimationStatus.reverse:
          animationController.reverse(from: currentValue);
          break;

        case AnimationStatus.dismissed:
          animationController.value = animationController.lowerBound;
          break;

        case AnimationStatus.completed:
          animationController.value = animationController.upperBound;
          break;
      }
    }

    _animationController = animationController;
  }

  void _onAnimationStatus(AnimationStatus status) {
    _status = status;
    if (widget.titleStyleType == TitleStyleType.below) {
      if (_status == AnimationStatus.forward ||
          _status == AnimationStatus.completed) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _updateAnimation(widget.duration, widget.curve);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.removeStatusListener(_onAnimationStatus);
    _status = null;
    _animation = null;
    _animationController?.dispose();
    _animationController = null;
  }

  void _startAnimation() {
    final AnimationController animationController = _animationController!;
    if (!animationController.isAnimating) {
      if (animationController.isCompleted) {
        animationController.reverse();
      } else if (animationController.isDismissed) {
        animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = _animation!;

    Widget title = widget.titleBuilder == null
        ? widget.title!
        : AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) => widget
                .titleBuilder!(context, widget.title, animation, _status!),
          );

    if (widget.titleAlignment != null) {
      title = Align(
        alignment: widget.titleAlignment!,
        child: title,
      );
    }

    title = GestureDetector(
      onTap: () async {
        _startAnimation();
      },
      child: widget.titlePadding == null
          ? title
          : Padding(
              padding: widget.titlePadding!,
              child: title,
            ),
    );

    Widget child = widget.builder == null
        ? widget.child!
        : widget.builder!(context, widget.child, animation);

    if (widget.alignment != null) {
      child = Align(
        alignment: widget.alignment!,
        child: child,
      );
    }

    if (widget.padding != null) {
      child = Padding(
        padding: widget.padding!,
        child: child,
      );
    }

    if (widget.changeFade) {
      child = FadeTransition(
        opacity: _animation!,
        child: child,
      );
    }

    child = SizeTransition(
      sizeFactor: _animation!,
      axis: widget.direction,
      axisAlignment: widget.reverse ? 1.0 : -1.0,
      child: child,
    );

    final List<Widget> children = <Widget>[
      title,
      child,
    ];

    if (widget.reverse) {
      final Widget first = children.removeAt(0);
      children.add(first);
    }

    if (widget.titleStyleType == TitleStyleType.below) {
      if (_status == AnimationStatus.forward ||
          _status == AnimationStatus.completed) {
        final Widget first = children.removeAt(0);
        children.add(first);
      }
    }

    return _isVertical
        ? IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          )
        : IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          );
  }

  Alignment get _flipAlignment {
    switch (widget.direction) {
      case Axis.vertical:
        return widget.reverse ? Alignment.bottomCenter : Alignment.topCenter;

      case Axis.horizontal:
        return widget.reverse ? Alignment.centerRight : Alignment.centerLeft;
    }
  }

  bool get _isVertical => widget.direction == Axis.vertical;
}
