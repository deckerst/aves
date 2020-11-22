import 'package:aves/model/filters/album.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/action_delegates/create_album_dialog.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AlbumPickPage extends StatefulWidget {
  static const routeName = '/album_pick';

  final CollectionSource source;
  final bool copy;

  const AlbumPickPage({
    @required this.source,
    @required this.copy,
  });

  @override
  _AlbumPickPageState createState() => _AlbumPickPageState();
}

class _AlbumPickPageState extends State<AlbumPickPage> {
  final _filterNotifier = ValueNotifier('');

  CollectionSource get source => widget.source;

  @override
  Widget build(BuildContext context) {
    Widget appBar = AlbumPickAppBar(
      copy: widget.copy,
      actionDelegate: AlbumChipSetActionDelegate(source: source),
      filterNotifier: _filterNotifier,
    );

    return Selector<Settings, ChipSortFactor>(
      selector: (context, s) => s.albumSortFactor,
      builder: (context, sortFactor, child) {
        return ValueListenableBuilder<String>(
          valueListenable: _filterNotifier,
          builder: (context, filter, child) => FilterGridPage(
            source: source,
            appBar: appBar,
            filterEntries: AlbumListPage.getAlbumEntries(source, filter: filter),
            filterBuilder: (s) => AlbumFilter(s, source.getUniqueAlbumName(s)),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.album,
              text: 'No albums',
            ),
            appBarHeight: AlbumPickAppBar.preferredHeight,
            onTap: (filter) => Navigator.pop<String>(context, (filter as AlbumFilter)?.album),
          ),
        );
      },
    );
  }
}

class AlbumPickAppBar extends StatelessWidget {
  final bool copy;
  final AlbumChipSetActionDelegate actionDelegate;
  final ValueNotifier<String> filterNotifier;

  static const preferredHeight = kToolbarHeight + AlbumFilterBar.preferredHeight;

  const AlbumPickAppBar({
    @required this.copy,
    @required this.actionDelegate,
    @required this.filterNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: BackButton(),
      title: Text(copy ? 'Copy to Album' : 'Move to Album'),
      bottom: AlbumFilterBar(
        filterNotifier: filterNotifier,
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
        IconButton(
          icon: Icon(AIcons.sort),
          onPressed: () => actionDelegate.onActionSelected(context, ChipSetAction.sort),
          tooltip: 'Sort…',
        ),
      ],
      floating: true,
    );
  }
}

class AlbumFilterBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<String> filterNotifier;

  static const preferredHeight = kToolbarHeight;

  const AlbumFilterBar({@required this.filterNotifier});

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  _AlbumFilterBarState createState() => _AlbumFilterBarState();
}

class _AlbumFilterBarState extends State<AlbumFilterBar> {
  final Debouncer _debouncer = Debouncer(delay: Durations.searchDebounceDelay);
  TextEditingController _controller;

  ValueNotifier<String> get filterNotifier => widget.filterNotifier;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: filterNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    final clearButton = IconButton(
      icon: Icon(AIcons.clear),
      onPressed: () {
        _controller.clear();
        filterNotifier.value = '';
      },
      tooltip: 'Clear',
    );
    return Container(
      height: AlbumFilterBar.preferredHeight,
      alignment: Alignment.topCenter,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon(AIcons.search),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                icon: Padding(
                  padding: EdgeInsetsDirectional.only(start: 16),
                  child: Icon(AIcons.search),
                ),
                // border: OutlineInputBorder(),
                hintText: MaterialLocalizations.of(context).searchFieldLabel,
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (s) => _debouncer(() => filterNotifier.value = s),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 16),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => AnimatedSwitcher(
                duration: Durations.appBarActionChangeAnimation,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    axis: Axis.horizontal,
                    sizeFactor: animation,
                    child: child,
                  ),
                ),
                child: _controller.text.isNotEmpty ? clearButton : SizedBox.shrink(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
