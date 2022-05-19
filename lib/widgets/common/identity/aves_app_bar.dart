import 'dart:ui';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvesAppBar extends StatelessWidget {
  final double contentHeight;
  final Widget leading;
  final Widget title;
  final List<Widget> actions;
  final Widget? bottom;
  final Object? transitionKey;

  const AvesAppBar({
    super.key,
    required this.contentHeight,
    required this.leading,
    required this.title,
    required this.actions,
    this.bottom,
    this.transitionKey,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      floating: true,
      pinned: false,
      delegate: _SliverAppBarDelegate(
        height: appBarHeightForContentHeight(contentHeight),
        child: SafeArea(
          bottom: false,
          child: AvesFloatingBar(
            builder: (context, backgroundColor) => Material(
              color: backgroundColor,
              textStyle: Theme.of(context).appBarTheme.titleTextStyle,
              child: Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: leading,
                        ),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: context.read<DurationsData>().iconAnimation,
                            child: Row(
                              key: ValueKey(transitionKey),
                              children: [
                                Expanded(child: title),
                                ...actions,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bottom != null) bottom!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double appBarHeightForContentHeight(double contentHeight) {
    final topPadding = window.padding.top / window.devicePixelRatio;
    return topPadding + AvesFloatingBar.margin.vertical + contentHeight;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _SliverAppBarDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) => true;
}

class AvesFloatingBar extends StatelessWidget {
  final Widget Function(BuildContext context, Color backgroundColor) builder;

  const AvesFloatingBar({
    super.key,
    required this.builder,
  });

  static const margin = EdgeInsets.all(8);
  static const borderRadius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.appBarTheme.backgroundColor!;
    final blurred = context.select<Settings, bool>((s) => s.enableOverlayBlurEffect);

    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor,
        ),
        borderRadius: borderRadius,
      ),
      margin: margin,
      child: BlurredRRect(
        enabled: blurred,
        borderRadius: borderRadius,
        child: builder(
          context,
          blurred ? backgroundColor.withOpacity(.85) : backgroundColor,
        ),
      ),
    );
  }
}
