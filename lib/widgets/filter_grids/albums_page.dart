import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
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
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AlbumListPage extends StatelessWidget {
  static const routeName = '/albums';

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return Selector<Settings, Tuple3<AlbumChipGroupFactor, ChipSortFactor, Set<CollectionFilter>>>(
      selector: (context, s) => Tuple3(s.albumGroupFactor, s.albumSortFactor, s.pinnedFilters),
      builder: (context, s, child) {
        return AnimatedBuilder(
          animation: androidFileUtils.appNameChangeNotifier,
          builder: (context, child) => StreamBuilder(
            stream: source.eventBus.on<AlbumsChangedEvent>(),
            builder: (context, snapshot) => FilterNavigationPage<AlbumFilter>(
              source: source,
              title: 'Albums',
              groupable: true,
              showHeaders: settings.albumGroupFactor != AlbumChipGroupFactor.none,
              chipSetActionDelegate: AlbumChipSetActionDelegate(source: source),
              chipActionDelegate: AlbumChipActionDelegate(source: source),
              chipActionsBuilder: (filter) => [
                settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
                ChipAction.rename,
                ChipAction.delete,
                ChipAction.hide,
              ],
              filterSections: getAlbumEntries(source),
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

  static Map<ChipSectionKey, List<FilterGridItem<AlbumFilter>>> getAlbumEntries(CollectionSource source) {
    final filters = source.rawAlbums.map((album) => AlbumFilter(album, source.getUniqueAlbumName(album))).toSet();

    final sorted = FilterNavigationPage.sort(settings.albumSortFactor, source, filters);
    return _group(sorted);
  }

  static Map<ChipSectionKey, List<FilterGridItem<AlbumFilter>>> _group(Iterable<FilterGridItem<AlbumFilter>> sortedMapEntries) {
    final pinned = settings.pinnedFilters.whereType<AlbumFilter>();
    final byPin = groupBy<FilterGridItem<AlbumFilter>, bool>(sortedMapEntries, (e) => pinned.contains(e.filter));
    final pinnedMapEntries = (byPin[true] ?? []);
    final unpinnedMapEntries = (byPin[false] ?? []);

    var sections = <ChipSectionKey, List<FilterGridItem<AlbumFilter>>>{};
    switch (settings.albumGroupFactor) {
      case AlbumChipGroupFactor.importance:
        sections = groupBy<FilterGridItem<AlbumFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          switch (androidFileUtils.getAlbumType(kv.filter.album)) {
            case AlbumType.regular:
              return AlbumImportanceSectionKey.regular;
            case AlbumType.app:
              return AlbumImportanceSectionKey.apps;
            default:
              return AlbumImportanceSectionKey.special;
          }
        });
        sections = {
          AlbumImportanceSectionKey.special: sections[AlbumImportanceSectionKey.special],
          AlbumImportanceSectionKey.apps: sections[AlbumImportanceSectionKey.apps],
          AlbumImportanceSectionKey.regular: sections[AlbumImportanceSectionKey.regular],
        }..removeWhere((key, value) => value == null);
        break;
      case AlbumChipGroupFactor.volume:
        sections = groupBy<FilterGridItem<AlbumFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          return StorageVolumeSectionKey(androidFileUtils.getStorageVolume(kv.filter.album));
        });
        break;
      case AlbumChipGroupFactor.none:
        return {
          if (pinnedMapEntries.isNotEmpty || unpinnedMapEntries.isNotEmpty)
            ChipSectionKey(): [
              ...pinnedMapEntries,
              ...unpinnedMapEntries,
            ],
        };
    }

    if (pinnedMapEntries.isNotEmpty) {
      sections = Map.fromEntries([
        MapEntry(AlbumImportanceSectionKey.pinned, pinnedMapEntries),
        ...sections.entries,
      ]);
    }

    return sections;
  }
}
