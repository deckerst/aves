import 'dart:math';

import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SectionRow extends StatelessWidget {
  final IconData icon;

  const SectionRow({
    Key? key,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const dim = 32.0;
    Widget buildDivider() => const SizedBox(
          width: dim,
          child: Divider(
            thickness: AvesFilterChip.outlineWidth,
            color: Colors.white70,
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDivider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            size: dim,
          ),
        ),
        buildDivider(),
      ],
    );
  }
}

class InfoRowGroup extends StatefulWidget {
  final Map<String, String> info;
  final int maxValueLength;
  final Map<String, InfoLinkHandler>? linkHandlers;

  static const keyValuePadding = 16;
  static const linkColor = Colors.blue;
  static const fontSize = 13.0;
  static const baseStyle = TextStyle(fontSize: fontSize);
  static final keyStyle = baseStyle.copyWith(color: Colors.white70, height: 2.0);
  static final linkStyle = baseStyle.copyWith(color: linkColor, decoration: TextDecoration.underline);

  const InfoRowGroup({
    Key? key,
    required this.info,
    this.maxValueLength = 0,
    this.linkHandlers,
  }) : super(key: key);

  @override
  State<InfoRowGroup> createState() => _InfoRowGroupState();
}

class _InfoRowGroupState extends State<InfoRowGroup> {
  final List<String> _expandedKeys = [];

  Map<String, String> get keyValues => widget.info;

  int get maxValueLength => widget.maxValueLength;

  Map<String, InfoLinkHandler>? get linkHandlers => widget.linkHandlers;

  @override
  Widget build(BuildContext context) {
    if (keyValues.isEmpty) return const SizedBox.shrink();

    // compute the size of keys and space in order to align values
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final keySizes = Map.fromEntries(keyValues.keys.map((key) => MapEntry(key, _getSpanWidth(TextSpan(text: key, style: InfoRowGroup.keyStyle), textScaleFactor))));

    final lastKey = keyValues.keys.last;
    return LayoutBuilder(
      builder: (context, constraints) {
        // find longest key below threshold
        final maxBaseValueX = constraints.maxWidth / 3;
        final baseValueX = keySizes.values.where((size) => size < maxBaseValueX).fold(0.0, max);

        return SelectableText.rich(
          TextSpan(
            children: keyValues.entries.expand(
              (kv) {
                final key = kv.key;
                String value;
                TextStyle? style;
                GestureRecognizer? recognizer;

                if (linkHandlers?.containsKey(key) == true) {
                  final handler = linkHandlers![key]!;
                  value = handler.linkText(context);
                  // open link on tap
                  recognizer = TapGestureRecognizer()..onTap = () => handler.onTap(context);
                  style = InfoRowGroup.linkStyle;
                } else {
                  value = kv.value;
                  // long values are clipped, and made expandable by tapping them
                  final showPreviewOnly = maxValueLength > 0 && value.length > maxValueLength && !_expandedKeys.contains(key);
                  if (showPreviewOnly) {
                    value = '${value.substring(0, maxValueLength)}…';
                    // show full value on tap
                    recognizer = TapGestureRecognizer()..onTap = () => setState(() => _expandedKeys.add(key));
                  }
                }

                if (key != lastKey) {
                  value = '$value\n';
                }

                final thisSpaceSize = max(0.0, (baseValueX - keySizes[key]!)) + InfoRowGroup.keyValuePadding;

                // each text span embeds and pops a Bidi isolate,
                // so that layout of the spans follows the directionality of the locale
                // (e.g. keys on the right for RTL locale, whatever the key intrinsic directionality)
                // and each span respects the directionality of its inner text only
                return [
                  TextSpan(text: '${Constants.fsi}$key${Constants.pdi}', style: InfoRowGroup.keyStyle),
                  WidgetSpan(child: SizedBox(width: thisSpaceSize)),
                  TextSpan(text: '${Constants.fsi}$value${Constants.pdi}', style: style, recognizer: recognizer),
                ];
              },
            ).toList(),
          ),
          style: InfoRowGroup.baseStyle,
        );
      },
    );
  }

  double _getSpanWidth(TextSpan span, double textScaleFactor) {
    final para = RenderParagraph(
      span,
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor,
    )..layout(const BoxConstraints(), parentUsesSize: true);
    return para.getMaxIntrinsicWidth(double.infinity);
  }
}

class InfoLinkHandler {
  final String Function(BuildContext context) linkText;
  final void Function(BuildContext context) onTap;

  const InfoLinkHandler({
    required this.linkText,
    required this.onTap,
  });
}
