import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterQueryBar<T extends CollectionFilter> extends StatelessWidget {
  final ValueNotifier<String> queryNotifier;
  final FocusNode focusNode;

  const FilterQueryBar({
    super.key,
    required this.queryNotifier,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    return Container(
      height: getPreferredHeight(textScaleFactor),
      alignment: Alignment.topCenter,
      child: Selector<Selection<FilterGridItem<T>>, bool>(
        selector: (context, selection) => !selection.isSelecting,
        builder: (context, editable, child) => QueryBar(
          queryNotifier: queryNotifier,
          focusNode: focusNode,
          hintText: context.l10n.collectionSearchTitlesHintText,
          editable: editable,
        ),
      ),
    );
  }

  static double getPreferredHeight(double textScaleFactor) => QueryBar.getPreferredHeight(textScaleFactor);
}
