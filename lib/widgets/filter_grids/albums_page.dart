import 'package:aves/model/filters/album.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/album/empty.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/filter_grids/filter_grid_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class AlbumListPage extends StatelessWidget {
  static const routeName = '/albums';

  final CollectionSource source;

  const AlbumListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, ChipSortFactor>(
      selector: (context, s) => s.albumSortFactor,
      builder: (context, albumSortFactor, child) {
        return AnimatedBuilder(
          animation: androidFileUtils.appNameChangeNotifier,
          builder: (context, child) => StreamBuilder(
            stream: source.eventBus.on<AlbumsChangedEvent>(),
            builder: (context, snapshot) {
              return FilterNavigationPage(
                source: source,
                title: 'Albums',
                actions: _buildActions(),
                filterEntries: getAlbumEntries(source),
                filterBuilder: (s) => AlbumFilter(s, source.getUniqueAlbumName(s)),
                emptyBuilder: () => EmptyContent(
                  icon: AIcons.album,
                  text: 'No albums',
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildActions() {
    return [
      Builder(
        builder: (context) => PopupMenuButton<ChipAction>(
          key: Key('appbar-menu-button'),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                key: Key('menu-sort'),
                value: ChipAction.sort,
                child: MenuRow(text: 'Sort...', icon: AIcons.sort),
              ),
            ];
          },
          onSelected: (action) => _onChipActionSelected(context, action),
        ),
      ),
    ];
  }

  void _onChipActionSelected(BuildContext context, ChipAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(Durations.popupMenuAnimation * timeDilation);
    switch (action) {
      case ChipAction.sort:
        final factor = await showDialog<ChipSortFactor>(
          context: context,
          builder: (context) => AvesSelectionDialog<ChipSortFactor>(
            initialValue: settings.albumSortFactor,
            options: {
              ChipSortFactor.date: 'By date',
              ChipSortFactor.name: 'By name',
            },
            title: 'Sort',
          ),
        );
        if (factor != null) {
          settings.albumSortFactor = factor;
        }
        break;
    }
  }

  // common with album selection page to move/copy entries

  static Map<String, ImageEntry> getAlbumEntries(CollectionSource source) {
    final entriesByDate = source.sortedEntriesForFilterList;
    final albumEntries = source.sortedAlbums.map((album) {
      return MapEntry(
        album,
        entriesByDate.firstWhere((entry) => entry.directory == album, orElse: () => null),
      );
    }).toList();

    switch (settings.albumSortFactor) {
      case ChipSortFactor.date:
        albumEntries.sort((a, b) {
          final c = b.value.bestDate?.compareTo(a.value.bestDate) ?? -1;
          return c != 0 ? c : compareAsciiUpperCase(a.key, b.key);
        });
        return Map.fromEntries(albumEntries);
      case ChipSortFactor.name:
      default:
        final regularAlbums = <String>[], appAlbums = <String>[], specialAlbums = <String>[];
        for (var album in source.sortedAlbums) {
          switch (androidFileUtils.getAlbumType(album)) {
            case AlbumType.regular:
              regularAlbums.add(album);
              break;
            case AlbumType.app:
              appAlbums.add(album);
              break;
            default:
              specialAlbums.add(album);
              break;
          }
        }
        return Map.fromEntries([...specialAlbums, ...appAlbums, ...regularAlbums].map((album) {
          return MapEntry(
            album,
            entriesByDate.firstWhere((entry) => entry.directory == album, orElse: () => null),
          );
        }));
    }
  }
}
