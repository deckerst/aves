import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverlayRowExpander extends StatefulWidget {
  final ValueNotifier<bool> expandedNotifier;
  final Widget child;

  const OverlayRowExpander({
    super.key,
    required this.expandedNotifier,
    required this.child,
  });

  @override
  State<OverlayRowExpander> createState() => _OverlayRowExpanderState();
}

class _OverlayRowExpanderState extends State<OverlayRowExpander> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant OverlayRowExpander oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      if (_scrollController.hasClients && _scrollController.positions.every((v) => v.hasContentDimensions)) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.expandedNotifier,
      builder: (context, expanded, child) {
        final parent = DefaultTextStyle.of(context);
        child = DefaultTextStyle(
          style: parent.style,
          textAlign: parent.textAlign,
          softWrap: expanded,
          overflow: parent.overflow,
          maxLines: expanded ? null : 1,
          textWidthBasis: parent.textWidthBasis,
          child: child!,
        );
        if (expanded) {
          child = ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.select<MediaQueryData, double>((mq) => mq.size.height / 5),
            ),
            child: MediaQuery.removePadding(
              // remove padding so that scroll bar is consistent with the scroll view
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                radius: const Radius.circular(16),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: child,
                ),
              ),
            ),
          );
        }
        return child;
      },
      child: widget.child,
    );
  }
}
