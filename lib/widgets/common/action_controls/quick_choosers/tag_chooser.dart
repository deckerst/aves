import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/button.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/menu.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/filter_quick_chooser_mixin.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:material_ui/material_ui.dart';

class const TagQuickChooser({
  super.key,
  required final ValueNotifier<Set<CollectionFilter>> valuesNotifier,
  @override required final List<CollectionFilter> options,
  required final bool blurred,
  required final PopupMenuPosition chooserPosition,
  required final Stream<Offset> pointerGlobalPosition,
  required final ValueNotifier<SelectionMode> selectionModeNotifier,
}) extends StatelessWidget with FilterQuickChooserMixin<CollectionFilter> {
  @override
  Widget build(BuildContext context) {
    return MenuQuickChooser<CollectionFilter>(
      selectedValuesNotifier: valuesNotifier,
      options: options,
      autoReverse: true,
      blurred: blurred,
      chooserPosition: chooserPosition,
      pointerGlobalPosition: pointerGlobalPosition,
      selectionModeNotifier: selectionModeNotifier,
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
