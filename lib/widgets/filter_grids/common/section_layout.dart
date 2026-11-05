import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/header.dart';
import 'package:aves/widgets/common/grid/sections/provider.dart';
import 'package:aves/widgets/filter_grids/common/section_header.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:material_ui/material_ui.dart';

class const SectionedFilterListLayoutProvider<T extends CollectionFilter>({
  super.key,
  @override required final Map<SectionKey, List<FilterGridItem<T>>> sections,
  @override required final bool showHeaders,
  required final bool selectable,
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
}) extends SectionedListLayoutProvider<FilterGridItem<T>> {
  @override
  double getHeaderExtent(BuildContext context, SectionKey sectionKey) {
    final headerExtent = sectionKey.getPreferredHeight(context, scrollableWidth);
    return headerExtent + SectionHeader.padding.vertical + SectionHeader.margin.vertical;
  }

  @override
  Widget buildHeader(BuildContext context, SectionKey sectionKey, double headerExtent) {
    return FilterChipSectionHeader<FilterGridItem<T>>(
      sectionKey: sectionKey as ChipSectionKey,
      selectable: selectable,
    );
  }
}
