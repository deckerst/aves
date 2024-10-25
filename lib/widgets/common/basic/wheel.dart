import 'package:aves/theme/durations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WheelSelector<T> extends StatefulWidget {
  final ValueNotifier<T> valueNotifier;
  final List<T> values;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final String Function(T v) format;

  const WheelSelector({
    super.key,
    required this.valueNotifier,
    required this.values,
    required this.textStyle,
    required this.textAlign,
    required this.format,
  });

  @override
  State<WheelSelector<T>> createState() => _WheelSelectorState<T>();
}

class _WheelSelectorState<T> extends State<WheelSelector<T>> {
  late final FixedExtentScrollController _controller;
  final ValueNotifier<bool> _focusedNotifier = ValueNotifier(false);

  ValueNotifier<T> get valueNotifier => widget.valueNotifier;

  List<T> get values => widget.values;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: values.indexOf(valueNotifier.value),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    const background = Colors.transparent;
    final foreground = DefaultTextStyle.of(context).style.color!;
    final transitionDuration = context.select<DurationsData, Duration>((v) => v.formTransition);
    final itemSize = Size.square(textScaler.scale(40));

    return FocusableActionDetector(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowUp): _AdjustValueIntent.up(),
        SingleActivator(LogicalKeyboardKey.arrowDown): _AdjustValueIntent.down(),
      },
      actions: {
        _AdjustValueIntent: CallbackAction<_AdjustValueIntent>(onInvoke: _onAdjustValueIntent),
      },
      onShowFocusHighlight: (v) => _focusedNotifier.value = v,
      child: NotificationListener<ScrollNotification>(
        // cancel notification bubbling so that the dialog scroll bar
        // does not misinterpret wheel scrolling for dialog content scrolling
        onNotification: (notification) => true,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: ValueListenableBuilder<bool>(
                      valueListenable: _focusedNotifier,
                      builder: (context, focused, child) {
                        return AnimatedContainer(
                          width: itemSize.width,
                          height: itemSize.height,
                          duration: transitionDuration,
                          decoration: BoxDecoration(
                            color: foreground.withAlpha((255.0 * (focused ? .2 : 0)).round()),
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                        );
                      }),
                ),
              ),
              SizedBox(
                width: itemSize.width,
                height: itemSize.height * 3,
                child: ShaderMask(
                  shaderCallback: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      background,
                      foreground,
                      foreground,
                      background,
                    ],
                  ).createShader,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbVisibility: WidgetStateProperty.all(false),
                      ),
                    ),
                    child: ListWheelScrollView(
                      controller: _controller,
                      physics: const FixedExtentScrollPhysics(parent: BouncingScrollPhysics()),
                      diameterRatio: 1.2,
                      itemExtent: itemSize.height,
                      squeeze: 1.3,
                      onSelectedItemChanged: (i) => valueNotifier.value = values[i],
                      children: values
                          .map((i) => SizedBox.fromSize(
                                size: itemSize,
                                child: Text(
                                  widget.format(i),
                                  textAlign: widget.textAlign,
                                  style: widget.textStyle,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAdjustValueIntent(_AdjustValueIntent intent) {
    late int delta;
    switch (intent.type) {
      case _ValueAdjustmentType.up:
        delta = -1;
      case _ValueAdjustmentType.down:
        delta = 1;
    }
    final targetItem = _controller.selectedItem + delta;
    final duration = context.read<DurationsData>().formTransition;
    if (duration > Duration.zero) {
      _controller.animateToItem(targetItem, duration: duration, curve: Curves.easeInOutCubic);
    } else {
      _controller.jumpToItem(targetItem);
    }
  }
}

class _AdjustValueIntent extends Intent {
  const _AdjustValueIntent({
    required this.type,
  });

  const _AdjustValueIntent.up() : type = _ValueAdjustmentType.up;

  const _AdjustValueIntent.down() : type = _ValueAdjustmentType.down;

  final _ValueAdjustmentType type;
}

enum _ValueAdjustmentType {
  up,
  down,
}
