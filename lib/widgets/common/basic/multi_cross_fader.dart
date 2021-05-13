import 'package:flutter/material.dart';

class MultiCrossFader extends StatefulWidget {
  final Duration duration;
  final Curve fadeCurve, sizeCurve;
  final AlignmentGeometry alignment;
  final Widget child;

  const MultiCrossFader({
    required this.duration,
    this.fadeCurve = Curves.linear,
    this.sizeCurve = Curves.linear,
    this.alignment = Alignment.topCenter,
    required this.child,
  });

  @override
  _MultiCrossFaderState createState() => _MultiCrossFaderState();
}

class _MultiCrossFaderState extends State<MultiCrossFader> {
  late Widget _first, _second;
  CrossFadeState _fadeState = CrossFadeState.showFirst;

  @override
  void initState() {
    super.initState();
    _first = widget.child;
    _second = SizedBox();
  }

  @override
  void didUpdateWidget(covariant MultiCrossFader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_first == oldWidget.child) {
      _second = widget.child;
      _fadeState = CrossFadeState.showSecond;
    } else {
      _first = widget.child;
      _fadeState = CrossFadeState.showFirst;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: _first,
      secondChild: _second,
      firstCurve: widget.fadeCurve,
      secondCurve: widget.fadeCurve,
      sizeCurve: widget.sizeCurve,
      alignment: widget.alignment,
      crossFadeState: _fadeState,
      duration: widget.duration,
    );
  }
}
