import 'package:aves/model/collection_filters.dart';
import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class XmpTagSectionSliver extends AnimatedWidget {
  final CollectionLens collection;
  final ImageEntry entry;
  final FilterCallback onFilter;

  XmpTagSectionSliver({
    Key key,
    @required this.collection,
    @required this.entry,
    @required this.onFilter,
  }) : super(key: key, listenable: entry.metadataChangeNotifier);

  @override
  Widget build(BuildContext context) {
    final tags = entry.xmpSubjects..sort(compareAsciiUpperCase);
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        tags.isEmpty
            ? []
            : [
                const SectionRow(OMIcons.localOffer),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AvesFilterChip.buttonBorderWidth / 2),
                  child: Wrap(
                    spacing: 8,
                    children: tags
                        .map((tag) => TagFilter(tag))
                        .map((filter) => AvesFilterChip.fromFilter(
                              filter,
                              onPressed: onFilter,
                            ))
                        .toList(),
                  ),
                ),
              ],
      ),
    );
  }
}
