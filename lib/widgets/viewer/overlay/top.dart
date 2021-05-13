import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/minimap.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ViewerTopOverlay extends StatelessWidget {
  final AvesEntry mainEntry;
  final Animation<double> scale;
  final EdgeInsets? viewInsets, viewPadding;
  final Function(EntryAction value) onActionSelected;
  final bool canToggleFavourite;
  final ValueNotifier<ViewState>? viewStateNotifier;

  static const double padding = 8;

  const ViewerTopOverlay({
    Key? key,
    required this.mainEntry,
    required this.scale,
    required this.canToggleFavourite,
    required this.viewInsets,
    required this.viewPadding,
    required this.onActionSelected,
    required this.viewStateNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: (viewInsets ?? EdgeInsets.zero) + (viewPadding ?? EdgeInsets.zero),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Selector<MediaQueryData, double>(
          selector: (c, mq) => mq.size.width - mq.padding.horizontal,
          builder: (c, mqWidth, child) {
            final availableCount = (mqWidth / (OverlayButton.getSize(context) + padding)).floor() - 2;

            Widget? child;
            if (mainEntry.isMultiPage) {
              final multiPageController = context.read<MultiPageConductor>().getController(mainEntry);
              if (multiPageController != null) {
                child = StreamBuilder<MultiPageInfo?>(
                  stream: multiPageController.infoStream,
                  builder: (context, snapshot) {
                    final multiPageInfo = multiPageController.info;
                    return ValueListenableBuilder<int?>(
                      valueListenable: multiPageController.pageNotifier,
                      builder: (context, page, child) {
                        return _buildOverlay(availableCount, mainEntry, pageEntry: multiPageInfo?.getPageEntryByIndex(page));
                      },
                    );
                  },
                );
              }
            }

            return child ??= _buildOverlay(availableCount, mainEntry);
          },
        ),
      ),
    );
  }

  Widget _buildOverlay(int availableCount, AvesEntry mainEntry, {AvesEntry? pageEntry}) {
    pageEntry ??= mainEntry;

    bool _canDo(EntryAction action) {
      final targetEntry = EntryActions.pageActions.contains(action) ? pageEntry! : mainEntry;
      switch (action) {
        case EntryAction.toggleFavourite:
          return canToggleFavourite;
        case EntryAction.delete:
        case EntryAction.rename:
          return targetEntry.canEdit;
        case EntryAction.rotateCCW:
        case EntryAction.rotateCW:
        case EntryAction.flip:
          return targetEntry.canRotateAndFlip;
        case EntryAction.export:
        case EntryAction.print:
          return !targetEntry.isVideo;
        case EntryAction.openMap:
          return targetEntry.hasGps;
        case EntryAction.viewSource:
          return targetEntry.isSvg;
        case EntryAction.share:
        case EntryAction.info:
        case EntryAction.open:
        case EntryAction.edit:
        case EntryAction.setAs:
          return true;
        case EntryAction.debug:
          return kDebugMode;
      }
    }

    final quickActions = settings.viewerQuickActions.where(_canDo).take(availableCount).toList();
    final inAppActions = EntryActions.inApp.where((action) => !quickActions.contains(action)).where(_canDo).toList();
    final externalAppActions = EntryActions.externalApp.where(_canDo).toList();
    final buttonRow = _TopOverlayRow(
      quickActions: quickActions,
      inAppActions: inAppActions,
      externalAppActions: externalAppActions,
      scale: scale,
      mainEntry: mainEntry,
      pageEntry: pageEntry,
      onActionSelected: onActionSelected,
    );

    return settings.showOverlayMinimap && viewStateNotifier != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buttonRow,
              SizedBox(height: 8),
              FadeTransition(
                opacity: scale,
                child: Minimap(
                  entry: pageEntry,
                  viewStateNotifier: viewStateNotifier!,
                ),
              )
            ],
          )
        : buttonRow;
  }
}

class _TopOverlayRow extends StatelessWidget {
  final List<EntryAction> quickActions, inAppActions, externalAppActions;
  final Animation<double> scale;
  final AvesEntry mainEntry, pageEntry;
  final Function(EntryAction value) onActionSelected;

