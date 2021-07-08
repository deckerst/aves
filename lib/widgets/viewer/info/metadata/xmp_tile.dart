import 'dart:collection';

import 'package:aves/model/entry.dart';
import 'package:aves/ref/xmp.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class XmpDirTile extends StatefulWidget {
  final AvesEntry entry;
  final SplayTreeMap<String, String> tags;
  final ValueNotifier<String?>? expandedNotifier;
  final bool initiallyExpanded;

  const XmpDirTile({
    Key? key,
    required this.entry,
    required this.tags,
    required this.expandedNotifier,
    required this.initiallyExpanded,
  }) : super(key: key);

  @override
  _XmpDirTileState createState() => _XmpDirTileState();
}

class _XmpDirTileState extends State<XmpDirTile> {
  AvesEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final sections = groupBy<MapEntry<String, String>, String>(widget.tags.entries, (kv) {
      final fullKey = kv.key;
      final i = fullKey.indexOf(XMP.propNamespaceSeparator);
      final namespace = i == -1 ? '' : fullKey.substring(0, i);
      return namespace;
    }).entries.map((kv) => XmpNamespace.create(kv.key, Map.fromEntries(kv.value))).toList()
      ..sort((a, b) => compareAsciiUpperCase(a.displayTitle, b.displayTitle));
    return AvesExpansionTile(
      title: 'XMP',
      expandedNotifier: widget.expandedNotifier,
      initiallyExpanded: widget.initiallyExpanded,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.expand((section) => section.buildNamespaceSection()).toList(),
          ),
        ),
      ],
    );
  }
}
