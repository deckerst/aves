import 'package:aves/widgets/common/grid/header.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:flutter/material.dart';

class FilterChipSectionHeader<T> extends StatelessWidget {
  final ChipSectionKey sectionKey;
  final bool selectable;

  const FilterChipSectionHeader({
    super.key,
    required this.sectionKey,
    required this.selectable,
  });

  @override
  Widget build(BuildContext context) {
    return SectionHeader<T>(
      sectionKey: sectionKey,
      leading: sectionKey.leading,
      title: sectionKey.title,
      selectable: selectable,
    );
  }

  static double getPreferredHeight(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(SectionHeader.leadingSize.height) + SectionHeader.padding.vertical + SectionHeader.margin.vertical;
  }
}
