import 'dart:math';

import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/cards/card.dart';
import 'package:aves/widgets/viewer/info/metadata/model/xmp_card_data.dart';
import 'package:aves/widgets/viewer/info/metadata/model/xmp_prop.dart';
import 'package:material_ui/material_ui.dart';

typedef XmpExtractedCard = (Map<String, XmpProp>, List<XmpCardData>?);

class XmpCard({
  super.key,
  required final String title,
  required Map<int?, XmpExtractedCard> structByIndex,
  required final String Function(XmpProp prop) formatValue,
  final Map<String, InfoValueSpanBuilder> Function(int? index)? spanBuilders,
}) extends StatelessWidget {
  late final XmpExtractedCard? directStruct;
  late final List<XmpExtractedCard>? indexedStructs;

  this {
    directStruct = structByIndex[null];

    final length = structByIndex.keys.nonNulls.fold(0, max);
    indexedStructs = length > 0 ? [for (var i = 0; i < length; i++) structByIndex[i + 1] ?? const ({}, null)] : null;
  }

  @override
  Widget build(BuildContext context) {
    return MetadataCard(
      title: title,
      count: indexedStructs?.length ?? 0,
      indexedInfoGroupBuilder: _buildIndexedInfoGroup,
      subCardsBuilder: _buildSubCards,
    );
  }

  InfoRowGroup _buildIndexedInfoGroup(int? index) {
    final data = index != null ? indexedStructs![index] : directStruct!;
    final props = data.$1.entries.map((kv) => XmpProp(kv.key, kv.value.value)).toList()..sort();

    return InfoRowGroup(
      info: Map.fromEntries(props.map((prop) => MapEntry(prop.displayKey, formatValue(prop)))),
      spanBuilders: spanBuilders?.call(index != null ? index + 1 : null),
    );
  }

  List<Widget> _buildSubCards(int? index) {
    final data = index != null ? indexedStructs![index] : directStruct!;
    final cards = data.$2;

    if (cards == null) return [];

    return cards.where((v) => !v.isEmpty).map((card) {
      final spanBuilders = card.spanBuilders;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: XmpCard(
          title: card.title,
          structByIndex: card.data,
          formatValue: formatValue,
          spanBuilders: spanBuilders != null ? (index) => spanBuilders(index, card.data[index]!.$1) : null,
        ),
      );
    }).toList();
  }
}
