import 'dart:async';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/filter_chooser.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';

class TagQuickChooser extends StatelessWidget {
  final ValueNotifier<CollectionFilter?> valueNotifier;
  final List<CollectionFilter> options;
  final Stream<Offset> pointerGlobalPosition;

  const TagQuickChooser({
    super.key,
    required this.valueNotifier,
    required this.options,
    required this.pointerGlobalPosition,
  });

  @override
  Widget build(BuildContext context) {
    return FilterQuickChooser<CollectionFilter>(
      valueNotifier: valueNotifier,
      options: options,
      pointerGlobalPosition: pointerGlobalPosition,
      buildFilterChip: (context, filter) => AvesFilterChip(
        filter: filter,
        showGenericIcon: false,
      ),
    );
  }
}
