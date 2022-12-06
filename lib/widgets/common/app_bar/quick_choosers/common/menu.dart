import 'dart:async';
import 'dart:ui';

import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/common/quick_chooser.dart';
import 'package:aves_ui/aves_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class MenuQuickChooser<T> extends StatefulWidget {
  final ValueNotifier<T?> valueNotifier;
  final List<T> options;
  final bool autoReverse;
  final bool blurred;
  final PopupMenuPosition chooserPosition;
  final Stream<Offset> pointerGlobalPosition;
  final Widget Function(BuildContext context, T menuItem) itemBuilder;

  static const int maxOptionCount = 5;

  MenuQuickChooser({
    super.key,
    required this.valueNotifier,
    required List<T> options,
    required this.autoReverse,
    required this.blurred,
    required this.chooserPosition,
    required this.pointerGlobalPosition,
    required this.itemBuilder,
  }) : options = options.take(maxOptionCount).toList();

  @override
  State<MenuQuickChooser<T>> createState() => _MenuQuickChooserState<T>();
}

class _MenuQuickChooserState<T> extends State<MenuQuickChooser<T>> {
  final List<StreamSubscription> _subscriptions = [];
  final ValueNotifier<Rect> _selectedRowRect = ValueNotifier(Rect.zero);

  ValueNotifier<T?> get valueNotifier => widget.valueNotifier;

  List<T> get options => widget.options;

  bool get reversed => widget.autoReverse && widget.chooserPosition == PopupMenuPosition.over;

  static const double intraPadding = 8;

  @override
  void initState() {
    super.initState();
    _selectedRowRect.value = Rect.fromLTWH(0, window.physicalSize.height * (reversed ? 1 : -1), 0, 0);
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant MenuQuickChooser<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(MenuQuickChooser<T> widget) {
    _subscriptions.add(widget.pointerGlobalPosition.listen(_onPointerMove));
  }

  void _unregisterWidget(MenuQuickChooser<T> widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return QuickChooser(
      blurred: widget.blurred,
      child: ValueListenableBuilder<T?>(
        valueListenable: valueNotifier,
        builder: (context, selectedValue, child) {
          final durations = context.watch<DurationsData>();

          List<Widget> optionChildren = options.mapIndexed((index, value) {
            final isFirst = index == (reversed ? options.length - 1 : 0);
            return Padding(
              padding: EdgeInsets.only(top: isFirst ? intraPadding : 0, bottom: intraPadding),
              child: widget.itemBuilder(context, value),
            );
          }).toList();

          optionChildren = AnimationConfiguration.toStaggeredList(
            duration: durations.staggeredAnimation * .5,
            delay: durations.staggeredAnimationDelay * .5 * timeDilation,
            childAnimationBuilder: (child) => SlideAnimation(
              verticalOffset: 50.0 * (widget.chooserPosition == PopupMenuPosition.over ? 1 : -1),
              child: FadeInAnimation(
                child: child,
              ),
            ),
            children: optionChildren,
          );

          if (reversed) {
            optionChildren = optionChildren.reversed.toList();
          }

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
                  children: optionChildren,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onPointerMove(Offset globalPosition) {
    final padding = QuickChooser.margin.vertical + QuickChooser.padding.vertical;

    final chooserBox = context.findRenderObject() as RenderBox;
    final chooserSize = chooserBox.size;
    final contentWidth = chooserSize.width;
    final contentHeight = chooserSize.height - padding;

    final optionCount = options.length;
    final itemHeight = (contentHeight - (optionCount + 1) * intraPadding) / optionCount;

    final local = chooserBox.globalToLocal(globalPosition);
    final dx = local.dx;
    final dy = local.dy - padding / 2;

    T? selectedValue;
    if (0 < dx && dx < contentWidth && 0 < dy && dy < contentHeight) {
      final index = (optionCount * dy / contentHeight).floor();
      if (0 <= index && index < optionCount) {
        selectedValue = options[reversed ? optionCount - 1 - index : index];
        final top = index * (itemHeight + intraPadding) + intraPadding;
        _selectedRowRect.value = Rect.fromLTWH(0, top, contentWidth, itemHeight);
      }
    }
    valueNotifier.value = selectedValue;
  }
}
