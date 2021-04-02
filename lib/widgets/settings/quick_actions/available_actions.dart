import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/quick_actions/common.dart';
import 'package:flutter/material.dart';

class AvailableActionPanel extends StatelessWidget {
  final List<EntryAction> quickActions;
  final Listenable quickActionsChangeNotifier;
  final ValueNotifier<bool> panelHighlight;
  final ValueNotifier<EntryAction> draggedQuickAction;
  final ValueNotifier<EntryAction> draggedAvailableAction;
  final bool Function(EntryAction action) removeQuickAction;

  const AvailableActionPanel({
    @required this.quickActions,
    @required this.quickActionsChangeNotifier,
    @required this.panelHighlight,
    @required this.draggedQuickAction,
    @required this.draggedAvailableAction,
    @required this.removeQuickAction,
  });

  static const allActions = [
    EntryAction.info,
    EntryAction.toggleFavourite,
    EntryAction.share,
    EntryAction.delete,
    EntryAction.rename,
    EntryAction.export,
    EntryAction.print,
    EntryAction.viewSource,
    EntryAction.flip,
    EntryAction.rotateCCW,
    EntryAction.rotateCW,
  ];

  @override
  Widget build(BuildContext context) {
    return DragTarget<EntryAction>(
      onWillAccept: (data) {
        if (draggedQuickAction.value != null) {
          _setPanelHighlight(true);
        }
        return true;
      },
      onAcceptWithDetails: (details) {
        removeQuickAction(draggedQuickAction.value);
        _setDraggedQuickAction(null);
        _setPanelHighlight(false);
      },
      onLeave: (data) => _setPanelHighlight(false),
      builder: (context, accepted, rejected) {
        return AnimatedBuilder(
          animation: Listenable.merge([quickActionsChangeNotifier, draggedAvailableAction]),
          builder: (context, child) => Padding(
            padding: EdgeInsets.all(8),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 8,
              runSpacing: 8,
              children: allActions.map((action) {
                final dragged = action == draggedAvailableAction.value;
                final enabled = dragged || !quickActions.contains(action);
                Widget child = ActionButton(
                  action: action,
                  enabled: enabled,
                );
                if (dragged) {
                  child = DraggedPlaceholder(child: child);
                }
                if (enabled) {
                  child = _buildDraggable(action, child);
                }
                return child;
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggable(EntryAction action, Widget child) => LongPressDraggable<EntryAction>(
        data: action,
        maxSimultaneousDrags: 1,
        onDragStarted: () => _setDraggedAvailableAction(action),
        onDragEnd: (details) => _setDraggedAvailableAction(null),
        feedback: MediaQueryDataProvider(
          child: ActionButton(
            action: action,
            showCaption: false,
          ),
        ),
        childWhenDragging: child,
        child: child,
      );

  void _setDraggedQuickAction(EntryAction action) => draggedQuickAction.value = action;

  void _setDraggedAvailableAction(EntryAction action) => draggedAvailableAction.value = action;

  void _setPanelHighlight(bool flag) => panelHighlight.value = flag;
}
