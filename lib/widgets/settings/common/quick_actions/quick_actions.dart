import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:flutter/widgets.dart';

enum QuickActionPlacement { header, action, footer }

// `T extends Object` because of `DragTarget` constraint
class const QuickActionButton<T extends Object>({
  super.key,
  required final QuickActionPlacement placement,
  final T? action,
  required final ValueNotifier<bool> panelHighlight,
  required final ValueNotifier<T?> draggedQuickAction,
  required final ValueNotifier<T?> draggedAvailableAction,
  required final bool Function(T action, QuickActionPlacement placement, T? overAction) insertAction,
  required final bool Function(T action) removeAction,
  required final VoidCallback onTargetLeave,
  final Widget Function(T action)? draggableFeedbackBuilder,
  final Widget? child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var child = this.child;
    child = _buildDragTarget(child);
    if (action != null) {
      child = _buildDraggable(child, action!);
    }
    return child;
  }

  DragTarget<T> _buildDragTarget(Widget? child) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) {
        if (draggedQuickAction.value != null) {
          insertAction(draggedQuickAction.value!, placement, action);
        }
        if (draggedAvailableAction.value != null) {
          insertAction(draggedAvailableAction.value!, placement, action);
          _setPanelHighlight(true);
        }
        return true;
      },
      onAcceptWithDetails: (details) => _setPanelHighlight(false),
      onLeave: (data) => onTargetLeave(),
      builder: (context, accepted, rejected) => child ?? const SizedBox(),
    );
  }

  Widget _buildDraggable(Widget child, T action) => LongPressDraggable(
    feedback: MediaQueryDataProvider(
      child: draggableFeedbackBuilder!(action),
    ),
    data: action,
    dragAnchorStrategy: (draggable, context, position) {
      return childDragAnchorStrategy(draggable, context, position) + Offset(0, OverlayButton.getSize(context));
    },
    maxSimultaneousDrags: 1,
    onDragStarted: () => _setDraggedQuickAction(action),
    // `onDragEnd` is only called when the widget is mounted,
    // so we rely on `onDraggableCanceled` and `onDragCompleted` instead
    onDraggableCanceled: (velocity, offset) => _setDraggedQuickAction(null),
    onDragCompleted: () => _setDraggedQuickAction(null),
    delay: settings.longPressTimeout,
    childWhenDragging: child,
    child: child,
  );

  void _setDraggedQuickAction(T? action) => draggedQuickAction.value = action;

  void _setPanelHighlight(bool flag) => panelHighlight.value = flag;
}
