import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/menu.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/filter_quick_chooser_mixin.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class TagQuickChooser extends StatelessWidget with FilterQuickChooserMixin<CollectionFilter> {
  final ValueNotifier<CollectionFilter?> valueNotifier;
  @override
  final List<CollectionFilter> options;
  final bool blurred;
  final PopupMenuPosition chooserPosition;
  final Stream<Offset> pointerGlobalPosition;

  const TagQuickChooser({
    super.key,
    required this.valueNotifier,
    required this.options,
    required this.blurred,
    required this.chooserPosition,
    required this.pointerGlobalPosition,
  });

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
