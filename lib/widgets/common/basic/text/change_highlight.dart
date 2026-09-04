import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class ChangeHighlightText extends StatefulWidget {
  final String data;
  final TextStyle style, changedStyle;
  final Curve curve;
  final Duration duration;

  const new(
    this.data, {
    super.key,
    required this.style,
    required this.changedStyle,
    this.curve = Curves.linear,
    required this.duration,
  });

  @override
  State<ChangeHighlightText> createState() => _ChangeHighlightTextState();
}

class _ChangeHighlightTextState extends State<ChangeHighlightText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  late final Animation<TextStyle> _style;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            duration: widget.duration,
            vsync: this,
          )
          ..value = 1
          ..addListener(() => setState(() {}));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _style = ShadowedTextStyleTween(begin: widget.changedStyle, end: widget.style).animate(_animation);
  }

  @override
  void didUpdateWidget(ChangeHighlightText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.data,
      style: _style.value,
    );
  }
}

class ShadowedTextStyleTween extends Tween<TextStyle> {
  new({super.begin, super.end});

  @override
  TextStyle lerp(double t) {
    final textStyle = TextStyle.lerp(begin, end, t)!;
    final beginShadows = begin!.shadows;
    final endShadows = end!.shadows;
    if (beginShadows != null && endShadows != null && beginShadows.length == endShadows.length) {
      return textStyle.copyWith(
        shadows: beginShadows.mapIndexed((i, a) {
          final b = endShadows[i];
          return Shadow.lerp(a, b, t)!;
        }).toList(),
      );
    } else {
      return textStyle;
    }
  }
}
