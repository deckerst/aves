import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class const ChangeHighlightText(
  final TextSpan data, {
  super.key,
  required final TextStyle textStyle,
  required final double changeBlurRadius,
  final Curve curve = Curves.linear,
  required final Duration duration,
}) extends StatefulWidget {
  @override
  State<ChangeHighlightText> createState() => _ChangeHighlightTextState();
}

class _ChangeHighlightTextState extends State<ChangeHighlightText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  Animation<TextStyle> _styleAnimation = const AlwaysStoppedAnimation(TextStyle());

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStyle();
  }

  @override
  void didUpdateWidget(ChangeHighlightText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.textStyle != widget.textStyle || oldWidget.changeBlurRadius != widget.changeBlurRadius) {
      _updateStyle();
    }

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
    final textStyle = _styleAnimation.value;
    return IconTheme.merge(
      data: IconThemeData(
        shadows: textStyle.shadows,
      ),
      child: Text.rich(
        widget.data,
        style: textStyle,
      ),
    );
  }

  void _updateStyle() {
    final shadowColor = Theme.of(context).colorScheme.onSurface;
    final style = widget.textStyle.copyWith(
      shadows: [
        Shadow(
          color: shadowColor.withAlpha(0),
          blurRadius: 0,
        ),
      ],
    );
    final changedStyle = widget.textStyle.copyWith(
      shadows: [
        Shadow(
          color: shadowColor,
          blurRadius: widget.changeBlurRadius,
        ),
      ],
    );
    _styleAnimation = ShadowedTextStyleTween(begin: changedStyle, end: style).animate(_animation);
  }
}

class ShadowedTextStyleTween({
  super.begin,
  super.end,
}) extends Tween<TextStyle> {
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
