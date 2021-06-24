import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:flutter/widgets.dart';

enum QuickActionPlacement { header, action, footer }

class QuickActionButton<T extends Object> extends StatelessWidget {
  final QuickActionPlacement placement;
  final T? action;
  final ValueNotifier<bool> panelHighlight;
  final ValueNotifier<T?> draggedQuickAction;
  final ValueNotifier<T?> draggedAvailableAction;
  final bool Function(T action, QuickActionPlacement placement, T? overAction) insertAction;
  final bool Function(T action) removeAction;
  final VoidCallback onTargetLeave;
  final Widget Function(T action)? draggableFeedbackBuilder;
  final Widget? child;

  const QuickActionButton({
    required this.placement,
    this.action,
    required this.panelHighlight,
    required this.draggedQuickAction,
    required this.draggedAvailableAction,
    required this.insertAction,
    required this.removeAction,
    required this.onTargetLeave,
    this.draggableFeedbackBuilder,
    this.child,
  });

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
      onWillAccept: (data) {
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
        data: action,
        maxSimultaneousDrags: 1,
        onDragStarted: () => _setDraggedQuickAction(action),
        // `onDragEnd` is only called when the widget is mounted,
        // so we rely on `onDraggableCanceled` and `onDragCompleted` instead
        onDraggableCanceled: (velocity, offset) => _setDraggedQuickAction(null),
        onDragCompleted: () => _setDraggedQuickAction(null),
        feedback: MediaQueryDataProvider(
          child: draggableFeedbackBuilder!(action),
        ),
        childWhenDragging: child,
        child: child,
      );

  void _setDraggedQuickAction(T? action) => draggedQuickAction.value = action;

  void _setPanelHighlight(bool flag) => panelHighlight.value = flag;
}
