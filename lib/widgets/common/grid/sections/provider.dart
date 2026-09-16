import 'package:aves/model/source/section_keys.dart';
import 'package:aves/widgets/common/grid/sections/calendar/section_layout_builder.dart';
import 'package:aves/widgets/common/grid/sections/fixed/section_layout_builder.dart';
import 'package:aves/widgets/common/grid/sections/list_layout.dart';
import 'package:aves/widgets/common/grid/sections/mosaic/section_layout_builder.dart';
import 'package:aves/widgets/common/grid/sections/section_layout_builder.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

typedef CoverRatioResolver<T> = double Function(T item);

abstract class const SectionedListLayoutProvider<T>({
  super.key,
  required final double scrollableWidth,
  required final TileLayout tileLayout,
  required final int columnCount,
  required final double spacing,
  required final double horizontalPadding,
  required final double tileWidth,
  required final double tileHeight,
  required final TileBuilder<T> tileBuilder,
  required final Duration tileAnimationDelay,
  required final CoverRatioResolver<T> coverRatioResolver,
  required final Widget child,
}) extends StatelessWidget {
  this : assert(scrollableWidth != 0);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider0<SectionedListLayout<T>>(
      update: (context, _) {
        switch (tileLayout) {
          case .mosaic:
            return MosaicSectionLayoutBuilder<T>(
              sections: sections,
              showHeaders: showHeaders,
              getHeaderExtent: getHeaderExtent,
              buildHeader: buildHeader,
              scrollableWidth: scrollableWidth,
              tileLayout: tileLayout,
              columnCount: columnCount,
              spacing: spacing,
              horizontalPadding: horizontalPadding,
              tileWidth: tileWidth,
              tileHeight: tileHeight,
              tileBuilder: tileBuilder,
              tileAnimationDelay: tileAnimationDelay,
              coverRatioResolver: coverRatioResolver,
            ).updateLayouts(context);
          case .grid:
          case .list:
            final isList = tileLayout == .list;
            return FixedExtentSectionLayoutBuilder<T>(
              sections: sections,
              showHeaders: showHeaders,
              getHeaderExtent: getHeaderExtent,
              buildHeader: buildHeader,
              scrollableWidth: scrollableWidth,
              tileLayout: tileLayout,
              columnCount: isList ? 1 : columnCount,
              spacing: spacing,
              horizontalPadding: horizontalPadding,
              tileWidth: isList ? contentWidth : tileWidth,
              tileHeight: tileHeight,
              tileBuilder: tileBuilder,
              tileAnimationDelay: tileAnimationDelay,
            ).updateLayouts(context);
          case .calendar:
            const columnCount = DateTime.daysPerWeek;
            final tileWidth = (contentWidth - spacing * (columnCount - 1)) / columnCount;
            return CalendarSectionLayoutBuilder<T>(
              sections: sections,
              showHeaders: showHeaders,
              getHeaderExtent: getHeaderExtent,
              buildHeader: buildHeader,
              scrollableWidth: scrollableWidth,
              tileLayout: .calendar,
              columnCount: columnCount,
              spacing: spacing,
              horizontalPadding: horizontalPadding,
              tileWidth: tileWidth,
              tileHeight: tileWidth,
              tileBuilder: tileBuilder,
              tileAnimationDelay: tileAnimationDelay,
              localizations: MaterialLocalizations.of(context),
            ).updateLayouts(context);
        }
      },
      child: child,
    );
  }

  double get contentWidth => scrollableWidth - (horizontalPadding * 2);

  bool get showHeaders;

  Map<SectionKey, List<T>> get sections;

  double getHeaderExtent(BuildContext context, SectionKey sectionKey);

  Widget buildHeader(BuildContext context, SectionKey sectionKey, double headerExtent);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('scrollableWidth', scrollableWidth));
    properties.add(EnumProperty<TileLayout>('tileLayout', tileLayout));
    properties.add(IntProperty('columnCount', columnCount));
    properties.add(DoubleProperty('spacing', spacing));
    properties.add(DoubleProperty('horizontalPadding', horizontalPadding));
    properties.add(DoubleProperty('tileWidth', tileWidth));
    properties.add(DoubleProperty('tileHeight', tileHeight));
    properties.add(DiagnosticsProperty<bool>('showHeaders', showHeaders));
  }
}
