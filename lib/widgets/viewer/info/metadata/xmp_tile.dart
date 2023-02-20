import 'dart:collection';
import 'dart:convert';

import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class XmpDirTileBody extends StatefulWidget {
  final SplayTreeMap<String, String> allTags, tags;

  const XmpDirTileBody({
    super.key,
    required this.allTags,
    required this.tags,
  });

  @override
  State<XmpDirTileBody> createState() => _XmpDirTileBodyState();
}

class _XmpDirTileBodyState extends State<XmpDirTileBody> {
  late final Map<String, String> _schemaRegistryPrefixes, _tags;

  static const schemaRegistryPrefixesKey = 'schemaRegistryPrefixes';

  @override
  void initState() {
    super.initState();
    _tags = Map.from(widget.tags)..remove(schemaRegistryPrefixesKey);
    final prefixesJson = widget.allTags[schemaRegistryPrefixesKey];
    final Map<String, dynamic> prefixesDecoded = prefixesJson != null ? jsonDecode(prefixesJson) : {};
    _schemaRegistryPrefixes = Map.fromEntries(prefixesDecoded.entries.map((kv) => MapEntry(kv.key, kv.value as String)));
  }

  @override
  Widget build(BuildContext context) {
    final sections = groupBy<MapEntry<String, String>, String>(_tags.entries, (kv) {
      final fullKey = kv.key;
      final i = fullKey.indexOf(XMP.propNamespaceSeparator);
      final nsPrefix = i == -1 ? '' : fullKey.substring(0, i + 1);
      return nsPrefix;
    }).entries.map((kv) {
      final nsPrefix = kv.key;
      final rawProps = Map.fromEntries(kv.value);
      return XmpNamespace.create(_schemaRegistryPrefixes, nsPrefix, rawProps);
    }).toList()
      ..sort((a, b) => compareAsciiUpperCase(a.displayTitle, b.displayTitle));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.expand((section) => section.buildNamespaceSection(context)).toList(),
    );
  }
}
