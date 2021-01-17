import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:aves/widgets/filter_grids/common/section_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SectionedFilterListLayoutProvider<T extends CollectionFilter> extends SectionedListLayoutProvider<FilterGridItem<T>> {
  const SectionedFilterListLayoutProvider({
    @required this.sections,
    @required this.showHeaders,
    @required double scrollableWidth,
    @required int columnCount,
    double spacing = 0,
    @required double tileExtent,
    @required Widget Function(FilterGridItem<T> gridItem) tileBuilder,
    @required Widget child,
  }) : super(
          scrollableWidth: scrollableWidth,
          columnCount: columnCount,
          spacing: spacing,
          tileExtent: tileExtent,
          tileBuilder: tileBuilder,
          child: child,
        );

  @override
  final Map<SectionKey, List<FilterGridItem<T>>> sections;

  @override
  final bool showHeaders;

  @override
  double getHeaderExtent(BuildContext context, SectionKey sectionKey) {
    return FilterChipSectionHeader.getPreferredHeight(context);
  }

  @override
  Widget buildHeader(BuildContext context, SectionKey sectionKey, double headerExtent) {
    return FilterChipSectionHeader(
      sectionKey: sectionKey,
    );
  }
}
