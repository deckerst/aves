import 'package:aves/model/query.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class const QueryProvider({
  super.key,
  final bool startEnabled = false,
  final String? initialQuery,
  required final Widget child,
}) extends StatelessWidget {
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
