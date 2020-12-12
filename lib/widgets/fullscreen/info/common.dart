import 'dart:math';

import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SectionRow extends StatelessWidget {
  final IconData icon;

  const SectionRow(this.icon);

  @override
  Widget build(BuildContext context) {
    const dim = 32.0;
    Widget buildDivider() => SizedBox(
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
          padding: EdgeInsets.all(16),
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
  final Map<String, String> keyValues;
  final int maxValueLength;
  final Map<String, InfoLinkHandler> linkHandlers;

  const InfoRowGroup(
    this.keyValues, {
    this.maxValueLength = 0,
    this.linkHandlers,
  });

  @override
  _InfoRowGroupState createState() => _InfoRowGroupState();
}

class _InfoRowGroupState extends State<InfoRowGroup> {
  final List<String> _expandedKeys = [];

  Map<String, String> get keyValues => widget.keyValues;

  int get maxValueLength => widget.maxValueLength;

  Map<String, InfoLinkHandler> get linkHandlers => widget.linkHandlers;

  static const keyValuePadding = 16;
  static const linkColor = Colors.blue;
  static final baseStyle = TextStyle(fontFamily: 'Concourse');
  static final keyStyle = baseStyle.copyWith(color: Colors.white70, height: 1.7);
  static final linkStyle = baseStyle.copyWith(color: linkColor, decoration: TextDecoration.underline);

  @override
  Widget build(BuildContext context) {
    if (keyValues.isEmpty) return SizedBox.shrink();

    // compute the size of keys and space in order to align values
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final keySizes = Map.fromEntries(keyValues.keys.map((key) => MapEntry(key, _getSpanWidth(TextSpan(text: '$key', style: keyStyle), textScaleFactor))));
    final baseSpaceWidth = _getSpanWidth(TextSpan(text: '\u200A' * 100, style: baseStyle), textScaleFactor);

    final lastKey = keyValues.keys.last;
    return LayoutBuilder(
      builder: (context, constraints) {
        // find longest key below threshold
        final maxBaseValueX = constraints.maxWidth / 3;
        final baseValueX = keySizes.values.where((size) => size < maxBaseValueX).fold(0.0, max);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText.rich(
              TextSpan(
                children: keyValues.entries.expand(
                  (kv) {
                    final key = kv.key;
                    String value;
                    TextStyle style;
                    GestureRecognizer recognizer;

                    if (linkHandlers?.containsKey(key) == true) {
                      final handler = linkHandlers[key];
                      value = handler.linkText;
                      // open link on tap
                      recognizer = TapGestureRecognizer()..onTap = () => handler.onTap(context);
                      style = linkStyle;
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

                    // as of Flutter v1.22.4, `SelectableText` cannot contain `WidgetSpan`
                    // so we add padding using multiple hair spaces instead
                    final thisSpaceSize = max(0.0, (baseValueX - keySizes[key])) + keyValuePadding;
                    final spaceCount = (100 * thisSpaceSize / baseSpaceWidth).round();

                    return [
                      TextSpan(text: key, style: keyStyle),
                      TextSpan(text: '\u200A' * spaceCount),
                      TextSpan(text: value, style: style, recognizer: recognizer),
                    ];
                  },
                ).toList(),
              ),
              style: baseStyle,
            ),
          ],
        );
      },
    );
  }

  double _getSpanWidth(TextSpan span, double textScaleFactor) {
    final para = RenderParagraph(
      span,
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor,
    )..layout(BoxConstraints(), parentUsesSize: true);
    return para.getMaxIntrinsicWidth(double.infinity);
  }
}

class InfoLinkHandler {
  final String linkText;
  final void Function(BuildContext context) onTap;

  const InfoLinkHandler({
    @required this.linkText,
    @required this.onTap,
  });
}
