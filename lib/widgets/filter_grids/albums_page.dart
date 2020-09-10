import 'package:aves/model/filters/album.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/filter_grid_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumListPage extends StatelessWidget {
  static const routeName = '/albums';

  final CollectionSource source;

  const AlbumListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, ChipSortFactor>(
      selector: (context, s) => s.albumSortFactor,
      builder: (context, sortFactor, child) {
        return AnimatedBuilder(
          animation: androidFileUtils.appNameChangeNotifier,
          builder: (context, child) => StreamBuilder(
            stream: source.eventBus.on<AlbumsChangedEvent>(),
            builder: (context, snapshot) => FilterNavigationPage(
              source: source,
              title: 'Albums',
              onChipActionSelected: _onChipActionSelected,
              filterEntries: getAlbumEntries(source),
              filterBuilder: (s) => AlbumFilter(s, source.getUniqueAlbumName(s)),
              emptyBuilder: () => EmptyContent(
                icon: AIcons.album,
                text: 'No albums',
              ),
            ),
          ),
        );
      },
    );
  }

  void _onChipActionSelected(BuildContext context, ChipAction action) async {
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
    final albums = source.sortedAlbums
        .map((album) => MapEntry(
              album,
              entriesByDate.firstWhere((entry) => entry.directory == album, orElse: () => null),
            ))
        .toList();

    switch (settings.albumSortFactor) {
      case ChipSortFactor.date:
        albums.sort(FilterNavigationPage.compareChipByDate);
        return Map.fromEntries(albums);
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
