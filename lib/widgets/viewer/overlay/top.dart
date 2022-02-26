import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/basic/popup_menu_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/favourite_toggler.dart';
import 'package:aves/widgets/viewer/action/entry_action_delegate.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/minimap.dart';
import 'package:aves/widgets/viewer/overlay/notifications.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ViewerTopOverlay extends StatelessWidget {
  final AvesEntry mainEntry;
  final Animation<double> scale;
  final EdgeInsets? viewInsets, viewPadding;
  final bool canToggleFavourite;

  static const double outerPadding = 8;
  static const double innerPadding = 8;

  const ViewerTopOverlay({
    Key? key,
    required this.mainEntry,
    required this.scale,
    required this.canToggleFavourite,
    required this.viewInsets,
    required this.viewPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: (viewInsets ?? EdgeInsets.zero) + (viewPadding ?? EdgeInsets.zero),
      child: Padding(
        padding: const EdgeInsets.all(outerPadding),
        child: Selector<MediaQueryData, double>(
          selector: (context, mq) => mq.size.width - mq.padding.horizontal,
          builder: (context, mqWidth, child) {
            final buttonWidth = OverlayButton.getSize(context);
            final availableCount = ((mqWidth - outerPadding * 2 - buttonWidth) / (buttonWidth + innerPadding)).floor();

            return mainEntry.isMultiPage
                ? PageEntryBuilder(
                    multiPageController: context.read<MultiPageConductor>().getController(mainEntry),
                    builder: (pageEntry) => _buildOverlay(context, availableCount, mainEntry, pageEntry: pageEntry),
                  )
                : _buildOverlay(context, availableCount, mainEntry);
          },
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, int availableCount, AvesEntry mainEntry, {AvesEntry? pageEntry}) {
    pageEntry ??= mainEntry;
    final trashed = mainEntry.trashed;

    bool _isVisible(EntryAction action) {
      if (trashed) {
        switch (action) {
          case EntryAction.delete:
          case EntryAction.restore:
            return true;
          case EntryAction.debug:
            return kDebugMode;
          default:
            return false;
        }
      } else {
        final targetEntry = EntryActions.pageActions.contains(action) ? pageEntry! : mainEntry;
        switch (action) {
          case EntryAction.toggleFavourite:
            return canToggleFavourite;
          case EntryAction.delete:
          case EntryAction.rename:
          case EntryAction.copy:
          case EntryAction.move:
            return targetEntry.canEdit;
          case EntryAction.rotateCCW:
          case EntryAction.rotateCW:
          case EntryAction.flip:
            return targetEntry.canRotateAndFlip;
          case EntryAction.convert:
          case EntryAction.print:
            return !targetEntry.isVideo && device.canPrint;
          case EntryAction.openMap:
            return targetEntry.hasGps;
          case EntryAction.viewSource:
            return targetEntry.isSvg;
          case EntryAction.rotateScreen:
            return settings.isRotationLocked;
          case EntryAction.addShortcut:
            return device.canPinShortcut;
          case EntryAction.copyToClipboard:
          case EntryAction.edit:
          case EntryAction.open:
          case EntryAction.setAs:
          case EntryAction.share:
            return true;
          case EntryAction.restore:
            return false;
          case EntryAction.debug:
            return kDebugMode;
        }
      }
    }

    final buttonRow = Selector<Settings, bool>(
      selector: (context, s) => s.isRotationLocked,
      builder: (context, s, child) {
        final quickActions = (trashed ? EntryActions.trashed : settings.viewerQuickActions).where(_isVisible).take(availableCount - 1).toList();
        final topLevelActions = EntryActions.topLevel.where((action) => !quickActions.contains(action)).where(_isVisible).toList();
        final exportActions = EntryActions.export.where((action) => !quickActions.contains(action)).where(_isVisible).toList();
        return _TopOverlayRow(
          quickActions: quickActions,
          topLevelActions: topLevelActions,
          exportActions: exportActions,
          scale: scale,
          mainEntry: mainEntry,
          pageEntry: pageEntry!,
        );
      },
    );

    if (settings.showOverlayMinimap) {
      final viewStateConductor = context.read<ViewStateConductor>();
      final viewStateNotifier = viewStateConductor.getOrCreateController(pageEntry);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buttonRow,
          const SizedBox(height: 8),
          FadeTransition(
            opacity: scale,
            child: Minimap(
              viewStateNotifier: viewStateNotifier,
            ),
          )
        ],
      );
    }
    return buttonRow;
  }
}

