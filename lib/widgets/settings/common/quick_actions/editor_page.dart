import 'dart:async';

import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/settings/common/quick_actions/action_panel.dart';
import 'package:aves/widgets/settings/common/quick_actions/available_actions.dart';
import 'package:aves/widgets/settings/common/quick_actions/placeholder.dart';
import 'package:aves/widgets/settings/common/quick_actions/quick_actions.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class QuickActionEditorPage<T extends Object> extends StatelessWidget {
  final String title, bannerText;
  final TextDirection? displayedButtonsDirection;
  final List<List<T>> allAvailableActions;
  final Widget Function(BuildContext context, T action) actionIcon;
  final String Function(BuildContext context, T action) actionText;
  final List<T> Function() load;
  final void Function(List<T> actions) save;

  const QuickActionEditorPage({
    super.key,
    required this.title,
    required this.bannerText,
    this.displayedButtonsDirection,
    required this.allAvailableActions,
    required this.actionIcon,
    required this.actionText,
    required this.load,
    required this.save,
  });

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: QuickActionEditorBody(
          bannerText: bannerText,
          displayedButtonsDirection: displayedButtonsDirection,
          allAvailableActions: allAvailableActions,
          actionIcon: actionIcon,
          actionText: actionText,
          load: load,
          save: save,
        ),
      ),
    );
  }
}

class QuickActionEditorBody<T extends Object> extends StatefulWidget {
  final String bannerText;
  final TextDirection? displayedButtonsDirection;
  final List<List<T>> allAvailableActions;
  final Widget Function(BuildContext context, T action) actionIcon;
  final String Function(BuildContext context, T action) actionText;
  final List<T> Function() load;
  final void Function(List<T> actions) save;

  const QuickActionEditorBody({
    super.key,
    required this.bannerText,
    this.displayedButtonsDirection,
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
  final PageController _availableActionPageController = PageController();

  // use a flag to prevent quick action target accept/leave when already animating reorder
  // as dragging a button against axis direction messes index resolution while items pop in and out
  bool _reordering = false;

  static const double quickActionVerticalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _quickActions = widget.load().toList();
  }

  @override
  void dispose() {
    _draggedQuickAction.dispose();
    _draggedAvailableAction.dispose();
    _quickActionHighlight.dispose();
    _availableActionHighlight.dispose();
    _quickActionsChangeNotifier.dispose();
    _availableActionPageController.dispose();

    _stopLeavingTimer();
    super.dispose();
  }

  void _onQuickActionTargetLeave() {
    _stopLeavingTimer();
    final action = _draggedAvailableAction.value;
    _targetLeavingTimer = Timer(ADurations.quickActionListAnimation + const Duration(milliseconds: 50), () {
      _removeQuickAction(action);
      _quickActionHighlight.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
    final originalDirection = Directionality.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => widget.save(_quickActions),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const FontSizeIconTheme(child: Icon(AIcons.info)),
                const SizedBox(width: 16),
                Expanded(child: Text(widget.bannerText)),
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              context.l10n.settingsViewerQuickActionEditorDisplayedButtonsSectionTitle,
              style: AStyles.knownTitleText,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _quickActionHighlight,
            builder: (context, highlight, child) => ActionPanel(
              highlight: highlight,
              child: child!,
            ),
            child: Directionality(
              textDirection: widget.displayedButtonsDirection ?? originalDirection,
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
                          return Directionality(
                            textDirection: originalDirection,
                            child: QuickActionButton<T>(
                              placement: QuickActionPlacement.action,
                              action: action,
                              panelHighlight: _quickActionHighlight,
                              draggedQuickAction: _draggedQuickAction,
                              draggedAvailableAction: _draggedAvailableAction,
                              insertAction: _insertQuickAction,
                              removeAction: _removeQuickAction,
                              onTargetLeave: _onQuickActionTargetLeave,
                              draggableFeedbackBuilder: (action) => CaptionedButton(
                                icon: widget.actionIcon(context, action),
                                caption: widget.actionText(context, action),
                                showCaption: false,
                                onPressed: () {},
                              ),
                              child: _buildQuickActionButton(action, animation),
                            ),
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
                                style: theme.textTheme.bodySmall,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.l10n.settingsViewerQuickActionEditorAvailableButtonsSectionTitle,
              style: AStyles.knownTitleText,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _availableActionHighlight,
            builder: (context, highlight, child) => ActionPanel(
              highlight: highlight,
              child: child!,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final allAvailableActions = widget.allAvailableActions;
                final maxWidth = constraints.maxWidth;
                final maxHeight = allAvailableActions
                    .map((page) => AvailableActionPanel.heightFor(
                          context,
                          page.map((v) => widget.actionText(context, v)).toList(),
                          maxWidth,
                        ))
                    .max;
                return Column(
                  children: [
                    if (allAvailableActions.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SmoothPageIndicator(
                          controller: _availableActionPageController,
                          count: allAvailableActions.length,
                          effect: WormEffect(
                            dotWidth: 8,
                            dotHeight: 8,
                            dotColor: colorScheme.onSurface.withValues(alpha: .2),
                            activeDotColor: colorScheme.primary,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: maxHeight,
                      child: PageView(
                        controller: _availableActionPageController,
                        children: allAvailableActions
                            .map((allActions) => AvailableActionPanel<T>(
                                  allActions: allActions,
                                  quickActions: _quickActions,
                                  quickActionsChangeNotifier: _quickActionsChangeNotifier,
                                  panelHighlight: _availableActionHighlight,
                                  draggedQuickAction: _draggedQuickAction,
                                  draggedAvailableAction: _draggedAvailableAction,
                                  removeQuickAction: _removeQuickAction,
                                  actionIcon: widget.actionIcon,
                                  actionText: widget.actionText,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
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
      case QuickActionPlacement.footer:
        targetIndex = _quickActions.length - (contained ? 1 : 0);
      case QuickActionPlacement.action:
        targetIndex = _quickActions.indexOf(overAction!);
    }
    if (currentIndex == targetIndex) return false;

    _reordering = true;
    _removeQuickAction(action);
    _quickActions.insert(targetIndex, action);
    _animatedListKey.currentState!.insertItem(
      targetIndex,
      duration: ADurations.quickActionListAnimation,
    );
    _quickActionsChangeNotifier.notify();
    Future.delayed(ADurations.quickActionListAnimation).then((value) => _reordering = false);
    return true;
  }

  bool _removeQuickAction(T? action) {
    if (action == null || !_quickActions.contains(action)) return false;

    final index = _quickActions.indexOf(action);
    _quickActions.removeAt(index);
    _animatedListKey.currentState!.removeItem(
      index,
      (context, animation) => DraggedPlaceholder(child: _buildQuickActionButton(action, animation)),
      duration: ADurations.quickActionListAnimation,
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
              icon: widget.actionIcon(context, action),
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
