import 'dart:math';

import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/animated_text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AboutTranslators extends StatelessWidget {
  const AboutTranslators({super.key});

  static const translators = {
    Contributor('D3ZOXY', 'its.ghost.message@gmail.com'),
    Contributor('JanWaldhorn', 'weblate@jwh.anonaddy.com'),
    Contributor('n-berenice', null),
    Contributor('Jonatas de Almeida Barros', 'ajonatas56@gmail.com'),
    Contributor('MeFinity', 'me.dot.finity@gmail.com'),
    Contributor('Maki', null),
    Contributor('HiSubway', 'shenyusoftware@gmail.com'),
    Contributor('glemco', null),
    Contributor('Aerowolf', null),
    Contributor('小默', null),
    Contributor('metezd', 'itoldyouthat@protonmail.com'),
    Contributor('Martijn Fabrie', null),
    Contributor('Koen Koppens', 'koenkoppens@proton.me'),
    Contributor('Emmanouil Papavergis', null),
    Contributor('kha84', 'khalukhin@gmail.com'),
    Contributor('gallegonovato', 'fran-carro@hotmail.es'),
    Contributor('Havokdan', 'havokdan@yahoo.com.br'),
    Contributor('Jean Mareilles', 'waged1266@tutanota.com'),
    Contributor('이정희', 'daemul72@gmail.com'),
    Contributor('Translator-3000', 'weblate.m1d0h@8shield.net'),
    // Contributor('Allan Nordhøy', 'epost@anotheragency.no'),
    // Contributor('Piotr K', '1337.kelt@gmail.com'),
    // Contributor('امیر جهانگرد', 'ijahangard.a@gmail.com'),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.aboutTranslatorsSectionTitle, style: Constants.knownTitleTextStyle),
            ),
          ),
          const SizedBox(height: 8),
          _RandomTextSpanHighlighter(
            spans: translators.map((v) => v.name).toList(),
            highlightColor: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _RandomTextSpanHighlighter extends StatefulWidget {
  final List<String> spans;
  final Color highlightColor;

  const _RandomTextSpanHighlighter({
    required this.spans,
    required this.highlightColor,
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

    _baseStyle = TextStyle(
      shadows: [
        Shadow(
          color: widget.highlightColor.withOpacity(0),
          blurRadius: 0,
        )
      ],
    );
    final highlightStyle = TextStyle(
      shadows: [
        Shadow(
          color: widget.highlightColor,
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
      curve: Curves.linear,
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
                if (i != 0) const TextSpan(text: ' • '),
                TextSpan(text: v, style: i == _highlightedIndex ? _animatedStyle.value : _baseStyle),
              ])
        ],
      ),
      strutStyle: const StrutStyle(height: 1.5, forceStrutHeight: true),
    );
  }
}

class Contributor {
  final String name;
  final String? weblateEmail;

  const Contributor(this.name, this.weblateEmail);
}
