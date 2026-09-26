import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

// this widget combines multiple pop handlers with a guaranteed order
class const AvesPopScope({
  super.key,
  required final List<PopHandler> handlers,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blocker = handlers.firstWhereOrNull((v) => !v.canPop(context));
    return PopScope(
      canPop: blocker == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          blocker?.onPopBlocked(context);
        }
      },
      child: child,
    );
  }
}

abstract class PopHandler {
  bool canPop(BuildContext context);

  void onPopBlocked(BuildContext context);
}

class APopHandler({
  required final bool Function(BuildContext context) _canPop,
  required final void Function(BuildContext context) _onPopBlocked,
}) implements PopHandler {
  @override
  bool canPop(BuildContext context) => _canPop(context);

  @override
  void onPopBlocked(BuildContext context) => _onPopBlocked(context);
}

@immutable
class PopExitNotification extends Notification;
