import 'package:aves/services/common/services.dart';
import 'package:flutter/services.dart';
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final shouldPop = handlers.fold(true, (prev, v) => prev ? v(context) : false);
        if (shouldPop) {
          if (Navigator.canPop(context)) {
            Navigator.maybeOf(context)?.pop();
          } else {
            // exit
            reportService.log('Exit by pop');
            SystemNavigator.pop();
          }
        }
      },
      child: child,
    );
  }
}
