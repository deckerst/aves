import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/provider.dart';
import 'package:aves/widgets/filter_grids/common/section_header.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:flutter/material.dart';

class SectionedFilterListLayoutProvider<T extends CollectionFilter> extends SectionedListLayoutProvider<FilterGridItem<T>> {
  final bool selectable;

  const SectionedFilterListLayoutProvider({
    super.key,
    required this.sections,
    required this.showHeaders,
    required this.selectable,
    required super.scrollableWidth,
    required super.tileLayout,
    required super.columnCount,
    required super.spacing,
    required super.horizontalPadding,
    required super.tileWidth,
    required super.tileHeight,
    required super.tileBuilder,
    required super.tileAnimationDelay,
    required super.coverRatioResolver,
    required super.child,
  });

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
    return FilterChipSectionHeader<FilterGridItem<T>>(
      sectionKey: sectionKey as ChipSectionKey,
      selectable: selectable,
    );
  }
}