class _TopOverlayRow extends StatelessWidget {
  final List<EntryAction> quickActions, topLevelActions, exportActions;
  final Animation<double> scale;
  final AvesEntry mainEntry, pageEntry;

  AvesEntry get favouriteTargetEntry => mainEntry.isBurst ? pageEntry : mainEntry;

  const _TopOverlayRow({
    Key? key,
    required this.quickActions,
    required this.topLevelActions,
    required this.exportActions,
    required this.scale,
    required this.mainEntry,
    required this.pageEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasOverflowMenu = pageEntry.canRotateAndFlip || topLevelActions.isNotEmpty || exportActions.isNotEmpty;
    return Row(
      children: [
        OverlayButton(
          scale: scale,
          child: Navigator.canPop(context) ? const BackButton() : const CloseButton(),
        ),
        const Spacer(),
        ...quickActions.map((action) => _buildOverlayButton(context, action)),
        if (hasOverflowMenu)
          OverlayButton(
            scale: scale,
            child: MenuIconTheme(
              child: AvesPopupMenuButton<EntryAction>(
                key: const Key('entry-menu-button'),
                itemBuilder: (context) {
                  final exportInternalActions = exportActions.whereNot(EntryActions.exportExternal.contains).toList();
                  final exportExternalActions = exportActions.where(EntryActions.exportExternal.contains).toList();
                  return [
                    if (pageEntry.canRotateAndFlip) _buildRotateAndFlipMenuItems(context),
                    ...topLevelActions.map((action) => _buildPopupMenuItem(context, action)),
                    if (exportActions.isNotEmpty)
                      PopupMenuItem<EntryAction>(
                        padding: EdgeInsets.zero,
                        child: PopupMenuItemExpansionPanel<EntryAction>(
                          icon: AIcons.export,
                          title: context.l10n.entryActionExport,
                          items: [
                            ...exportInternalActions.map((action) => _buildPopupMenuItem(context, action)).toList(),
                            if (exportInternalActions.isNotEmpty && exportExternalActions.isNotEmpty) const PopupMenuDivider(height: 0),
                            ...exportExternalActions.map((action) => _buildPopupMenuItem(context, action)).toList(),
                          ],
                        ),
                      ),
                    if (!kReleaseMode) ...[
                      const PopupMenuDivider(),
                      _buildPopupMenuItem(context, EntryAction.debug),
                    ]
                  ];
                },
                onSelected: (action) {
                  // wait for the popup menu to hide before proceeding with the action
                  Future.delayed(Durations.popupMenuAnimation * timeDilation, () => _onActionSelected(context, action));
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
      ],
    );
  }

  Widget _buildOverlayButton(BuildContext context, EntryAction action) {
    Widget? child;
    void onPressed() => _onActionSelected(context, action);
    switch (action) {
      case EntryAction.toggleFavourite:
        child = FavouriteToggler(
          entries: {favouriteTargetEntry},
          onPressed: onPressed,
        );
        break;
      default:
        child = IconButton(
          icon: action.getIcon(),
          onPressed: onPressed,
          tooltip: action.getText(context),
        );
        break;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: ViewerTopOverlay.innerPadding),
      child: OverlayButton(
        scale: scale,
        child: child,
      ),
    );
  }

  PopupMenuItem<EntryAction> _buildPopupMenuItem(BuildContext context, EntryAction action) {
    Widget? child;
    switch (action) {
      // in app actions
      case EntryAction.toggleFavourite:
        child = FavouriteToggler(
          entries: {favouriteTargetEntry},
          isMenuItem: true,
        );
        break;
      default:
        child = MenuRow(text: action.getText(context), icon: action.getIcon());
        break;
    }
    return PopupMenuItem(
      value: action,
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
          child: PopupMenuItem(
            value: action,
            child: Tooltip(
              message: action.getText(context),
              child: Center(child: action.getIcon()),
            ),
          ),
        );

    return PopupMenuItem(
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
    );
  }

  void _onActionSelected(BuildContext context, EntryAction action) {
    var targetEntry = mainEntry;
    if (mainEntry.isMultiPage && (mainEntry.isBurst || EntryActions.pageActions.contains(action))) {
      final multiPageController = context.read<MultiPageConductor>().getController(mainEntry);
      if (multiPageController != null) {
        final multiPageInfo = multiPageController.info;
        final pageEntry = multiPageInfo?.getPageEntryByIndex(multiPageController.page);
        if (pageEntry != null) {
          targetEntry = pageEntry;
        }
      }
    }
    EntryActionDelegate(targetEntry).onActionSelected(context, action);
  }
}
