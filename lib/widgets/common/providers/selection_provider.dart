import 'package:aves/model/selection.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SelectionProvider<T> extends StatelessWidget {
  final Widget child;
  final Set<T> Function(T item)? toSelectableItems;

  const SelectionProvider({
    super.key,
    this.toSelectableItems,
    required this.child,
  });

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
