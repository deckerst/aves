import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/filter_grids/common/chip_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/chip_set_action_delegate.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
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
            builder: (context, snapshot) => FilterNavigationPage<AlbumFilter>(
              source: source,
              title: 'Albums',
              chipSetActionDelegate: AlbumChipSetActionDelegate(source: source),
              chipActionDelegate: AlbumChipActionDelegate(source: source),
              chipActionsBuilder: (filter) => [
                settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
                ChipAction.rename,
                ChipAction.delete,
              ],
              filterEntries: getAlbumEntries(source),
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

  static Map<AlbumFilter, ImageEntry> getAlbumEntries(CollectionSource source) {
    final pinned = settings.pinnedFilters.whereType<AlbumFilter>();
    final entriesByDate = source.sortedEntriesForFilterList;

    AlbumFilter _buildFilter(String album) => AlbumFilter(album, source.getUniqueAlbumName(album));

    // albums are initially sorted by name at the source level
    var sortedFilters = source.sortedAlbums.map(_buildFilter);

    if (settings.albumSortFactor == ChipSortFactor.name) {
      final pinnedAlbums = <AlbumFilter>[], regularAlbums = <AlbumFilter>[], appAlbums = <AlbumFilter>[], specialAlbums = <AlbumFilter>[];
      for (var filter in sortedFilters) {
        if (pinned.contains(filter)) {
          pinnedAlbums.add(filter);
        } else {
          switch (androidFileUtils.getAlbumType(filter.album)) {
            case AlbumType.regular:
              regularAlbums.add(filter);
              break;
            case AlbumType.app:
              appAlbums.add(filter);
              break;
            default:
              specialAlbums.add(filter);
              break;
          }
        }
      }
      return Map.fromEntries([...pinnedAlbums, ...specialAlbums, ...appAlbums, ...regularAlbums].map((filter) {
        return MapEntry(
          filter,
          entriesByDate.firstWhere((entry) => entry.directory == filter.album, orElse: () => null),
        );
      }));
    }

    if (settings.albumSortFactor == ChipSortFactor.count) {
      final filtersWithCount = List.of(sortedFilters.map((filter) => MapEntry(filter, source.count(filter))));
      filtersWithCount.sort(FilterNavigationPage.compareChipsByEntryCount);
      sortedFilters = filtersWithCount.map((kv) => kv.key).toList();
    }

    final allMapEntries = sortedFilters.map((filter) => MapEntry(
          filter,
          entriesByDate.firstWhere((entry) => entry.directory == filter.album, orElse: () => null),
        ));
    final byPin = groupBy<MapEntry<AlbumFilter, ImageEntry>, bool>(allMapEntries, (e) => pinned.contains(e.key));
    final pinnedMapEntries = (byPin[true] ?? []);
    final unpinnedMapEntries = (byPin[false] ?? []);

    if (settings.albumSortFactor == ChipSortFactor.date) {
      pinnedMapEntries.sort(FilterNavigationPage.compareChipsByDate);
      unpinnedMapEntries.sort(FilterNavigationPage.compareChipsByDate);
    }

    return Map.fromEntries([...pinnedMapEntries, ...unpinnedMapEntries]);
  }
}
