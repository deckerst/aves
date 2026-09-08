import 'package:aves/widgets/common/grid/header.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:material_ui/material_ui.dart';

class const FilterChipSectionHeader<T>({
  super.key,
  required final ChipSectionKey sectionKey,
  required final bool selectable,
}) extends StatelessWidget {
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
