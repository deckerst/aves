import 'dart:async';
import 'dart:math';

import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/quick_chooser.dart';
import 'package:aves_ui/aves_ui.dart';
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
  final int maxTotalOptionCount;
  final double itemHeight;
  final double? Function(BuildContext context)? contentWidth;
  final Widget Function(BuildContext context, T menuItem) itemBuilder;
  final WidgetBuilder? emptyBuilder;

  static const int maxVisibleOptionCount = 5;

  MenuQuickChooser({
    super.key,
    required this.valueNotifier,
    required List<T> options,
    required this.autoReverse,
    required this.blurred,
    required this.chooserPosition,
    required this.pointerGlobalPosition,
    this.maxTotalOptionCount = maxVisibleOptionCount,
    this.itemHeight = kMinInteractiveDimension,
    this.contentWidth,
    required this.itemBuilder,
    this.emptyBuilder,
  }) : options = options.take(maxTotalOptionCount).toList();

  @override
  State<MenuQuickChooser<T>> createState() => _MenuQuickChooserState<T>();
}

class _MenuQuickChooserState<T> extends State<MenuQuickChooser<T>> {
  final List<StreamSubscription> _subscriptions = [];
  final ValueNotifier<Rect> _selectedRowRect = ValueNotifier(Rect.zero);
  final ScrollController _scrollController = ScrollController();
  int _scrollDirection = 0;
  Timer? _scrollUpdateTimer;
  Offset _globalPosition = Offset.zero;

  ValueNotifier<T?> get valueNotifier => widget.valueNotifier;

  List<T> get options => widget.options;

  bool get reversed => widget.autoReverse && widget.chooserPosition == PopupMenuPosition.over;

  bool get scrollable => options.length > MenuQuickChooser.maxVisibleOptionCount;

  int get visibleOptionCount => min(MenuQuickChooser.maxVisibleOptionCount, options.length);

  double get itemHeight => widget.itemHeight;

  double get contentHeight => max(0, itemHeight * visibleOptionCount + _intraPadding * (visibleOptionCount - 1));

  static const double _selectorMargin = 24;
  static const double _intraPadding = 8;
  static const double _nonScrollablePaddingHeight = _intraPadding;
  static const double _scrollerAreaHeight = kMinInteractiveDimension;
  static const double scrollMaxPixelPerSecond = 600.0;
  static const Duration scrollUpdateInterval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedRowRect.value = Rect.fromLTWH(0, MediaQuery.sizeOf(context).height * (reversed ? 1 : -1), 0, 0);
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
    _selectedRowRect.dispose();
    _scrollController.dispose();
    _scrollUpdateTimer?.cancel();
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

