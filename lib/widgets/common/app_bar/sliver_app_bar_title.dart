import 'package:flutter/material.dart';

// as of Flutter v2.8.1, fading opacity in `SliverAppBar`
// is not applied to title when `appBarTheme.titleTextStyle` is defined,
// so this wrapper manually applies opacity to the default text style
class SliverAppBarTitleWrapper extends StatelessWidget {
  final Widget child;

  const SliverAppBarTitleWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final toolbarOpacity = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!.toolbarOpacity;
    final baseColor = (DefaultTextStyle.of(context).style.color ?? Theme.of(context).textTheme.titleLarge!.color!);
    return DefaultTextStyle.merge(
      style: TextStyle(color: baseColor.withOpacity(toolbarOpacity)),
      child: child,
    );
  }
}
