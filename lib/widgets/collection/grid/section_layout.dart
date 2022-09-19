import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/collection/grid/headers/any.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:flutter/material.dart';

class SectionedEntryListLayoutProvider extends SectionedListLayoutProvider<AvesEntry> {
  final CollectionLens collection;
  final bool selectable;

  const SectionedEntryListLayoutProvider({
    super.key,
    required this.collection,
    required this.selectable,
    required super.scrollableWidth,
    required super.tileLayout,
    required super.columnCount,
    required super.spacing,
    required super.horizontalPadding,
    required double tileExtent,
    required super.tileBuilder,
    required super.tileAnimationDelay,
    required super.child,
  }) : super(
          tileWidth: tileExtent,
          tileHeight: tileExtent,
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
      selectable: selectable,
    );
  }
}