          if (options.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: widget.emptyBuilder?.call(context) ?? const SizedBox(),
            );
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
              Container(
                width: widget.contentWidth?.call(context),
                margin: const EdgeInsetsDirectional.only(start: _selectorMargin),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    scrollable
                        ? ListenableBuilder(
                            listenable: _scrollController,
                            builder: (context, child) => Opacity(
                              opacity: canGoUp ? 1 : .5,
                              child: child,
                            ),
                            child: _buildScrollerArea(AIcons.up),
                          )
                        : const SizedBox(height: _nonScrollablePaddingHeight),
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(height: contentHeight),
                      child: ListView.separated(
                        reverse: reversed,
                        controller: _scrollController,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final child = Container(
                            alignment: AlignmentDirectional.centerStart,
                            constraints: BoxConstraints.tightFor(height: itemHeight),
                            child: widget.itemBuilder(context, options[index]),
                          );
                          if (index < MenuQuickChooser.maxVisibleOptionCount) {
                            // only animate items visible on first render
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: durations.staggeredAnimation * .5,
                              delay: durations.staggeredAnimationDelay * .5 * timeDilation,
                              child: SlideAnimation(
                                verticalOffset: 50.0 * (widget.chooserPosition == PopupMenuPosition.over ? 1 : -1),
                                child: FadeInAnimation(
                                  child: child,
                                ),
                              ),
                            );
                          } else {
                            return child;
                          }
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: _intraPadding),
                        itemCount: options.length,
                      ),
                    ),
                    scrollable
                        ? ListenableBuilder(
                            listenable: _scrollController,
                            builder: (context, child) => Opacity(
                              opacity: canGoDown ? 1 : .5,
                              child: child,
                            ),
                            child: _buildScrollerArea(AIcons.down),
                          )
                        : const SizedBox(height: _nonScrollablePaddingHeight),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool get canGoUp {
    if (!_scrollController.hasClients) return false;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return false;
    return reversed ? position.pixels < position.maxScrollExtent : 0 < position.pixels;
  }

  bool get canGoDown {
    if (!_scrollController.hasClients) return false;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return false;
    return reversed ? 0 < position.pixels : position.pixels < position.maxScrollExtent;
  }

  Widget _buildScrollerArea(IconData icon) {
    return Container(
      alignment: Alignment.center,
      height: _scrollerAreaHeight,
      margin: const EdgeInsetsDirectional.only(end: _selectorMargin),
      child: Icon(icon),
    );
  }

  void _onPointerMove(Offset globalPosition) {
    _globalPosition = globalPosition;
    final chooserBox = context.findRenderObject() as RenderBox?;
    if (chooserBox == null) return;

    final chooserSize = chooserBox.size;
    final contentWidth = chooserSize.width;
    final chooserBoxEdgeHeight = (QuickChooser.margin.vertical + QuickChooser.padding.vertical) / 2;

    final localPosition = chooserBox.globalToLocal(globalPosition);
    final dx = localPosition.dx;
    if (!(0 < dx && dx < contentWidth)) {
      valueNotifier.value = null;
      return;
    }

    double dy = localPosition.dy - chooserBoxEdgeHeight;
    int scrollDirection = 0;
    if (scrollable) {
      dy -= _scrollerAreaHeight;
      if (-_scrollerAreaHeight < dy && dy < 0) {
        scrollDirection = reversed ? 1 : -1;
      } else if (contentHeight < dy && dy < contentHeight + _scrollerAreaHeight) {
        scrollDirection = reversed ? -1 : 1;
      }
      _scroll(scrollDirection);
    } else {
      dy -= _nonScrollablePaddingHeight;
    }

    T? selectedValue;
    if (scrollDirection == 0 && 0 < dy && dy < contentHeight) {
      final visibleOffset = reversed ? contentHeight - dy : dy;
      final fullItemHeight = itemHeight + _intraPadding;
      final scrollOffset = _scrollController.offset;
      final index = (visibleOffset + _intraPadding + scrollOffset) ~/ (fullItemHeight);
      if (0 <= index && index < options.length) {
        selectedValue = options[index];
        double fromEdge = fullItemHeight * index;
        fromEdge += (scrollable ? _scrollerAreaHeight - scrollOffset : _nonScrollablePaddingHeight);
        final top = reversed ? chooserSize.height - chooserBoxEdgeHeight - fromEdge - fullItemHeight : fromEdge;
        _selectedRowRect.value = Rect.fromLTWH(0, top, contentWidth, itemHeight);
      }
    }
    valueNotifier.value = selectedValue;
  }

  void _scroll(int scrollDirection) {
    if (scrollDirection == _scrollDirection) return;
    _scrollDirection = scrollDirection;
    _scrollUpdateTimer?.cancel();

    final current = _scrollController.offset;
    if (scrollDirection == 0) {
      _scrollController.jumpTo(current);
      return;
    }

    final target = scrollDirection > 0 ? _scrollController.position.maxScrollExtent : .0;
    if (target != current) {
      final distance = target - current;
      final millis = distance * 1000 / scrollMaxPixelPerSecond / scrollDirection;
      _scrollController.animateTo(
        target,
        duration: Duration(milliseconds: millis.round()),
        curve: Curves.linear,
      );
      // use a timer to update the selection, because `_onPointerMove`
      // is not called when the pointer stays still while the view is scrolling
      _scrollUpdateTimer = Timer.periodic(scrollUpdateInterval, (_) => _onPointerMove(_globalPosition));
    }
  }
}
