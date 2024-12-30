import 'package:aves/model/query.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class QueryProvider extends StatelessWidget {
  final bool startEnabled;
  final String? initialQuery;
  final Widget child;

  const QueryProvider({
    super.key,
    this.startEnabled = false,
    this.initialQuery,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Query>(
      create: (context) => Query(
        enabled: startEnabled,
        initialValue: initialQuery,
      ),
      child: child,
    );
  }
}
