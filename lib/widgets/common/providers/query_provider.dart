import 'package:aves/model/query.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class QueryProvider extends StatelessWidget {
  final String? initialQuery;
  final Widget child;

  const QueryProvider({
    super.key,
    required this.initialQuery,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Query>(
      create: (context) => Query(initialValue: initialQuery),
      child: child,
    );
  }
}
