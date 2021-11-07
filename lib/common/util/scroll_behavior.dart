import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSScrollBehavior extends ScrollBehavior {

  const IOSScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) {
    return Theme.of(context).platform;
  }

  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}