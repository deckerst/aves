import 'dart:math';

import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/viewer/multipage.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/minimap.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerTopOverlay extends StatelessWidget {
  final ImageEntry entry;
  final Animation<double> scale;
  final EdgeInsets viewInsets, viewPadding;
  final Function(EntryAction value) onActionSelected;
  final bool canToggleFavourite;
  final ValueNotifier<ViewState> viewStateNotifier;
  final MultiPageController multiPageController;

  static const double padding = 8;

  static const int landscapeActionCount = 3;

  static const int portraitActionCount = 2;

  const ViewerTopOverlay({
    Key key,
    @required this.entry,
    @required this.scale,
    @required this.canToggleFavourite,
    @required this.viewInsets,
    @required this.viewPadding,
    @required this.onActionSelected,
    @required this.viewStateNotifier,
    @required this.multiPageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: (viewInsets ?? EdgeInsets.zero) + (viewPadding ?? EdgeInsets.zero),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Selector<MediaQueryData, Tuple2<double, Orientation>>(
          selector: (c, mq) => Tuple2(mq.size.width, mq.orientation),
          builder: (c, mq, child) {
            final mqWidth = mq.item1;
            final mqOrientation = mq.item2;

            final targetCount = mqOrientation == Orientation.landscape ? landscapeActionCount : portraitActionCount;
            final availableCount = (mqWidth / (kMinInteractiveDimension + padding)).floor() - 2;
            final quickActionCount = min(targetCount, availableCount);

            final quickActions = [
              EntryAction.toggleFavourite,
              EntryAction.share,
              EntryAction.delete,
            ].where(_canDo).take(quickActionCount).toList();
            final inAppActions = EntryActions.inApp.where((action) => !quickActions.contains(action)).where(_canDo).toList();
            final externalAppActions = EntryActions.externalApp.where(_canDo).toList();
            final buttonRow = _TopOverlayRow(
              quickActions: quickActions,
              inAppActions: inAppActions,
              externalAppActions: externalAppActions,
              scale: scale,
              entry: entry,
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
                          mainEntry: entry,
                          viewStateNotifier: viewStateNotifier,
                          multiPageController: multiPageController,
                        ),
                      )
                    ],
                  )
                : buttonRow;
          },
        ),
      ),
    );
  }

  bool _canDo(EntryAction action) {
    switch (action) {
      case EntryAction.toggleFavourite:
        return canToggleFavourite;
      case EntryAction.delete:
      case EntryAction.rename:
        return entry.canEdit;
      case EntryAction.rotateCCW:
      case EntryAction.rotateCW:
      case EntryAction.flip:
        return entry.canRotateAndFlip;
      case EntryAction.print:
        return entry.canPrint;
      case EntryAction.openMap:
        return entry.hasGps;
      case EntryAction.viewSource:
        return entry.isSvg;
      case EntryAction.share:
      case EntryAction.info:
      case EntryAction.open:
      case EntryAction.edit:
      case EntryAction.setAs:
        return true;
      case EntryAction.debug:
        return kDebugMode;
    }
    return false;
  }
}

class _TopOverlayRow extends StatelessWidget {
  final List<EntryAction> quickActions;
  final List<EntryAction> inAppActions;
  final List<EntryAction> externalAppActions;
  final Animation<double> scale;
  final ImageEntry entry;
  final Function(EntryAction value) onActionSelected;

  const _TopOverlayRow({
    Key key,
    @required this.quickActions,
    @required this.inAppActions,
    @required this.externalAppActions,
    @required this.scale,
    @required this.entry,
    @required this.onActionSelected,
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
        ...quickActions.map(_buildOverlayButton),
        OverlayButton(
          scale: scale,
          child: PopupMenuButton<EntryAction>(
            key: Key('entry-menu-button'),
            itemBuilder: (context) => [
              ...inAppActions.map(_buildPopupMenuItem),
              if (entry.canRotateAndFlip) _buildRotateAndFlipMenuItems(),
              PopupMenuDivider(),
              ...externalAppActions.map(_buildPopupMenuItem),
              if (kDebugMode) ...[
                PopupMenuDivider(),
                _buildPopupMenuItem(EntryAction.debug),
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

  Widget _buildOverlayButton(EntryAction action) {
    Widget child;
    void onPressed() => onActionSelected(action);
    switch (action) {
      case EntryAction.toggleFavourite:
        child = _FavouriteToggler(
          entry: entry,
          onPressed: onPressed,
        );
        break;
      case EntryAction.info:
      case EntryAction.share:
      case EntryAction.delete:
      case EntryAction.rename:
      case EntryAction.rotateCCW:
      case EntryAction.rotateCW:
      case EntryAction.flip:
      case EntryAction.print:
      case EntryAction.viewSource:
        child = IconButton(
          icon: Icon(action.getIcon()),
          onPressed: onPressed,
          tooltip: action.getText(),
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

  PopupMenuEntry<EntryAction> _buildPopupMenuItem(EntryAction action) {
    Widget child;
    switch (action) {
      // in app actions
      case EntryAction.toggleFavourite:
        child = _FavouriteToggler(
          entry: entry,
          isMenuItem: true,
        );
        break;
      case EntryAction.info:
      case EntryAction.share:
      case EntryAction.delete:
      case EntryAction.rename:
      case EntryAction.rotateCCW:
      case EntryAction.rotateCW:
      case EntryAction.flip:
      case EntryAction.print:
      case EntryAction.viewSource:
      case EntryAction.debug:
        child = MenuRow(text: action.getText(), icon: action.getIcon());
        break;
      // external app actions
      case EntryAction.edit:
      case EntryAction.open:
      case EntryAction.setAs:
      case EntryAction.openMap:
        child = Text(action.getText());
        break;
    }
    return PopupMenuItem(
      value: action,
      child: child,
    );
  }

  PopupMenuItem<EntryAction> _buildRotateAndFlipMenuItems() {
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
              message: action.getText(),
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
  final ImageEntry entry;
  final bool isMenuItem;
  final VoidCallback onPressed;

  const _FavouriteToggler({
    @required this.entry,
    this.isMenuItem = false,
    this.onPressed,
  });

  @override
  _FavouriteTogglerState createState() => _FavouriteTogglerState();
}

class _FavouriteTogglerState extends State<_FavouriteToggler> {
  final ValueNotifier<bool> isFavouriteNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    favourites.changeNotifier.addListener(_onChanged);
    _onChanged();
  }

  @override
  void didUpdateWidget(covariant _FavouriteToggler oldWidget) {
    super.didUpdateWidget(oldWidget);
    _onChanged();
  }

  @override
  void dispose() {
    favourites.changeNotifier.removeListener(_onChanged);
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
                  text: 'Remove from favourites',
                  icon: AIcons.favouriteActive,
                )
              : MenuRow(
                  text: 'Add to favourites',
                  icon: AIcons.favourite,
                );
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(isFavourite ? AIcons.favouriteActive : AIcons.favourite),
              onPressed: widget.onPressed,
              tooltip: isFavourite ? 'Remove from favourites' : 'Add to favourites',
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
