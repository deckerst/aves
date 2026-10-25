import 'dart:collection';

import 'package:aves/utils/string_utils.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:aves/widgets/viewer/info/metadata/cards/card.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class const JsonCard({
  super.key,
  required final String titleKey,
  required final Object? content,
  final Map<String, InfoValueSpanBuilder> Function(SplayTreeMap<String, String> tags)? getLinkHandlers,
  final EdgeInsets? padding,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildContentCard(context, titleKey, content, padding: padding) ?? const SizedBox();
  }

  Widget? _buildContentCard(BuildContext context, String titleKey, Object? o, {EdgeInsets? padding}) {
    if (o == null) return null;
    if (o is List) return _buildMapListCard(context, titleKey, o, padding: padding);
    if (o is Map) return _buildMapCard(context, titleKey, o, padding: padding);
    return Text('$o');
  }

  Widget _buildMapListCard(BuildContext context, String titleKey, Object o, {EdgeInsets? padding}) {
    if (o is! List) return Text('$o');

    final contents = o as List<Object?>;
    if (contents.isEmpty) return const SizedBox();

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: MetadataCard(
        title: formatKey(titleKey),
        count: contents.length,
        indexedInfoGroupBuilder: (index) {
          final content = contents[index!] as Map<String, Object?>;
          final subKeys = content.entries.where((kv) => isMapOrMapList(kv.value)).map((kv) => kv.key).toSet();
          final infoEntries = content.entries.whereNot((kv) => subKeys.contains(kv.key)).toSet();
          final info = SplayTreeMap.of(Map.fromEntries(infoEntries.map((kv) => MapEntry(formatKey(kv.key), kv.value.toString()))));

          return InfoRowGroup(
            info: info,
            spanBuilders: getLinkHandlers?.call(info),
          );
        },
        subCardsBuilder: (index) {
          final content = contents[index!] as Map<String, Object?>;
          final subKeys = content.entries.where((kv) => isMapOrMapList(kv.value)).map((kv) => kv.key).toList().sorted();

          return subKeys.map((key) => _buildContentCard(context, key, content[key])).nonNulls.toList();
        },
      ),
    );
  }

  Widget _buildMapCard(BuildContext context, String titleKey, Object o, {EdgeInsets? padding}) {
    if (o is! Map) return Text('$o');

    final content = o as Map<String, Object?>;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: MetadataCard(
        title: formatKey(titleKey),
        count: 0,
        indexedInfoGroupBuilder: (index) {
          final subKeys = content.entries.where((kv) => isMapOrMapList(kv.value)).map((kv) => kv.key).toSet();
          final infoEntries = content.entries.whereNot((kv) => subKeys.contains(kv.key)).toSet();
          final info = SplayTreeMap.of(Map.fromEntries(infoEntries.map((kv) => MapEntry(formatKey(kv.key), kv.value.toString()))));

          return InfoRowGroup(
            info: info,
            spanBuilders: getLinkHandlers?.call(info),
          );
        },
        subCardsBuilder: (index) {
          final subKeys = content.entries.where((kv) => isMapOrMapList(kv.value)).map((kv) => kv.key).toList().sorted();

          return subKeys.map((key) => _buildContentCard(context, key, content[key])).nonNulls.toList();
        },
      ),
    );
  }

  static String formatKey(String key) {
    return key.replaceAll('_', ' ').toSentenceCase();
  }

  static bool isMapOrMapList(Object? o) {
    if (o is Map) return true;
    if (o is List) {
      if (o.isEmpty || o.first is Map) return true;
    }
    return false;
  }
}
