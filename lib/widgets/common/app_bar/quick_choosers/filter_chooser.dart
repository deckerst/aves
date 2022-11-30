import 'dart:async';

import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_ui/aves_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FilterQuickChooser<T> extends StatefulWidget {
  final ValueNotifier<T?> valueNotifier;
  final List<T> options;
  final Stream<Offset> pointerGlobalPosition;
  final Widget Function(BuildContext context, T album) buildFilterChip;

  const FilterQuickChooser({
    super.key,
    required this.valueNotifier,
    required this.options,
    required this.pointerGlobalPosition,
    required this.buildFilterChip,
  });

  @override
  State<FilterQuickChooser<T>> createState() => _FilterQuickChooserState<T>();
}

class _FilterQuickChooserState<T> extends State<FilterQuickChooser<T>> {
  final List<StreamSubscription> _subscriptions = [];
  final ValueNotifier<Rect> _selectedRowRect = ValueNotifier(Rect.zero);

  ValueNotifier<T?> get valueNotifier => widget.valueNotifier;

  List<T> get options => widget.options;

  static const margin = EdgeInsets.all(8);
  static const padding = EdgeInsets.all(8);
  static const double intraPadding = 8;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant FilterQuickChooser<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(FilterQuickChooser<T> widget) {
    _subscriptions.add(widget.pointerGlobalPosition.listen(_onPointerMove));
  }

  void _unregisterWidget(FilterQuickChooser<T> widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        shape: AvesDialog.shape(context),
        child: Padding(
          padding: padding,
          child: ValueListenableBuilder<T?>(
            valueListenable: valueNotifier,
            builder: (context, selectedValue, child) {
              return Stack(
                children: [
                  ValueListenableBuilder<Rect>(
                    valueListenable: _selectedRowRect,
                    builder: (context, selectedRowRect, child) {
                      Widget child = const Center(child: AvesDot());
                      child = AnimatedOpacity(
                        opacity: selectedValue != null ? 1 : 0,
                        curve: Curves.easeInOutCubic,
                        duration: const Duration(milliseconds: 200),
                        child: child,
                      );
                      child = AnimatedPositioned(
                        top: selectedRowRect.top,
                        height: selectedRowRect.height,
                        curve: Curves.easeInOutCubic,
                        duration: const Duration(milliseconds: 200),
                        child: child,
                      );
                      return child;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: options.mapIndexed((index, value) {
                        return Padding(
                          padding: index == 0 ? EdgeInsets.zero : const EdgeInsets.only(top: intraPadding),
                          child: widget.buildFilterChip(context, value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onPointerMove(Offset globalPosition) {
    final chooserBox = context.findRenderObject() as RenderBox;
    final chooserSize = chooserBox.size;
    final contentWidth = chooserSize.width;
    final contentHeight = chooserSize.height - (margin.vertical + padding.vertical);

    final optionCount = options.length;
    final itemHeight = (contentHeight - (optionCount - 1) * intraPadding) / optionCount;

    final local = chooserBox.globalToLocal(globalPosition);
    final dx = local.dx;
    final dy = local.dy - (margin.vertical + padding.vertical) / 2;

    T? selectedValue;
    if (0 < dx && dx < contentWidth && 0 < dy && dy < contentHeight) {
      final index = (options.length * dy / contentHeight).floor();
      if (0 <= index && index < options.length) {
        selectedValue = options[index];
        final top = index * (itemHeight + intraPadding);
        _selectedRowRect.value = Rect.fromLTWH(0, top, contentWidth, itemHeight);
      }
    }
    valueNotifier.value = selectedValue;
  }
}
