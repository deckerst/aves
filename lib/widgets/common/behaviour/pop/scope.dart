import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

// this widget combines multiple pop handlers with a guaranteed order
class AvesPopScope extends StatelessWidget {
  final List<PopHandler> handlers;
  final Widget child;

  const AvesPopScope({
    super.key,
    required this.handlers,
    required this.child,
  });

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

class APopHandler implements PopHandler {
  final bool Function(BuildContext context) _canPop;
  final void Function(BuildContext context) _onPopBlocked;

  APopHandler({
    required bool Function(BuildContext context) canPop,
    required void Function(BuildContext context) onPopBlocked,
  })  : _canPop = canPop,
        _onPopBlocked = onPopBlocked;

  @override
  bool canPop(BuildContext context) => _canPop(context);

  @override
  void onPopBlocked(BuildContext context) => _onPopBlocked(context);
}

@immutable
class PopExitNotification extends Notification {}
