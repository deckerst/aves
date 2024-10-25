import 'dart:math';

import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/multi_cross_fader.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/highlight_title.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:flutter/material.dart';

typedef XmpExtractedCard = (Map<String, XmpProp>, List<XmpCardData>?);

class XmpCard extends StatefulWidget {
  final String title;
  late final XmpExtractedCard? directStruct;
  late final List<XmpExtractedCard>? indexedStructs;
  final String Function(XmpProp prop) formatValue;
  final Map<String, InfoValueSpanBuilder> Function(int? index)? spanBuilders;

  XmpCard({
    super.key,
    required this.title,
    required Map<int?, XmpExtractedCard> structByIndex,
    required this.formatValue,
    this.spanBuilders,
  }) {
    directStruct = structByIndex[null];

    final length = structByIndex.keys.nonNulls.fold(0, max);
    indexedStructs = length > 0 ? [for (var i = 0; i < length; i++) structByIndex[i + 1] ?? const ({}, null)] : null;
  }

  @override
  State<XmpCard> createState() => _XmpCardState();
}

class _XmpCardState extends State<XmpCard> {
  final ValueNotifier<int> _indexNotifier = ValueNotifier(0);

  List<XmpExtractedCard>? get indexedStructs => widget.indexedStructs;

  bool get isIndexed => indexedStructs != null;

  int get indexedStructCount => indexedStructs?.length ?? 0;

  @override
  void initState() {
    super.initState();
    if (isIndexed) {
      _indexNotifier.value = indexedStructCount - 1;
    }
  }

  @override
  void didUpdateWidget(covariant XmpCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isIndexed && _indexNotifier.value >= indexedStructCount) {
      _indexNotifier.value = indexedStructCount - 1;
    }
  }

  @override
  void dispose() {
    _indexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _isIndexed = isIndexed;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _indexNotifier,
        builder: (context, index, child) {
          final data = _isIndexed ? indexedStructs![index] : widget.directStruct!;
          final props = data.$1.entries.map((kv) => XmpProp(kv.key, kv.value.value)).toList()..sort();
          final cards = data.$2;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: HighlightTitle(
                        title: widget.title,
                        showHighlight: false,
                      ),
                    ),
                    if (_isIndexed) ...[
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(AIcons.previous),
                        onPressed: index > 0 ? () => _setIndex(index - 1) : null,
                        tooltip: context.l10n.previousTooltip,
                      ),
                      HighlightTitle(
                        title: '${index + 1}',
                        showHighlight: false,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(AIcons.next),
                        onPressed: index < indexedStructCount - 1 ? () => _setIndex(index + 1) : null,
                        tooltip: context.l10n.nextTooltip,
                      ),
                    ]
                  ],
                ),
              ),
              MultiCrossFader(
                duration: ADurations.xmpStructArrayCardTransition,
                sizeCurve: Curves.easeOutBack,
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  // add padding at this level (instead of the column level)
                  // so that the crossfader can animate the content size
                  // without clipping the text
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: InfoRowGroup(
                    info: Map.fromEntries(props.map((prop) => MapEntry(prop.displayKey, widget.formatValue(prop)))),
                    spanBuilders: widget.spanBuilders?.call(_isIndexed ? index + 1 : null),
                  ),
                ),
              ),
              if (cards != null)
                ...cards.where((v) => !v.isEmpty).map((card) {
                  final spanBuilders = card.spanBuilders;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: XmpCard(
                      title: card.title,
                      structByIndex: card.data,
                      formatValue: widget.formatValue,
                      spanBuilders: spanBuilders != null ? (index) => spanBuilders(index, card.data[index]!.$1) : null,
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _setIndex(int index) => _indexNotifier.value = index.clamp(0, indexedStructCount - 1);
}
