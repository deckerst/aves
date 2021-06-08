import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/quick_actions/common.dart';
import 'package:flutter/material.dart';

enum QuickActionPlacement { header, action, footer }

class QuickActionButton extends StatelessWidget {
  final QuickActionPlacement placement;
  final EntryAction? action;
  final ValueNotifier<bool> panelHighlight;
  final ValueNotifier<EntryAction?> draggedQuickAction;
  final ValueNotifier<EntryAction?> draggedAvailableAction;
  final bool Function(EntryAction action, QuickActionPlacement placement, EntryAction? overAction) insertAction;
  final bool Function(EntryAction action) removeAction;
  final VoidCallback onTargetLeave;
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

  DragTarget<EntryAction> _buildDragTarget(Widget? child) {
    return DragTarget<EntryAction>(
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

  Widget _buildDraggable(Widget child, EntryAction action) => LongPressDraggable(
        data: action,
        maxSimultaneousDrags: 1,
        onDragStarted: () => _setDraggedQuickAction(action),
        // `onDragEnd` is only called when the widget is mounted,
        // so we rely on `onDraggableCanceled` and `onDragCompleted` instead
        onDraggableCanceled: (velocity, offset) => _setDraggedQuickAction(null),
        onDragCompleted: () => _setDraggedQuickAction(null),
        feedback: MediaQueryDataProvider(
          child: ActionButton(
            action: action,
            showCaption: false,
          ),
        ),
        childWhenDragging: child,
        child: child,
      );

  void _setDraggedQuickAction(EntryAction? action) => draggedQuickAction.value = action;

  void _setPanelHighlight(bool flag) => panelHighlight.value = flag;
}
