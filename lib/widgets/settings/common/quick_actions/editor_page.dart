import 'dart:async';

import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/settings/common/quick_actions/action_button.dart';
import 'package:aves/widgets/settings/common/quick_actions/action_panel.dart';
import 'package:aves/widgets/settings/common/quick_actions/available_actions.dart';
import 'package:aves/widgets/settings/common/quick_actions/placeholder.dart';
import 'package:aves/widgets/settings/common/quick_actions/quick_actions.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QuickActionEditorPage<T extends Object> extends StatelessWidget {
  final String title, bannerText;
  final List<T> allAvailableActions;
  final Widget? Function(T action) actionIcon;
  final String Function(BuildContext context, T action) actionText;
  final List<T> Function() load;
  final void Function(List<T> actions) save;

  const QuickActionEditorPage({
    super.key,
    required this.title,
    required this.bannerText,
    required this.allAvailableActions,
    required this.actionIcon,
    required this.actionText,
    required this.load,
    required this.save,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SafeArea(
          child: QuickActionEditorBody(
            bannerText: bannerText,
            allAvailableActions: allAvailableActions,
            actionIcon: actionIcon,
            actionText: actionText,
            load: load,
            save: save,
          ),
        ),
      ),
    );
  }
}

class QuickActionEditorBody<T extends Object> extends StatefulWidget {
  final String bannerText;
  final List<T> allAvailableActions;
  final Widget? Function(T action) actionIcon;
  final String Function(BuildContext context, T action) actionText;
  final List<T> Function() load;
  final void Function(List<T> actions) save;

  const QuickActionEditorBody({
    super.key,
    required this.bannerText,
    required this.allAvailableActions,
    required this.actionIcon,
    required this.actionText,
    required this.load,
    required this.save,
  });

  @override
  State<QuickActionEditorBody<T>> createState() => _QuickActionEditorBodyState<T>();
}

