import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/menu.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/filter_quick_chooser_mixin.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:material_ui/material_ui.dart';

class const TagQuickChooser({
  super.key,
  required final ValueNotifier<CollectionFilter?> valueNotifier,
  @override required final List<CollectionFilter> options,
  required final bool blurred,
  required final PopupMenuPosition chooserPosition,
  required final Stream<Offset> pointerGlobalPosition,
}) extends StatelessWidget with FilterQuickChooserMixin<CollectionFilter> {
  @override
  Widget build(BuildContext context) {
    return MenuQuickChooser<CollectionFilter>(
      valueNotifier: valueNotifier,
      options: options,
      autoReverse: true,
      blurred: blurred,
      chooserPosition: chooserPosition,
      pointerGlobalPosition: pointerGlobalPosition,
      maxTotalOptionCount: FilterQuickChooserMixin.maxTotalOptionCount,
      itemHeight: computeItemHeight(context),
      contentWidth: computeLargestItemWidth,
      itemBuilder: itemBuilder,
      emptyBuilder: (context) => Text(context.l10n.tagEmpty),
    );
  }

  @override
  CollectionFilter buildFilter(BuildContext context, CollectionFilter option) => option;
}
