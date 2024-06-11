import 'dart:math';

import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SectionRow extends StatelessWidget {
  final IconData icon;

  const SectionRow({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const dim = 32.0;
    Widget buildDivider() => const SizedBox(
          width: dim,
          child: Divider(
            thickness: AvesFilterChip.outlineWidth,
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
  final Map<String, InfoValueSpanBuilder> spanBuilders;

  static const int defaultMaxValueLength = 140;
  static const double keyValuePadding = 16;
  static const double fontSize = 13;
  static const valueStyle = TextStyle(fontSize: fontSize);
  static final _keyStyle = valueStyle.copyWith(height: 2.0);

  static TextStyle keyStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant).merge(_keyStyle);
  }

  const InfoRowGroup({
    super.key,
    required this.info,
    this.maxValueLength = defaultMaxValueLength,
    Map<String, InfoValueSpanBuilder>? spanBuilders,
  }) : spanBuilders = spanBuilders ?? const {};

  @override
  State<InfoRowGroup> createState() => _InfoRowGroupState();

  static InfoValueSpanBuilder linkSpanBuilder({
    required String Function(BuildContext context) linkText,
    required void Function(BuildContext context) onTap,
  }) {
    return (context, key, value) {
      value = linkText(context);
      // `colorScheme.secondary` is overridden upstream as an `ExpansionTileCard` theming workaround,
      // so we use `colorScheme.primary` instead
      final linkColor = Theme.of(context).colorScheme.primary;

      return [
        WidgetSpan(
          child: LinkChip(
            text: value,
            color: linkColor,
            textStyle: InfoRowGroup.valueStyle,
            // open link on tap
            onTap: () => onTap(context),
          ),
          alignment: PlaceholderAlignment.middle,
        ),
      ];
    };
  }
}

class _InfoRowGroupState extends State<InfoRowGroup> {
  final List<String> _expandedKeys = [];

  Map<String, String> get keyValues => widget.info;

  int get maxValueLength => widget.maxValueLength;

  Map<String, InfoValueSpanBuilder> get spanBuilders => widget.spanBuilders;

  @override
  Widget build(BuildContext context) {
    if (keyValues.isEmpty) return const SizedBox();

    final _keyStyle = InfoRowGroup.keyStyle(context);

    // compute the size of keys and space in order to align values
    final textScaler = MediaQuery.textScalerOf(context);
    final keySizes = Map.fromEntries(keyValues.keys.map((key) => MapEntry(key, _getSpanWidth(TextSpan(text: _buildTextValue(key), style: _keyStyle), textScaler))));

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
                final value = kv.value;
                final customSpanBuilder = spanBuilders[key];
                final spanBuilder = customSpanBuilder ?? _buildTextValueSpans;
                final thisSpaceSize = max(0.0, (baseValueX - keySizes[key]!)) + InfoRowGroup.keyValuePadding;

                InlineSpan paddingSpan;
                if (customSpanBuilder != null) {
                  // add padding using hair spaces instead of a straightforward `SizedBox` in a `WidgetSpan`,
                  // because ordering of multiple `WidgetSpan`s (e.g. with owner app icon) in Bidi context is tricky
                  final baseSpaceWidth = _getSpanWidth(TextSpan(text: '\u200A' * 100, style: _keyStyle), textScaler);
                  final spaceCount = (100 * thisSpaceSize / baseSpaceWidth).round();
                  paddingSpan = TextSpan(text: '\u200A' * spaceCount);
                } else {
                  final textScaleFactor = textScaler.scale(thisSpaceSize) / thisSpaceSize;
                  paddingSpan = WidgetSpan(
                    child: SizedBox(
                      width: thisSpaceSize / textScaleFactor,
                      // as of Flutter v3.0.0, the underline decoration from the following `TextSpan`
                      // is applied to the `WidgetSpan` too, so we add a dummy `Text` as a workaround
                      child: const Text(''),
                    ),
                  );
                }

                return [
                  TextSpan(text: _buildTextValue(key), style: _keyStyle),
                  paddingSpan,
                  ...spanBuilder(context, key, value),
                  if (key != lastKey) const TextSpan(text: '\n'),
                ];
              },
            ).toList(),
          ),
          style: InfoRowGroup.valueStyle,
        );
      },
    );
  }

  double _getSpanWidth(TextSpan span, TextScaler textScaler) {
    final paragraph = RenderParagraph(
      span,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout(const BoxConstraints(), parentUsesSize: true);
    final width = paragraph.getMaxIntrinsicWidth(double.infinity);
    paragraph.dispose();
    return width;
  }

  List<InlineSpan> _buildTextValueSpans(BuildContext context, String key, String value) {
    GestureRecognizer? recognizer;

    // long values are clipped, and made expandable by tapping them
    final showPreviewOnly = maxValueLength > 0 && value.length > maxValueLength && !_expandedKeys.contains(key);
    if (showPreviewOnly) {
      value = '${value.substring(0, maxValueLength)}…';
      // show full value on tap
      recognizer = TapGestureRecognizer()..onTap = () => setState(() => _expandedKeys.add(key));
    }

    return [TextSpan(text: _buildTextValue(value), recognizer: recognizer)];
  }

  // each text span embeds and pops a Bidi isolate,
  // so that layout of the spans follows the directionality of the locale
  // (e.g. keys on the right for RTL locale, whatever the key intrinsic directionality)
  // and each span respects the directionality of its inner text only
  String _buildTextValue(String value) => '${Unicode.FSI}$value${Unicode.PDI}';
}

typedef InfoValueSpanBuilder = List<InlineSpan> Function(BuildContext context, String key, String value);
