import 'dart:collection';

import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/brand_colors.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/xmp.dart';
import 'package:aves/widgets/common/aves_expansion_tile.dart';
import 'package:aves/widgets/common/highlight_title.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:aves/widgets/fullscreen/info/metadata/metadata_thumbnail.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XmpDirTile extends StatelessWidget {
  final ImageEntry entry;
  final SplayTreeMap<String, String> tags;
  final ValueNotifier<String> expandedNotifier;

  const XmpDirTile({
    @required this.entry,
    @required this.tags,
    @required this.expandedNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = MetadataThumbnails(source: MetadataThumbnailSource.xmp, entry: entry);
    final sections = SplayTreeMap.of(
      groupBy<MapEntry<String, String>, String>(tags.entries, (kv) {
        final fullKey = kv.key;
        final i = fullKey.indexOf(XMP.namespaceSeparator);
        if (i == -1) return '';
        final namespace = fullKey.substring(0, i);
        return XMP.namespaces[namespace] ?? namespace;
      }),
      compareAsciiUpperCase,
    );
    return AvesExpansionTile(
      title: 'XMP',
      expandedNotifier: expandedNotifier,
      children: [
        if (thumbnail != null) thumbnail,
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.entries.expand((sectionEntry) {
              final title = sectionEntry.key;

              final entries = sectionEntry.value.map((kv) {
                final key = kv.key.splitMapJoin(XMP.structFieldSeparator, onNonMatch: (s) {
                  // strip namespace
                  final key = s.split(XMP.namespaceSeparator).last;
                  // uppercase first letter
                  return key.replaceFirstMapped(RegExp('.'), (m) => m.group(0).toUpperCase());
                });
                return MapEntry(key, kv.value);
              }).toList()
                ..sort((a, b) => compareAsciiUpperCaseNatural(a.key, b.key));
              return [
                if (title.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: HighlightTitle(
                      title,
                      color: BrandColors.get(title),
                    ),
                  ),
                InfoRowGroup(Map.fromEntries(entries), maxValueLength: Constants.infoGroupMaxValueLength),
              ];
            }).toList(),
          ),
        ),
      ],
    );
  }
}
