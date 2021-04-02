import 'dart:async';

import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/quick_actions/available_actions.dart';
import 'package:aves/widgets/settings/quick_actions/common.dart';
import 'package:aves/widgets/settings/quick_actions/quick_actions.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QuickActionsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsViewerQuickActionsTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: QuickActionEditorPage.routeName),
            builder: (context) => QuickActionEditorPage(),
          ),
        );
      },
    );
  }
}

class QuickActionEditorPage extends StatefulWidget {
  static const routeName = '/settings/quick_actions';

  @override
  _QuickActionEditorPageState createState() => _QuickActionEditorPageState();
}

class _QuickActionEditorPageState extends State<QuickActionEditorPage> {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey(debugLabel: 'quick-actions-animated-list');
  Timer _targetLeavingTimer;
  List<EntryAction> _quickActions;
  final ValueNotifier<EntryAction> _draggedQuickAction = ValueNotifier(null);
  final ValueNotifier<EntryAction> _draggedAvailableAction = ValueNotifier(null);
  final ValueNotifier<bool> _quickActionHighlight = ValueNotifier(false);
  final ValueNotifier<bool> _availableActionHighlight = ValueNotifier(false);
  final AChangeNotifier _quickActionsChangeNotifier = AChangeNotifier();

  // use a flag to prevent quick action target accept/leave when already animating reorder
  // as dragging a button against axis direction messes index resolution while items pop in and out
  bool _reordering = false;

  static const quickActionVerticalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _quickActions = settings.viewerQuickActions.toList();
  }

  @override
  void dispose() {
    _stopLeavingTimer();
    super.dispose();
  }

  void _onQuickActionTargetLeave() {
    _stopLeavingTimer();
    final action = _draggedAvailableAction.value;
    _targetLeavingTimer = Timer(Durations.quickActionListAnimation + Duration(milliseconds: 50), () {
      _removeQuickAction(action);
      _quickActionHighlight.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final header = QuickActionButton(
      placement: QuickActionPlacement.header,
      panelHighlight: _quickActionHighlight,
      draggedQuickAction: _draggedQuickAction,
      draggedAvailableAction: _draggedAvailableAction,
      insertAction: _insertQuickAction,
      removeAction: _removeQuickAction,
      onTargetLeave: _onQuickActionTargetLeave,
    );
    final footer = QuickActionButton(
      placement: QuickActionPlacement.footer,
      panelHighlight: _quickActionHighlight,
      draggedQuickAction: _draggedQuickAction,
      draggedAvailableAction: _draggedAvailableAction,
      insertAction: _insertQuickAction,
      removeAction: _removeQuickAction,
      onTargetLeave: _onQuickActionTargetLeave,
    );
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsViewerQuickActionEditorTitle),
        ),
        body: WillPopScope(
          onWillPop: () {
            settings.viewerQuickActions = _quickActions;
            return SynchronousFuture(true);
          },
          child: SafeArea(
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(AIcons.info),
                      SizedBox(width: 16),
                      Expanded(child: Text(context.l10n.settingsViewerQuickActionEditorBanner)),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.l10n.settingsViewerQuickActionEditorDisplayedButtons,
                    style: Constants.titleTextStyle,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _quickActionHighlight,
                  builder: (context, highlight, child) => ActionPanel(
                    highlight: highlight,
                    child: child,
                  ),
                  child: Container(
                    height: OverlayButton.getSize(context) + quickActionVerticalPadding * 2,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: .5,
                            child: header,
                          ),
                        ),
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerRight,
                            widthFactor: .5,
                            child: footer,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: AnimatedList(
                            key: _animatedListKey,
                            initialItemCount: _quickActions.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index, animation) {
                              if (index >= _quickActions.length) return null;
                              final action = _quickActions[index];
                              return QuickActionButton(
                                placement: QuickActionPlacement.action,
                                action: action,
                                panelHighlight: _quickActionHighlight,
                                draggedQuickAction: _draggedQuickAction,
                                draggedAvailableAction: _draggedAvailableAction,
                                insertAction: _insertQuickAction,
                                removeAction: _removeQuickAction,
                                onTargetLeave: _onQuickActionTargetLeave,
                                child: _buildQuickActionButton(action, animation),
                              );
                            },
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _quickActionsChangeNotifier,
                          builder: (context, child) => _quickActions.isEmpty
                              ? Center(
                                  child: Text(
                                    context.l10n.settingsViewerQuickActionEmpty,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                )
                              : SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.l10n.settingsViewerQuickActionEditorAvailableButtons,
                    style: Constants.titleTextStyle,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _availableActionHighlight,
                  builder: (context, highlight, child) => ActionPanel(
                    highlight: highlight,
                    child: child,
                  ),
                  child: AvailableActionPanel(
                    quickActions: _quickActions,
                    quickActionsChangeNotifier: _quickActionsChangeNotifier,
                    panelHighlight: _availableActionHighlight,
                    draggedQuickAction: _draggedQuickAction,
                    draggedAvailableAction: _draggedAvailableAction,
                    removeQuickAction: _removeQuickAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _stopLeavingTimer() => _targetLeavingTimer?.cancel();

  bool _insertQuickAction(EntryAction action, QuickActionPlacement placement, EntryAction overAction) {
    if (action == null) return false;
    _stopLeavingTimer();
    if (_reordering) return false;

    final currentIndex = _quickActions.indexOf(action);
    final contained = currentIndex != -1;
    int targetIndex;
    switch (placement) {
      case QuickActionPlacement.header:
        targetIndex = 0;
        break;
      case QuickActionPlacement.footer:
        targetIndex = _quickActions.length - (contained ? 1 : 0);
        break;
      case QuickActionPlacement.action:
        targetIndex = _quickActions.indexOf(overAction);
        break;
    }
    if (currentIndex == targetIndex) return false;

    _reordering = true;
    _removeQuickAction(action);
    _quickActions.insert(targetIndex, action);
    _animatedListKey.currentState.insertItem(
      targetIndex,
      duration: Durations.quickActionListAnimation,
    );
    _quickActionsChangeNotifier.notifyListeners();
    Future.delayed(Durations.quickActionListAnimation).then((value) => _reordering = false);
    return true;
  }

  bool _removeQuickAction(EntryAction action) {
    if (!_quickActions.contains(action)) return false;

    final index = _quickActions.indexOf(action);
    _quickActions.removeAt(index);
    _animatedListKey.currentState.removeItem(
      index,
      (context, animation) => DraggedPlaceholder(child: _buildQuickActionButton(action, animation)),
      duration: Durations.quickActionListAnimation,
    );
    _quickActionsChangeNotifier.notifyListeners();
    return true;
  }

  Widget _buildQuickActionButton(EntryAction action, Animation<double> animation) {
    animation = animation.drive(CurveTween(curve: Curves.easeInOut));
    Widget child = FadeTransition(
      opacity: animation,
      child: SizeTransition(
        axis: Axis.horizontal,
        sizeFactor: animation,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: _QuickActionEditorPageState.quickActionVerticalPadding, horizontal: 4),
          child: OverlayButton(
            child: IconButton(
              icon: Icon(action.getIcon()),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    child = AnimatedBuilder(
      animation: Listenable.merge([_draggedQuickAction, _draggedAvailableAction]),
      builder: (context, child) {
        final dragged = _draggedQuickAction.value == action || _draggedAvailableAction.value == action;
        if (dragged) {
          child = DraggedPlaceholder(child: child);
        }
        return child;
      },
      child: child,
    );

    return child;
  }
}
