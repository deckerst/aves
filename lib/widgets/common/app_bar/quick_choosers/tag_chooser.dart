import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/common/menu.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';

class TagQuickChooser extends StatelessWidget {
  final ValueNotifier<CollectionFilter?> valueNotifier;
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
      itemBuilder: (context, filter) => AvesFilterChip(
        filter: filter,
        showGenericIcon: false,
      ),
    );
  }
}
