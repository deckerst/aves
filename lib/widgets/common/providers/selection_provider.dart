import 'package:aves/model/selection.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class const SelectionProvider<T>({
  super.key,
  final Set<T> Function(T item)? toSelectableItems,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Selection<T>>(
      create: (context) => Selection<T>(
        toSelectableItems: toSelectableItems,
      ),
      child: child,
    );
  }
}
