import 'dart:math';

import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/entry_actions.dart';
import 'package:aves/widgets/common/fx/sweeper.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class FullscreenTopOverlay extends StatelessWidget {
  final ImageEntry entry;
  final Animation<double> scale;
  final EdgeInsets viewInsets, viewPadding;
  final Function(EntryAction value) onActionSelected;
  final bool canToggleFavourite;

  static const double padding = 8;

  static const int landscapeActionCount = 3;

  static const int portraitActionCount = 2;

  const FullscreenTopOverlay({
    Key key,
    @required this.entry,
    @required this.scale,
    @required this.canToggleFavourite,
    @required this.viewInsets,
    @required this.viewPadding,
    @required this.onActionSelected,
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

            return _TopOverlayRow(
              quickActions: quickActions,
              inAppActions: inAppActions,
              externalAppActions: externalAppActions,
              scale: scale,
              entry: entry,
              onActionSelected: onActionSelected,
            );
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
        return entry.canRotate;
      case EntryAction.print:
        return entry.canPrint;
      case EntryAction.openMap:
        return entry.hasGps;
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
              PopupMenuDivider(),
              ...externalAppActions.map(_buildPopupMenuItem),
              if (kDebugMode) ...[
                PopupMenuDivider(),
                _buildPopupMenuItem(EntryAction.debug),
              ]
            ],
            onSelected: onActionSelected,
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayButton(EntryAction action) {
    Widget child;
    void onPressed() => onActionSelected?.call(action);
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
      case EntryAction.print:
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
      case EntryAction.print:
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
  void didUpdateWidget(_FavouriteToggler oldWidget) {
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
