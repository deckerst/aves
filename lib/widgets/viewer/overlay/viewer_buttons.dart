import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/move_button.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/rate_button.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/share_button.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/tag_button.dart';
import 'package:aves/widgets/common/action_controls/togglers/favourite.dart';
import 'package:aves/widgets/common/action_controls/togglers/mute.dart';
import 'package:aves/widgets/common/action_controls/togglers/play.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/basic/popup_menu_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/action/entry_action_delegate.dart';
import 'package:aves/widgets/viewer/notifications.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ViewerButtons extends StatelessWidget {
  final AvesEntry mainEntry, pageEntry;
  final CollectionLens? collection;
  final Animation<double> scale;

  static const double outerPadding = 8;
  static const double innerPadding = 8;

  static double preferredHeight(BuildContext context) => _buttonSize(context) + ViewerButtonRowContent.padding;

  static double _buttonSize(BuildContext context) => OverlayButton.getSize(context);

  const ViewerButtons({
    super.key,
    required this.mainEntry,
    required this.pageEntry,
    required this.collection,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final actionDelegate = EntryActionDelegate(mainEntry, pageEntry, collection);

    if (settings.useTvLayout) {
      return _TvButtonRowContent(
        actionDelegate: actionDelegate,
        scale: scale,
        mainEntry: mainEntry,
        pageEntry: pageEntry,
      );
    }

    final trashed = mainEntry.trashed;
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonWidth = _buttonSize(context);
          final availableCount = ((constraints.maxWidth - outerPadding * 2) / (buttonWidth + innerPadding)).floor();
          return Selector<Settings, bool>(
            selector: (context, s) => s.isRotationLocked,
            builder: (context, s, child) {
              final quickActions = (trashed ? EntryActions.trashed : settings.viewerQuickActions).where(actionDelegate.isVisible).where(actionDelegate.canApply).take(availableCount - 1).toList();
              final topLevelActions = EntryActions.topLevel.where((action) => !quickActions.contains(action)).where(actionDelegate.isVisible).toList();
              final exportActions = EntryActions.export.where((action) => !quickActions.contains(action)).where(actionDelegate.isVisible).toList();
              final videoActions = EntryActions.video.where((action) => !quickActions.contains(action)).where(actionDelegate.isVisible).toList();
              return ViewerButtonRowContent(
                actionDelegate: EntryActionDelegate(mainEntry, pageEntry, collection),
                quickActions: quickActions,
                topLevelActions: topLevelActions,
                exportActions: exportActions,
                videoActions: videoActions,
                scale: scale,
                mainEntry: mainEntry,
                pageEntry: pageEntry,
              );
            },
          );
        },
      ),
    );
  }
}

class _TvButtonRowContent extends StatelessWidget {
  final EntryActionDelegate actionDelegate;
  final Animation<double> scale;
  final AvesEntry mainEntry, pageEntry;

  const _TvButtonRowContent({
    required this.actionDelegate,
    required this.scale,
    required this.mainEntry,
    required this.pageEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<VideoConductor, AvesVideoController?>(
      selector: (context, vc) => vc.getController(pageEntry),
      builder: (context, videoController, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...EntryActions.topLevel,
            ...EntryActions.export,
            ...EntryActions.videoPlayback,
            ...EntryActions.video,
          ].where(actionDelegate.isVisible).map((action) {
            final enabled = actionDelegate.canApply(action);
            return CaptionedButton(
              scale: scale,
              iconButtonBuilder: (context, focusNode) => ViewerButtonRowContent._buildButtonIcon(
                context: context,
                action: action,
                mainEntry: mainEntry,
                pageEntry: pageEntry,
                videoController: videoController,
                actionDelegate: actionDelegate,
                focusNode: focusNode,
              ),
              captionText: _buildButtonCaption(
                context: context,
                action: action,
                mainEntry: mainEntry,
                pageEntry: pageEntry,
                videoController: videoController,
                enabled: enabled,
              ),
              onPressed: enabled ? () => actionDelegate.onActionSelected(context, action) : null,
            );
          }).toList(),
        );
      },
    );
  }

  static Widget _buildButtonCaption({
    required BuildContext context,
    required EntryAction action,
    required AvesEntry mainEntry,
    required AvesEntry pageEntry,
    required AvesVideoController? videoController,
    required bool enabled,
  }) {
    switch (action) {
      case EntryAction.toggleFavourite:
        final favouriteTargetEntry = mainEntry.isBurst ? pageEntry : mainEntry;
        return FavouriteTogglerCaption(
          entries: {favouriteTargetEntry},
          enabled: enabled,
        );
      case EntryAction.videoToggleMute:
        return MuteTogglerCaption(
          controller: videoController,
          enabled: enabled,
        );
      case EntryAction.videoTogglePlay:
        return PlayTogglerCaption(
          controller: videoController,
          enabled: enabled,
        );
      default:
        return CaptionedButtonText(
          text: action.getText(context),
          enabled: enabled,
        );
    }
  }
}

