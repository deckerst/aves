import 'package:aves/widgets/common/grid/header.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:flutter/material.dart';

class FilterChipSectionHeader extends StatelessWidget {
  final ChipSectionKey sectionKey;

  const FilterChipSectionHeader({
    Key key,
    @required this.sectionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      sectionKey: sectionKey,
      leading: sectionKey.leading,
      title: sectionKey.title,
      selectable: false,
    );
  }

  static double getPreferredHeight(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    return SectionHeader.leadingDimension * textScaleFactor + SectionHeader.padding.vertical;
  }
}
