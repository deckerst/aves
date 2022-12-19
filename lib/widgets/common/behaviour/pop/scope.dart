import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// as of Flutter v3.3.10, the resolution order of multiple `WillPopScope` is random
// so this widget combines multiple handlers with a guaranteed order
class AvesPopScope extends StatelessWidget {
  final List<bool Function(BuildContext context)> handlers;
  final Widget child;

  const AvesPopScope({
    super.key,
    required this.handlers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => SynchronousFuture(handlers.fold(true, (prev, v) => prev ? v(context) : false)),
      child: child,
    );
  }
}
