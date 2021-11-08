import 'package:aves/model/query.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class QueryProvider extends StatelessWidget {
  final Widget child;

  const QueryProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Query>(
      create: (context) => Query(),
      child: child,
    );
  }
}
