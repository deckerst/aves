import 'dart:math';

import 'package:aves/utils/diff_match.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class AnimatedDiffText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final StrutStyle? strutStyle;
  final Curve curve;
  final Duration duration;

  const AnimatedDiffText(
    this.text, {
    super.key,
    this.textStyle,
    this.strutStyle,
    this.curve = Curves.easeInOutCubic,
    required this.duration,
  });

  @override
  State<AnimatedDiffText> createState() => _AnimatedDiffTextState();
}

class _AnimatedDiffTextState extends State<AnimatedDiffText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  final List<_TextDiff> _diffs = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _computeDiff(widget.text, widget.text);
  }

  @override
  void didUpdateWidget(covariant AnimatedDiffText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldText = oldWidget.text;
    final newText = widget.text;
    if (oldText != newText) {
      _computeDiff(oldText, newText);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text.rich(
          TextSpan(
            children: _diffs.map((diff) {
              final (oldText, newText, oldSize, newSize) = diff;
              final text = (_animation.value == 0 ? oldText : newText) ?? '';
              return WidgetSpan(
                child: AnimatedSize(
                  key: ValueKey(diff),
                  curve: widget.curve,
                  duration: widget.duration,
                  child: AnimatedSwitcher(
                    duration: widget.duration,
                    switchInCurve: widget.curve,
                    switchOutCurve: widget.curve,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ...previousChildren.map(
                            (child) => ConstrainedBox(
                              constraints: BoxConstraints.tight(Size(
                                min(oldSize.width, newSize.width),
                                min(oldSize.height, newSize.height),
                              )),
                              child: child,
                            ),
                          ),
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: Text(
                      text,
                      key: Key(text),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          strutStyle: widget.strutStyle,
        );
      },
    );
  }

  Size textSize(String text) {
    final para = RenderParagraph(
      TextSpan(text: text, style: widget.textStyle),
      textDirection: Directionality.of(context),
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
      strutStyle: widget.strutStyle,
    )..layout(const BoxConstraints(), parentUsesSize: true);
    final width = para.getMaxIntrinsicWidth(double.infinity);
    final height = para.getMaxIntrinsicHeight(double.infinity);
    return Size(width, height);
  }

  // use an adaptation of Google's `Diff Match and Patch`
  // as package `diffutil_dart` (as of v3.0.0) is unreliable
  void _computeDiff(String oldText, String newText) {
    final oldCharacters = oldText.characters.join();
    final newCharacters = newText.characters.join();

    final dmp = DiffMatchPatch();
    final d = dmp.diff_main(oldCharacters, newCharacters);
    dmp.diff_cleanupSemantic(d);

    _diffs
      ..clear()
      ..addAll(d.map((diff) {
        final text = diff.text;
        final size = textSize(text);
        return switch (diff.operation) {
          Operation.delete => (text, null, size, Size.zero),
          Operation.insert => (null, text, Size.zero, size),
          Operation.equal || _ => (text, text, size, size),
        };
      }).fold<List<_TextDiff>>([], (prev, v) {
        if (prev.isNotEmpty) {
          final last = prev.last;
          final prevNewText = last.$2;
          if (prevNewText == null) {
            // previous diff is a deletion
            final thisOldText = v.$1;
            if (thisOldText == null) {
              // this diff is an insertion
              // merge deletion and insertion as a change operation
              final change = (last.$1, v.$2, last.$3, v.$4);
              return [...prev.take(prev.length - 1), change];
            }
          }
        }
        return [...prev, v];
      }));
  }
}

typedef _TextDiff = (String?, String?, Size, Size);
