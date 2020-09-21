import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AlbumListPage extends StatelessWidget {
  static const routeName = '/albums';

  final CollectionSource source;

  const AlbumListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, Tuple2<ChipSortFactor, Set<CollectionFilter>>>(
      selector: (context, s) => Tuple2(s.albumSortFactor, s.pinnedFilters),
      builder: (context, s, child) {
        return AnimatedBuilder(
          animation: androidFileUtils.appNameChangeNotifier,
          builder: (context, child) => StreamBuilder(
            stream: source.eventBus.on<AlbumsChangedEvent>(),
            builder: (context, snapshot) => FilterNavigationPage(
              source: source,
              title: 'Albums',
              chipSetActionDelegate: AlbumChipSetActionDelegate(),
              chipActionDelegate: AlbumChipActionDelegate(source: source),
              chipActionsBuilder: (filter) => [
                settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
                ChipAction.rename,
              ],
              filterEntries: getAlbumEntries(source),
              filterBuilder: (album) => AlbumFilter(album, source.getUniqueAlbumName(album)),
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

  // common with album selection page to move/copy entries

  static Map<String, ImageEntry> getAlbumEntries(CollectionSource source) {
    final pinned = settings.pinnedFilters.whereType<AlbumFilter>().map((f) => f.album);
    final entriesByDate = source.sortedEntriesForFilterList;

    switch (settings.albumSortFactor) {
      case ChipSortFactor.date:
        final allAlbumMapEntries = source.sortedAlbums.map((album) => MapEntry(
              album,
              entriesByDate.firstWhere((entry) => entry.directory == album, orElse: () => null),
            ));
        final byPin = groupBy<MapEntry<String, ImageEntry>, bool>(allAlbumMapEntries, (e) => pinned.contains(e.key));
        final pinnedMapEntries = (byPin[true] ?? [])..sort(FilterNavigationPage.compareChipByDate);
        final unpinnedMapEntries = (byPin[false] ?? [])..sort(FilterNavigationPage.compareChipByDate);
        return Map.fromEntries([...pinnedMapEntries, ...unpinnedMapEntries]);
      case ChipSortFactor.name:
      default:
        final pinnedAlbums = <String>[], regularAlbums = <String>[], appAlbums = <String>[], specialAlbums = <String>[];
        for (var album in source.sortedAlbums) {
          if (pinned.contains(album)) {
            pinnedAlbums.add(album);
          } else {
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
        }
        return Map.fromEntries([...pinnedAlbums, ...specialAlbums, ...appAlbums, ...regularAlbums].map((album) {
          return MapEntry(
            album,
            entriesByDate.firstWhere((entry) => entry.directory == album, orElse: () => null),
          );
        }));
    }
  }
}
