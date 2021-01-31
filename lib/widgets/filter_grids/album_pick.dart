import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/app_bar_subtitle.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/common/basic/query_bar.dart';
import 'package:aves/widgets/dialogs/create_album_dialog.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AlbumPickPage extends StatefulWidget {
  static const routeName = '/album_pick';

  final CollectionSource source;
  final MoveType moveType;

  const AlbumPickPage({
    @required this.source,
    @required this.moveType,
  });

  @override
  _AlbumPickPageState createState() => _AlbumPickPageState();
}

class _AlbumPickPageState extends State<AlbumPickPage> {
  final _queryNotifier = ValueNotifier('');

  CollectionSource get source => widget.source;

  @override
  Widget build(BuildContext context) {
    Widget appBar = AlbumPickAppBar(
      source: source,
      moveType: widget.moveType,
      actionDelegate: AlbumChipSetActionDelegate(source: source),
      queryNotifier: _queryNotifier,
    );

    return Selector<Settings, Tuple2<AlbumChipGroupFactor, ChipSortFactor>>(
      selector: (context, s) => Tuple2(s.albumGroupFactor, s.albumSortFactor),
      builder: (context, s, child) {
        return StreamBuilder(
          stream: source.eventBus.on<AlbumsChangedEvent>(),
          builder: (context, snapshot) => FilterGridPage<AlbumFilter>(
            source: source,
            appBar: appBar,
            filterSections: AlbumListPage.getAlbumEntries(source),
            showHeaders: settings.albumGroupFactor != AlbumChipGroupFactor.none,
            applyQuery: (filters, query) {
              if (query == null || query.isEmpty) return filters;
              query = query.toUpperCase();
              return filters.where((item) => item.filter.uniqueName.toUpperCase().contains(query)).toList();
            },
            queryNotifier: _queryNotifier,
            emptyBuilder: () => EmptyContent(
              icon: AIcons.album,
              text: 'No albums',
            ),
            settingsRouteKey: AlbumListPage.routeName,
            appBarHeight: AlbumPickAppBar.preferredHeight,
            onTap: (filter) => Navigator.pop<String>(context, (filter as AlbumFilter)?.album),
          ),
        );
      },
    );
  }
}

class AlbumPickAppBar extends StatelessWidget {
  final CollectionSource source;
  final MoveType moveType;
  final AlbumChipSetActionDelegate actionDelegate;
  final ValueNotifier<String> queryNotifier;

  static const preferredHeight = kToolbarHeight + AlbumFilterBar.preferredHeight;

  const AlbumPickAppBar({
    @required this.source,
    @required this.moveType,
    @required this.actionDelegate,
    @required this.queryNotifier,
  });

  @override
  Widget build(BuildContext context) {
    String title() {
      switch (moveType) {
        case MoveType.copy:
          return 'Copy to Album';
        case MoveType.export:
          return 'Export to Album';
        case MoveType.move:
          return 'Move to Album';
        default:
          return null;
      }
    }

    return SliverAppBar(
      leading: BackButton(),
      title: SourceStateAwareAppBarTitle(
        title: Text(title()),
        source: source,
      ),
      bottom: AlbumFilterBar(
        filterNotifier: queryNotifier,
      ),
      actions: [
        IconButton(
          icon: Icon(AIcons.createAlbum),
          onPressed: () async {
            final newAlbum = await showDialog<String>(
              context: context,
              builder: (context) => CreateAlbumDialog(),
            );
            if (newAlbum != null && newAlbum.isNotEmpty) {
              Navigator.pop<String>(context, newAlbum);
            }
          },
          tooltip: 'Create album',
        ),
        PopupMenuButton<ChipSetAction>(
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: ChipSetAction.sort,
                child: MenuRow(text: 'Sort…', icon: AIcons.sort),
              ),
              PopupMenuItem(
                value: ChipSetAction.group,
                child: MenuRow(text: 'Group…', icon: AIcons.group),
              ),
            ];
          },
          onSelected: (action) {
            // wait for the popup menu to hide before proceeding with the action
            Future.delayed(Durations.popupMenuAnimation * timeDilation, () => actionDelegate.onActionSelected(context, action));
          },
        ),
      ],
      floating: true,
    );
  }
}

class AlbumFilterBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<String> filterNotifier;

  static const preferredHeight = kToolbarHeight;

  const AlbumFilterBar({
    @required this.filterNotifier,
  });

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AlbumFilterBar.preferredHeight,
      alignment: Alignment.topCenter,
      child: QueryBar(
        filterNotifier: filterNotifier,
      ),
    );
  }
}
