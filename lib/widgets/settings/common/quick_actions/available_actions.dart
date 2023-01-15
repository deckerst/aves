import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/common/quick_actions/placeholder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AvailableActionPanel<T extends Object> extends StatelessWidget {
  final List<T> allActions, quickActions;
  final Listenable quickActionsChangeNotifier;
  final ValueNotifier<bool> panelHighlight;
  final ValueNotifier<T?> draggedQuickAction;
  final ValueNotifier<T?> draggedAvailableAction;
  final bool Function(T? action) removeQuickAction;
  final Widget Function(T action) actionIcon;
  final String Function(BuildContext context, T action) actionText;

  static const double spacing = 8;
  static const double runSpacing = 20;
  static const padding = EdgeInsets.symmetric(vertical: 16, horizontal: 8);

  const AvailableActionPanel({
    super.key,
    required this.allActions,
    required this.quickActions,
    required this.quickActionsChangeNotifier,
    required this.panelHighlight,
    required this.draggedQuickAction,
    required this.draggedAvailableAction,
    required this.removeQuickAction,
    required this.actionIcon,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
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
          builder: (context, child) {
            return Padding(
              padding: padding,
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: spacing,
                runSpacing: runSpacing,
                children: allActions.map((action) {
                  final dragged = action == draggedAvailableAction.value;
                  final enabled = dragged || !quickActions.contains(action);
                  var child = _buildActionButton(context, action, enabled: enabled);
                  if (dragged) {
                    child = DraggedPlaceholder(child: child);
                  }
                  if (enabled) {
                    child = _buildDraggable(context, action, child);
                  }
                  return child;
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDraggable(
    BuildContext context,
    T action,
    Widget child,
  ) =>
      LongPressDraggable<T>(
        feedback: MediaQueryDataProvider(
          child: _buildActionButton(
            context,
            action,
            showCaption: false,
          ),
        ),
        data: action,
        dragAnchorStrategy: (draggable, context, position) {
          return childDragAnchorStrategy(draggable, context, position) + Offset(0, OverlayButton.getSize(context));
        },
        maxSimultaneousDrags: 1,
        onDragStarted: () => _setDraggedAvailableAction(action),
        onDragEnd: (details) => _setDraggedAvailableAction(null),
        childWhenDragging: child,
        child: child,
      );

  Widget _buildActionButton(
    BuildContext context,
    T action, {
    bool enabled = true,
    bool showCaption = true,
  }) =>
      CaptionedButton(
        icon: actionIcon(action),
        caption: actionText(context, action),
        showCaption: showCaption,
        onPressed: enabled ? () {} : null,
      );

  void _setDraggedQuickAction(T? action) => draggedQuickAction.value = action;

  void _setDraggedAvailableAction(T? action) => draggedAvailableAction.value = action;

  void _setPanelHighlight(bool flag) => panelHighlight.value = flag;

  static double heightFor(BuildContext context, List<String> captions, double width) {
    final buttonSizes = captions.map((v) => CaptionedButton.getSize(context, v, showCaption: true));
    final actionsPerRun = (width - padding.horizontal + spacing) ~/ (buttonSizes.first.width + spacing);
    final runCount = (captions.length / actionsPerRun).ceil();
    var height = runSpacing * (runCount - 1) + padding.vertical / 2;
    for (var i = 0; i < runCount; i++) {
      height += buttonSizes.skip(i * actionsPerRun).take(actionsPerRun).map((v) => v.height).max;
    }
    return height;
  }
}
