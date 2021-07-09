import 'package:aves/model/selection.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SelectionProvider<T> extends StatelessWidget {
  final Widget child;

  const SelectionProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Selection<T>>(
      create: (context) => Selection<T>(),
      child: child,
    );
  }
}
