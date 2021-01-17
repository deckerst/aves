import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/collection/grid/headers/any.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SectionedEntryListLayoutProvider extends SectionedListLayoutProvider<ImageEntry> {
  final CollectionLens collection;

  const SectionedEntryListLayoutProvider({
    @required this.collection,
    @required double scrollableWidth,
    @required int columnCount,
    @required double tileExtent,
    @required Widget Function(ImageEntry entry) tileBuilder,
    @required Widget child,
  }) : super(
          scrollableWidth: scrollableWidth,
          columnCount: columnCount,
          tileExtent: tileExtent,
          tileBuilder: tileBuilder,
          child: child,
        );

  @override
  bool get showHeaders => collection.showHeaders;

  @override
  Map<SectionKey, List<ImageEntry>> get sections => collection.sections;

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
