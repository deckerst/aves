import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/chip_set_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/common/sliver_app_bar_title.dart';
import 'package:aves/widgets/dialogs/filter_editors/create_album_dialog.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/album_set.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

Future<String?> pickAlbum({
  required BuildContext context,
  required MoveType? moveType,
}) async {
  final source = context.read<CollectionSource>();
  if (source.initState != SourceInitializationState.full) {
    // source may not be fully initialized in view mode
    await source.init();
  }
  final filter = await Navigator.push(
    context,
    MaterialPageRoute<AlbumFilter>(
      settings: const RouteSettings(name: _AlbumPickPage.routeName),
      builder: (context) => _AlbumPickPage(source: source, moveType: moveType),
    ),
  );
  return filter?.album;
}

class _AlbumPickPage extends StatefulWidget {
  static const routeName = '/album_pick';

  final CollectionSource source;
  final MoveType? moveType;

  const _AlbumPickPage({
    super.key,
    required this.source,
    required this.moveType,
  });

  @override
  State<_AlbumPickPage> createState() => _AlbumPickPageState();
}

class _AlbumPickPageState extends State<_AlbumPickPage> {
  final _queryNotifier = ValueNotifier('');

  CollectionSource get source => widget.source;

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ValueNotifier<AppMode>>.value(
      value: ValueNotifier(AppMode.pickFilterInternal),
      child: Selector<Settings, Tuple2<AlbumChipGroupFactor, ChipSortFactor>>(
        selector: (context, s) => Tuple2(s.albumGroupFactor, s.albumSortFactor),
        builder: (context, s, child) {
          return StreamBuilder(
            stream: source.eventBus.on<AlbumsChangedEvent>(),
            builder: (context, snapshot) {
              final gridItems = AlbumListPage.getAlbumGridItems(context, source);
              return SelectionProvider<FilterGridItem<AlbumFilter>>(
                child: FilterGridPage<AlbumFilter>(
                  settingsRouteKey: AlbumListPage.routeName,
                  appBar: _AlbumPickAppBar(
                    source: source,
                    moveType: widget.moveType,
                    actionDelegate: AlbumChipSetActionDelegate(gridItems),
                    queryNotifier: _queryNotifier,
                  ),
                  appBarHeight: _AlbumPickAppBar.preferredHeight,
                  sections: AlbumListPage.groupToSections(context, source, gridItems),
                  newFilters: source.getNewAlbumFilters(context),
                  sortFactor: settings.albumSortFactor,
                  showHeaders: settings.albumGroupFactor != AlbumChipGroupFactor.none,
                  selectable: false,
                  queryNotifier: _queryNotifier,
                  applyQuery: (filters, query) {
                    if (query.isEmpty) return filters;
                    query = query.toUpperCase();
                    return filters.where((item) => (item.filter.displayName ?? item.filter.album).toUpperCase().contains(query)).toList();
                  },
                  emptyBuilder: () => EmptyContent(
                    icon: AIcons.album,
                    text: context.l10n.albumEmpty,
                  ),
                  heroType: HeroType.never,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AlbumPickAppBar extends StatelessWidget {
  final CollectionSource source;
  final MoveType? moveType;
  final AlbumChipSetActionDelegate actionDelegate;
  final ValueNotifier<String> queryNotifier;

  static const preferredHeight = kToolbarHeight + _AlbumQueryBar.preferredHeight;

  const _AlbumPickAppBar({
    super.key,
    required this.source,
    required this.moveType,
    required this.actionDelegate,
    required this.queryNotifier,
  });

  @override
  Widget build(BuildContext context) {
    String title() {
      switch (moveType) {
        case MoveType.copy:
          return context.l10n.albumPickPageTitleCopy;
        case MoveType.move:
          return context.l10n.albumPickPageTitleMove;
        case MoveType.export:
          return context.l10n.albumPickPageTitleExport;
        case MoveType.toBin:
        case MoveType.fromBin:
        case null:
          return context.l10n.albumPickPageTitlePick;
      }
    }

    return SliverAppBar(
      leading: const BackButton(),
      title: SliverAppBarTitleWrapper(
        child: SourceStateAwareAppBarTitle(
          title: Text(title()),
          source: source,
        ),
      ),
      bottom: _AlbumQueryBar(
        queryNotifier: queryNotifier,
      ),
      actions: [
        if (moveType != null)
          IconButton(
            icon: const Icon(AIcons.add),
            onPressed: () async {
              final newAlbum = await showDialog<String>(
                context: context,
                builder: (context) => const CreateAlbumDialog(),
              );
              // wait for the dialog to hide as applying the change may block the UI
              await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
              if (newAlbum != null && newAlbum.isNotEmpty) {
                Navigator.pop<AlbumFilter>(context, AlbumFilter(newAlbum, source.getAlbumDisplayName(context, newAlbum)));
              }
            },
            tooltip: context.l10n.createAlbumTooltip,
          ),
        MenuIconTheme(
          child: PopupMenuButton<ChipSetAction>(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: ChipSetAction.configureView,
                  child: MenuRow(text: context.l10n.menuActionConfigureView, icon: const Icon(AIcons.view)),
                ),
              ];
            },
            onSelected: (action) async {
              // remove focus, if any, to prevent the keyboard from showing up
              // after the user is done with the popup menu
              FocusManager.instance.primaryFocus?.unfocus();

              // wait for the popup menu to hide before proceeding with the action
              await Future.delayed(Durations.popupMenuAnimation * timeDilation);
              actionDelegate.onActionSelected(context, {}, action);
            },
          ),
        ),
      ],
      floating: true,
    );
  }
}

class _AlbumQueryBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<String> queryNotifier;

  static const preferredHeight = kToolbarHeight;

  const _AlbumQueryBar({
    super.key,
    required this.queryNotifier,
  });

  @override
  Size get preferredSize => const Size.fromHeight(preferredHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _AlbumQueryBar.preferredHeight,
      alignment: Alignment.topCenter,
      child: QueryBar(
        queryNotifier: queryNotifier,
      ),
    );
  }
}
