import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvesScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;

  const AvesScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    // prevent conflict between drawer drag gesture and Android navigation gestures
    final drawerEnableOpenDragGesture = context.select<MediaQueryData, bool>((mq) => mq.systemGestureInsets.horizontal == 0);

    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
    );
  }
}
