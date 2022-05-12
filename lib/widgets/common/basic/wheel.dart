import 'package:flutter/material.dart';

class WheelSelector<T> extends StatefulWidget {
  final ValueNotifier<T> valueNotifier;
  final List<T> values;
  final TextStyle textStyle;
  final TextAlign textAlign;

  const WheelSelector({
    super.key,
    required this.valueNotifier,
    required this.values,
    required this.textStyle,
    required this.textAlign,
  });

  @override
  State<WheelSelector<T>> createState() => _WheelSelectorState<T>();
}

class _WheelSelectorState<T> extends State<WheelSelector<T>> {
  late final ScrollController _controller;

  static const itemSize = Size(40, 40);

  ValueNotifier<T> get valueNotifier => widget.valueNotifier;

  List<T> get values => widget.values;

  @override
  void initState() {
    super.initState();
    var indexOf = values.indexOf(valueNotifier.value);
    _controller = FixedExtentScrollController(
      initialItem: indexOf,
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Colors.transparent;
    final foreground = DefaultTextStyle.of(context).style.color!;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
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
                        '$i',
                        textAlign: widget.textAlign,
                        style: widget.textStyle,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
