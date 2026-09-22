import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class const ChangeHighlightText(
  final TextSpan data, {
  super.key,
  final TextStyle? textStyle,
  final double changeBlurRadius = 8,
  final Curve curve = Curves.linear,
  required final Duration duration,
}) extends StatefulWidget {
  @override
  State<ChangeHighlightText> createState() => _ChangeHighlightTextState();
}

class _ChangeHighlightTextState extends State<ChangeHighlightText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late CurvedAnimation _animation;
  late Animation<TextStyle> _styleAnimation;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStyle(context);
  }

  @override
  void didUpdateWidget(ChangeHighlightText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.textStyle != widget.textStyle || oldWidget.changeBlurRadius != widget.changeBlurRadius || oldWidget.curve != widget.curve) {
      _updateStyle(context);
    }

    if (!_sameSpanContent(oldWidget.data, widget.data)) {
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

  void _updateStyle(BuildContext context) {
    final shadowColor = Theme.of(context).colorScheme.onSurface;
    final textStyle = widget.textStyle ?? DefaultTextStyle.of(context).style;
    final style = textStyle.copyWith(
      shadows: [
        Shadow(
          color: shadowColor.withAlpha(0),
          blurRadius: 0,
        ),
      ],
    );
    final changedStyle = textStyle.copyWith(
      shadows: [
        Shadow(
          color: shadowColor,
          blurRadius: widget.changeBlurRadius,
        ),
      ],
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _styleAnimation = ShadowedTextStyleTween(begin: changedStyle, end: style).animate(_animation);
  }

  // `TextSpan.compareTo()` does not compare deep in `WidgetSpan`s
  static bool _sameSpanContent(InlineSpan a, InlineSpan b) {
    if (identical(a, b)) return true;
    if (a.runtimeType != b.runtimeType) return false;
    if (a is TextSpan && b is TextSpan) return _isSameTextSpanContent(a, b);
    if (a is WidgetSpan && b is WidgetSpan) return _isSameWidgetSpanContent(a, b);
    return false;
  }

  static bool _isSameTextSpanContent(TextSpan a, TextSpan b) {
    if (a.text != b.text) return false;
    final aChildren = a.children;
    final bChildren = b.children;
    if (aChildren?.length != bChildren?.length) return false;
    if (aChildren != null && bChildren != null) {
      final length = aChildren.length;
      for (var i = 0; i < length; i++) {
        if (!_sameSpanContent(aChildren[i], bChildren[i])) return false;
      }
    }
    return true;
  }

  static bool _isSameWidgetSpanContent(WidgetSpan a, WidgetSpan b) {
    final aChild = a.child;
    final bChild = b.child;
    if (identical(aChild, bChild)) return true;
    if (aChild.runtimeType != bChild.runtimeType) return false;
    if (aChild is Icon && bChild is Icon) {
      if (aChild.icon != bChild.icon) return false;
    }
    return true;
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