  const _TopOverlayRow({
    Key? key,
    required this.quickActions,
    required this.inAppActions,
    required this.externalAppActions,
    required this.scale,
    required this.mainEntry,
    required this.pageEntry,
    required this.onActionSelected,
  }) : super(key: key);

  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OverlayButton(
          scale: scale,
          child: Navigator.canPop(context) ? BackButton() : CloseButton(),
        ),
        Spacer(),
        ...quickActions.map((action) => _buildOverlayButton(context, action)),
        OverlayButton(
          scale: scale,
          child: PopupMenuButton<EntryAction>(
            key: Key('entry-menu-button'),
            itemBuilder: (context) => [
              ...inAppActions.map((action) => _buildPopupMenuItem(context, action)),
              if (pageEntry.canRotateAndFlip) _buildRotateAndFlipMenuItems(context),
              PopupMenuDivider(),
              ...externalAppActions.map((action) => _buildPopupMenuItem(context, action)),
              if (kDebugMode) ...[
                PopupMenuDivider(),
                _buildPopupMenuItem(context, EntryAction.debug),
              ]
            ],
            onSelected: (action) {
              // wait for the popup menu to hide before proceeding with the action
              Future.delayed(Durations.popupMenuAnimation * timeDilation, () => onActionSelected(action));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayButton(BuildContext context, EntryAction action) {
    Widget? child;
    void onPressed() => onActionSelected(action);
    switch (action) {
      case EntryAction.toggleFavourite:
        child = _FavouriteToggler(
          entry: mainEntry,
          onPressed: onPressed,
        );
        break;
      case EntryAction.delete:
      case EntryAction.export:
      case EntryAction.flip:
      case EntryAction.info:
      case EntryAction.print:
      case EntryAction.rename:
      case EntryAction.rotateCCW:
      case EntryAction.rotateCW:
      case EntryAction.share:
      case EntryAction.viewSource:
        child = IconButton(
          icon: Icon(action.getIcon()),
          onPressed: onPressed,
          tooltip: action.getText(context),
        );
        break;
      case EntryAction.openMap:
      case EntryAction.open:
      case EntryAction.edit:
      case EntryAction.setAs:
      case EntryAction.debug:
        break;
    }
    return child != null
        ? Padding(
            padding: EdgeInsetsDirectional.only(end: padding),
            child: OverlayButton(
              scale: scale,
              child: child,
            ),
          )
        : SizedBox.shrink();
  }

  PopupMenuEntry<EntryAction> _buildPopupMenuItem(BuildContext context, EntryAction action) {
    Widget? child;
    switch (action) {
      // in app actions
      case EntryAction.toggleFavourite:
        child = _FavouriteToggler(
          entry: mainEntry,
          isMenuItem: true,
        );
        break;
      case EntryAction.delete:
      case EntryAction.export:
      case EntryAction.flip:
      case EntryAction.info:
      case EntryAction.print:
      case EntryAction.rename:
      case EntryAction.rotateCCW:
      case EntryAction.rotateCW:
      case EntryAction.share:
      case EntryAction.viewSource:
      case EntryAction.debug:
        child = MenuRow(text: action.getText(context), icon: action.getIcon());
        break;
      // external app actions
      case EntryAction.edit:
      case EntryAction.open:
      case EntryAction.setAs:
      case EntryAction.openMap:
        child = Text(action.getText(context));
        break;
    }
    return PopupMenuItem(
      value: action,
      child: child,
    );
  }

  PopupMenuItem<EntryAction> _buildRotateAndFlipMenuItems(BuildContext context) {
    Widget buildDivider() => SizedBox(
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
              child: Center(child: Icon(action.getIcon())),
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
}

class _FavouriteToggler extends StatefulWidget {
  final AvesEntry entry;
  final bool isMenuItem;
  final VoidCallback? onPressed;

  const _FavouriteToggler({
    required this.entry,
    this.isMenuItem = false,
    this.onPressed,
  });

  @override
  _FavouriteTogglerState createState() => _FavouriteTogglerState();
}

class _FavouriteTogglerState extends State<_FavouriteToggler> {
  final ValueNotifier<bool> isFavouriteNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    favourites.addListener(_onChanged);
    _onChanged();
  }

  @override
  void didUpdateWidget(covariant _FavouriteToggler oldWidget) {
    super.didUpdateWidget(oldWidget);
    _onChanged();
  }

  @override
  void dispose() {
    favourites.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isFavouriteNotifier,
      builder: (context, isFavourite, child) {
        if (widget.isMenuItem) {
          return isFavourite
              ? MenuRow(
                  text: context.l10n.entryActionRemoveFavourite,
                  icon: AIcons.favouriteActive,
                )
              : MenuRow(
                  text: context.l10n.entryActionAddFavourite,
                  icon: AIcons.favourite,
                );
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(isFavourite ? AIcons.favouriteActive : AIcons.favourite),
              onPressed: widget.onPressed,
              tooltip: isFavourite ? context.l10n.entryActionRemoveFavourite : context.l10n.entryActionAddFavourite,
            ),
            Sweeper(
              key: ValueKey(widget.entry),
              builder: (context) => Icon(AIcons.favourite, color: Colors.redAccent),
              toggledNotifier: isFavouriteNotifier,
            ),
          ],
        );
      },
    );
  }

  void _onChanged() {
    isFavouriteNotifier.value = widget.entry.isFavourite;
  }
}