class ViewerButtonRowContent extends StatelessWidget {
  final EntryActionDelegate actionDelegate;
  final List<EntryAction> quickActions, topLevelActions, exportActions, videoActions;
  final Animation<double> scale;
  final AvesEntry mainEntry, pageEntry;
  final ValueNotifier<String?> _popupExpandedNotifier = ValueNotifier(null);

  AvesEntry get favouriteTargetEntry => mainEntry.isBurst ? pageEntry : mainEntry;

  static const double padding = 8;

  ViewerButtonRowContent({
    super.key,
    required this.actionDelegate,
    required this.quickActions,
    required this.topLevelActions,
    required this.exportActions,
    required this.videoActions,
    required this.scale,
    required this.mainEntry,
    required this.pageEntry,
  });

  @override
  Widget build(BuildContext context) {
    final hasOverflowMenu = pageEntry.canRotate || pageEntry.canFlip || topLevelActions.isNotEmpty || exportActions.isNotEmpty || videoActions.isNotEmpty;
    return Selector<VideoConductor, AvesVideoController?>(
      selector: (context, vc) => vc.getController(pageEntry),
      builder: (context, videoController, child) {
        return Padding(
          padding: const EdgeInsets.only(left: padding / 2, right: padding / 2, bottom: padding),
          child: Row(
            children: [
              const Spacer(),
              ...quickActions.map((action) => _buildOverlayButton(context, action, videoController)),
              if (hasOverflowMenu)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: padding / 2),
                  child: OverlayButton(
                    scale: scale,
                    child: MenuIconTheme(
                      child: AvesPopupMenuButton<EntryAction>(
                        key: const Key('entry-menu-button'),
                        itemBuilder: (context) {
                          final exportInternalActions = exportActions.whereNot(EntryActions.exportExternal.contains).toList();
                          final exportExternalActions = exportActions.where(EntryActions.exportExternal.contains).toList();
                          return [
                            if (pageEntry.canRotate || pageEntry.canFlip) _buildRotateAndFlipMenuItems(context),
                            ...topLevelActions.map((action) => _buildPopupMenuItem(context, action, videoController)),
                            if (exportActions.isNotEmpty)
                              PopupMenuItem<EntryAction>(
                                padding: EdgeInsets.zero,
                                child: PopupMenuItemExpansionPanel<EntryAction>(
                                  value: 'export',
                                  expandedNotifier: _popupExpandedNotifier,
                                  icon: AIcons.export,
                                  title: context.l10n.entryActionExport,
                                  items: [
                                    ...exportInternalActions.map((action) => _buildPopupMenuItem(context, action, videoController)).toList(),
                                    if (exportInternalActions.isNotEmpty && exportExternalActions.isNotEmpty) const PopupMenuDivider(height: 0),
                                    ...exportExternalActions.map((action) => _buildPopupMenuItem(context, action, videoController)).toList(),
                                  ],
                                ),
                              ),
                            if (videoActions.isNotEmpty)
                              PopupMenuItem<EntryAction>(
                                padding: EdgeInsets.zero,
                                child: PopupMenuItemExpansionPanel<EntryAction>(
                                  value: 'video',
                                  expandedNotifier: _popupExpandedNotifier,
                                  icon: AIcons.video,
                                  title: context.l10n.settingsVideoSectionTitle,
                                  items: [
                                    ...videoActions.map((action) => _buildPopupMenuItem(context, action, videoController)).toList(),
                                  ],
                                ),
                              ),
                            if (!kReleaseMode) ...[
                              const PopupMenuDivider(),
                              _buildPopupMenuItem(context, EntryAction.debug, videoController),
                            ]
                          ];
                        },
                        onSelected: (action) {
                          _popupExpandedNotifier.value = null;
                          // wait for the popup menu to hide before proceeding with the action
                          Future.delayed(Durations.popupMenuAnimation * timeDilation, () => actionDelegate.onActionSelected(context, action));
                        },
                        onCanceled: () {
                          _popupExpandedNotifier.value = null;
                        },
                        onMenuOpened: () {
                          // if the menu is opened while overlay is hiding,
                          // the popup menu button is disposed and menu items are ineffective,
                          // so we make sure overlay stays visible
                          const ToggleOverlayNotification(visible: true).dispatch(context);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverlayButton(BuildContext context, EntryAction action, AvesVideoController? videoController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding / 2),
      child: OverlayButton(
        scale: scale,
        child: _buildButtonIcon(
          context: context,
          action: action,
          mainEntry: mainEntry,
          pageEntry: pageEntry,
          videoController: videoController,
          actionDelegate: actionDelegate,
        ),
      ),
    );
  }

  PopupMenuItem<EntryAction> _buildPopupMenuItem(BuildContext context, EntryAction action, AvesVideoController? videoController) {
    late final bool enabled;
    switch (action) {
      case EntryAction.videoCaptureFrame:
        enabled = videoController?.canCaptureFrameNotifier.value ?? false;
        break;
      case EntryAction.videoToggleMute:
        enabled = videoController?.canMuteNotifier.value ?? false;
        break;
      case EntryAction.videoSelectStreams:
        enabled = videoController?.canSelectStreamNotifier.value ?? false;
        break;
      case EntryAction.videoSetSpeed:
        enabled = videoController?.canSetSpeedNotifier.value ?? false;
        break;
      default:
        enabled = true;
        break;
    }

    Widget? child;
    switch (action) {
      case EntryAction.toggleFavourite:
        child = FavouriteToggler(
          entries: {favouriteTargetEntry},
          isMenuItem: true,
        );
        break;
      case EntryAction.videoToggleMute:
        child = MuteToggler(
          controller: videoController,
          isMenuItem: true,
        );
        break;
      case EntryAction.videoTogglePlay:
        child = PlayToggler(
          controller: videoController,
          isMenuItem: true,
        );
        break;
      default:
        child = MenuRow(text: action.getText(context), icon: action.getIcon());
        break;
    }
    return PopupMenuItem(
      value: action,
      enabled: enabled,
      child: child,
    );
  }

  PopupMenuItem<EntryAction> _buildRotateAndFlipMenuItems(BuildContext context) {
    Widget buildDivider() => const SizedBox(
          height: 16,
          child: VerticalDivider(
            width: 1,
            thickness: 1,
          ),
        );

    Widget buildItem(EntryAction action) => Expanded(
          child: Material(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            clipBehavior: Clip.antiAlias,
            child: PopupMenuItem(
              value: action,
              enabled: actionDelegate.canApply(action),
              child: Tooltip(
                message: action.getText(context),
                child: Center(child: action.getIcon()),
              ),
            ),
          ),
        );

    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: IconTheme.merge(
        data: IconThemeData(
          color: ListTileTheme.of(context).iconColor,
        ),
        child: ColoredBox(
          color: PopupMenuTheme.of(context).color!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                buildDivider(),
                buildItem(EntryAction.rotateCCW),
                buildDivider(),
                buildItem(EntryAction.rotateCW),
                buildDivider(),
                buildItem(EntryAction.flip),
                buildDivider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildButtonIcon({
    required BuildContext context,
    required EntryAction action,
    required AvesEntry mainEntry,
    required AvesEntry pageEntry,
    required AvesVideoController? videoController,
    required EntryActionDelegate actionDelegate,
    FocusNode? focusNode,
  }) {
    Widget? child;
    void onPressed() => actionDelegate.onActionSelected(context, action);

    ValueListenableBuilder<bool> _buildFromListenable(ValueListenable<bool>? enabledNotifier) {
      return ValueListenableBuilder<bool>(
        valueListenable: enabledNotifier ?? ValueNotifier(false),
        builder: (context, canDo, child) => IconButton(
          icon: child!,
          onPressed: canDo ? onPressed : null,
          focusNode: focusNode,
          tooltip: action.getText(context),
        ),
        child: action.getIcon(),
      );
    }

    final blurred = settings.enableBlurEffect;
    switch (action) {
      case EntryAction.copy:
        child = MoveButton(
          copy: true,
          blurred: blurred,
          onChooserValue: (album) => actionDelegate.quickMove(context, album, copy: true),
          onPressed: onPressed,
        );
        break;
      case EntryAction.move:
        child = MoveButton(
          copy: false,
          blurred: blurred,
          onChooserValue: (album) => actionDelegate.quickMove(context, album, copy: false),
          onPressed: onPressed,
        );
        break;
      case EntryAction.share:
        child = ShareButton(
          blurred: blurred,
          entries: {mainEntry},
          onChooserValue: (action) => actionDelegate.quickShare(context, action),
          focusNode: focusNode,
          onPressed: onPressed,
        );
        break;
      case EntryAction.toggleFavourite:
        final favouriteTargetEntry = mainEntry.isBurst ? pageEntry : mainEntry;
        child = FavouriteToggler(
          entries: {favouriteTargetEntry},
          focusNode: focusNode,
          onPressed: onPressed,
        );
        break;
      case EntryAction.videoToggleMute:
        child = MuteToggler(
          controller: videoController,
          focusNode: focusNode,
          onPressed: onPressed,
        );
        break;
      case EntryAction.videoTogglePlay:
        child = PlayToggler(
          controller: videoController,
          focusNode: focusNode,
          onPressed: onPressed,
        );
        break;
      case EntryAction.videoCaptureFrame:
        child = _buildFromListenable(videoController?.canCaptureFrameNotifier);
        break;
      case EntryAction.videoSelectStreams:
        child = _buildFromListenable(videoController?.canSelectStreamNotifier);
        break;
      case EntryAction.videoSetSpeed:
        child = _buildFromListenable(videoController?.canSetSpeedNotifier);
        break;
      case EntryAction.editRating:
        child = RateButton(
          blurred: blurred,
          onChooserValue: (rating) => actionDelegate.quickRate(context, rating),
          focusNode: focusNode,
          onPressed: onPressed,
        );
        break;
      case EntryAction.editTags:
        child = TagButton(
          blurred: blurred,
          onChooserValue: (filter) => actionDelegate.quickTag(context, filter),
          focusNode: focusNode,
          onPressed: onPressed,
        );
        break;
      default:
        child = IconButton(
          icon: action.getIcon(),
          onPressed: onPressed,
          focusNode: focusNode,
          tooltip: action.getText(context),
        );
        break;
    }
    return child;
  }
}
