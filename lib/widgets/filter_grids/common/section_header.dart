import 'package:aves/widgets/common/grid/header.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:flutter/material.dart';

class FilterChipSectionHeader<T> extends StatelessWidget {
  final ChipSectionKey sectionKey;

  const FilterChipSectionHeader({
    super.key,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    return SectionHeader<T>(
      sectionKey: sectionKey,
      leading: sectionKey.leading,
      title: sectionKey.title,
    );
  }

  static double getPreferredHeight(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    return SectionHeader.leadingSize.height * textScaleFactor + SectionHeader.padding.vertical;
  }
}
