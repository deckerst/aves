import 'dart:math';

import 'package:aves/model/app/contributors.dart';
import 'package:aves/theme/text.dart';
import 'package:aves/widgets/about/title.dart';
import 'package:aves/widgets/common/basic/text/change_highlight.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AboutTranslators extends StatelessWidget {
  const AboutTranslators({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AboutSectionTitle(text: context.l10n.aboutTranslatorsSectionTitle),
          const SizedBox(height: 8),
          buildBody(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Widget buildBody(BuildContext context) {
    return _RandomTextSpanHighlighter(
      spans: Contributors.translators.map((v) => v.name).toList(),
      color: Theme.of(context).colorScheme.onBackground,
    );
  }
}

class _RandomTextSpanHighlighter extends StatefulWidget {
  final List<String> spans;
  final Color color;

  const _RandomTextSpanHighlighter({
    required this.spans,
    required this.color,
  });

  @override
  State<_RandomTextSpanHighlighter> createState() => _RandomTextSpanHighlighterState();
}

class _RandomTextSpanHighlighterState extends State<_RandomTextSpanHighlighter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<TextStyle> _animatedStyle;
  late final TextStyle _baseStyle;
  int _highlightedIndex = 0;

  @override
  void initState() {
    super.initState();

    final color = widget.color;
    _baseStyle = TextStyle(
      color: color.withOpacity(.7),
      shadows: [
        Shadow(
          color: color.withOpacity(0),
          blurRadius: 0,
        )
      ],
    );
    final highlightStyle = TextStyle(
      color: color.withOpacity(1),
      shadows: [
        Shadow(
          color: color.withOpacity(1),
          blurRadius: 3,
        )
      ],
    );

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _highlightedIndex = Random().nextInt(widget.spans.length);
        }
      })
      ..repeat(reverse: true);
    _animatedStyle = ShadowedTextStyleTween(begin: _baseStyle, end: highlightStyle).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          ...widget.spans.expandIndexed((i, v) => [
                if (i != 0) const TextSpan(text: AText.separator),
                TextSpan(text: v, style: i == _highlightedIndex ? _animatedStyle.value : _baseStyle),
              ])
        ],
      ),
    );
  }
}
