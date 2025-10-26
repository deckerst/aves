import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CrumbLine<T> extends StatefulWidget {
  final List<String> Function(BuildContext context) split;
  final T Function(BuildContext context, int index) combine;
  final void Function(T combined) onTap;

  static const EdgeInsets padding = EdgeInsets.only(top: 6, bottom: 20);

  const CrumbLine({
    super.key,
    required this.split,
    required this.combine,
    required this.onTap,
  });

  @override
  State<CrumbLine<T>> createState() => _CrumbLineState<T>();

  static double getPreferredHeight(TextScaler textScaler) => textScaler.scale(22) + padding.vertical;
}

class _CrumbLineState<T> extends State<CrumbLine<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CrumbLine<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.split(context).length < widget.split(context).length) {
      // scroll to show last crumb
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final animate = context.read<Settings>().animate;
        final extent = _scrollController.position.maxScrollExtent;
        if (animate) {
          _scrollController.animateTo(
            extent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
          );
        } else {
          _scrollController.jumpTo(extent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.split(context);

    final crumbColor = DefaultTextStyle.of(context).style.color;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        Widget _buildText(String text) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(text),
            );

        if (index >= parts.length) return const SizedBox();
        final text = parts[index];
        if (index == parts.length - 1) {
          return Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: _buildText(text),
            ),
          );
        }
        return GestureDetector(
          onTap: parts.isNotEmpty ? () => widget.onTap(widget.combine(context, index)) : null,
          child: Container(
            // use a `Container` with a dummy color to make it expand
            // so that we can also detect taps around the title `Text`
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildText(text),
                Icon(
                  AIcons.next,
                  color: crumbColor,
                ),
              ],
            ),
          ),
        );
      },
      itemCount: parts.length,
    );
  }
}
