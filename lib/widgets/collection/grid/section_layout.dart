import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/collection/grid/headers/any.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:flutter/material.dart';

class SectionedEntryListLayoutProvider extends SectionedListLayoutProvider<AvesEntry> {
  final CollectionLens collection;

  const SectionedEntryListLayoutProvider({
    Key? key,
    required this.collection,
    required double scrollableWidth,
    required TileLayout tileLayout,
    required int columnCount,
    required double spacing,
    required double horizontalPadding,
    required double tileExtent,
    required Widget Function(AvesEntry entry) tileBuilder,
    required Duration tileAnimationDelay,
    required Widget child,
  }) : super(
          key: key,
          scrollableWidth: scrollableWidth,
          tileLayout: tileLayout,
          columnCount: columnCount,
          spacing: spacing,
          horizontalPadding: horizontalPadding,
          tileWidth: tileExtent,
          tileHeight: tileExtent,
          tileBuilder: tileBuilder,
          tileAnimationDelay: tileAnimationDelay,
          child: child,
        );

  @override
  bool get showHeaders => collection.showHeaders;

  @override
  Map<SectionKey, List<AvesEntry>> get sections => collection.sections;

  @override
  double getHeaderExtent(BuildContext context, SectionKey sectionKey) {
    return CollectionSectionHeader.getPreferredHeight(context, scrollableWidth, collection.source, sectionKey);
  }

  @override
  Widget buildHeader(BuildContext context, SectionKey sectionKey, double headerExtent) {
    return CollectionSectionHeader(
      collection: collection,
      sectionKey: sectionKey,
      height: headerExtent,
    );
  }
}