class _QuickActionEditorBodyState<T extends Object> extends State<QuickActionEditorBody<T>> with AutomaticKeepAliveClientMixin {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey(debugLabel: 'quick-actions-animated-list');
  Timer? _targetLeavingTimer;
  late List<T> _quickActions;
  final ValueNotifier<T?> _draggedQuickAction = ValueNotifier(null);
  final ValueNotifier<T?> _draggedAvailableAction = ValueNotifier(null);
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
    _quickActions = widget.load().toList();
  }

  @override
  void dispose() {
    _stopLeavingTimer();
    super.dispose();
  }

  void _onQuickActionTargetLeave() {
    _stopLeavingTimer();
    final action = _draggedAvailableAction.value;
    _targetLeavingTimer = Timer(Durations.quickActionListAnimation + const Duration(milliseconds: 50), () {
      _removeQuickAction(action);
      _quickActionHighlight.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final header = QuickActionButton<T>(
      placement: QuickActionPlacement.header,
      panelHighlight: _quickActionHighlight,
      draggedQuickAction: _draggedQuickAction,
      draggedAvailableAction: _draggedAvailableAction,
      insertAction: _insertQuickAction,
      removeAction: _removeQuickAction,
      onTargetLeave: _onQuickActionTargetLeave,
    );
    final footer = QuickActionButton<T>(
      placement: QuickActionPlacement.footer,
      panelHighlight: _quickActionHighlight,
      draggedQuickAction: _draggedQuickAction,
      draggedAvailableAction: _draggedAvailableAction,
      insertAction: _insertQuickAction,
      removeAction: _removeQuickAction,
      onTargetLeave: _onQuickActionTargetLeave,
    );
    return WillPopScope(
      onWillPop: () {
        widget.save(_quickActions);
        return SynchronousFuture(true);
      },
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(AIcons.info),
                const SizedBox(width: 16),
                Expanded(child: Text(widget.bannerText)),
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              context.l10n.settingsViewerQuickActionEditorDisplayedButtons,
              style: Constants.titleTextStyle,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _quickActionHighlight,
            builder: (context, highlight, child) => ActionPanel(
              highlight: highlight,
              child: child!,
            ),
            child: SizedBox(
              height: OverlayButton.getSize(context) + quickActionVerticalPadding * 2,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: .5,
                      child: header,
                    ),
                  ),
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerEnd,
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
                        if (index >= _quickActions.length) return const SizedBox();
                        final action = _quickActions[index];
                        return QuickActionButton<T>(
                          placement: QuickActionPlacement.action,
                          action: action,
                          panelHighlight: _quickActionHighlight,
                          draggedQuickAction: _draggedQuickAction,
                          draggedAvailableAction: _draggedAvailableAction,
                          insertAction: _insertQuickAction,
                          removeAction: _removeQuickAction,
                          onTargetLeave: _onQuickActionTargetLeave,
                          draggableFeedbackBuilder: (action) => ActionButton(
                            text: widget.actionText(context, action),
                            icon: widget.actionIcon(action),
                            showCaption: false,
                          ),
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
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.l10n.settingsViewerQuickActionEditorAvailableButtons,
              style: Constants.titleTextStyle,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _availableActionHighlight,
            builder: (context, highlight, child) => ActionPanel(
              highlight: highlight,
              child: child!,
            ),
            child: AvailableActionPanel<T>(
              allActions: widget.allAvailableActions,
              quickActions: _quickActions,
              quickActionsChangeNotifier: _quickActionsChangeNotifier,
              panelHighlight: _availableActionHighlight,
              draggedQuickAction: _draggedQuickAction,
              draggedAvailableAction: _draggedAvailableAction,
              removeQuickAction: _removeQuickAction,
              actionIcon: widget.actionIcon,
              actionText: widget.actionText,
            ),
          ),
        ],
      ),
    );
  }

  void _stopLeavingTimer() => _targetLeavingTimer?.cancel();

  bool _insertQuickAction(T action, QuickActionPlacement placement, T? overAction) {
    _stopLeavingTimer();
    if (_reordering) return false;

    final currentIndex = _quickActions.indexOf(action);
    final contained = currentIndex != -1;
    int? targetIndex;
    switch (placement) {
      case QuickActionPlacement.header:
        targetIndex = 0;
        break;
      case QuickActionPlacement.footer:
        targetIndex = _quickActions.length - (contained ? 1 : 0);
        break;
      case QuickActionPlacement.action:
        targetIndex = _quickActions.indexOf(overAction!);
        break;
    }
    if (currentIndex == targetIndex) return false;

    _reordering = true;
    _removeQuickAction(action);
    _quickActions.insert(targetIndex, action);
    _animatedListKey.currentState!.insertItem(
      targetIndex,
      duration: Durations.quickActionListAnimation,
    );
    _quickActionsChangeNotifier.notify();
    Future.delayed(Durations.quickActionListAnimation).then((value) => _reordering = false);
    return true;
  }

  bool _removeQuickAction(T? action) {
    if (action == null || !_quickActions.contains(action)) return false;

    final index = _quickActions.indexOf(action);
    _quickActions.removeAt(index);
    _animatedListKey.currentState!.removeItem(
      index,
      (context, animation) => DraggedPlaceholder(child: _buildQuickActionButton(action, animation)),
      duration: Durations.quickActionListAnimation,
    );
    _quickActionsChangeNotifier.notify();
    return true;
  }

  Widget _buildQuickActionButton(T action, Animation<double> animation) {
    animation = animation.drive(CurveTween(curve: Curves.easeInOut));
    Widget child = FadeTransition(
      opacity: animation,
      child: SizeTransition(
        axis: Axis.horizontal,
        sizeFactor: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _QuickActionEditorBodyState.quickActionVerticalPadding, horizontal: 4),
          child: OverlayButton(
            child: IconButton(
              icon: widget.actionIcon(action) ?? const SizedBox(),
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
          child = DraggedPlaceholder(child: child!);
        }
        return child!;
      },
      child: child,
    );

    return child;
  }

  @override
  bool get wantKeepAlive => true;
}
