import 'package:aves/model/covers.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/album_set.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AlbumListPage extends StatelessWidget {
  static const routeName = '/albums';

  const AlbumListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return Selector<Settings, Tuple3<AlbumChipGroupFactor, ChipSortFactor, Set<CollectionFilter>>>(
      selector: (context, s) => Tuple3(s.albumGroupFactor, s.albumSortFactor, s.pinnedFilters),
      shouldRebuild: (t1, t2) {
        // `Selector` by default uses `DeepCollectionEquality`, which does not go deep in collections within `TupleN`
        const eq = DeepCollectionEquality();
        return !(eq.equals(t1.item1, t2.item1) && eq.equals(t1.item2, t2.item2) && eq.equals(t1.item3, t2.item3));
      },
      builder: (context, s, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: androidFileUtils.areAppNamesReadyNotifier,
          builder: (context, areAppNamesReady, child) {
            return StreamBuilder(
              stream: source.eventBus.on<AlbumsChangedEvent>(),
              builder: (context, snapshot) {
                final gridItems = getAlbumGridItems(context, source);
                return StreamBuilder<Set<CollectionFilter>?>(
                  // to update sections by tier
                  stream: covers.packageChangeStream,
                  builder: (context, snapshot) => FilterNavigationPage<AlbumFilter>(
                    source: source,
                    title: context.l10n.albumPageTitle,
                    sortFactor: settings.albumSortFactor,
                    showHeaders: settings.albumGroupFactor != AlbumChipGroupFactor.none,
                    actionDelegate: AlbumChipSetActionDelegate(gridItems),
                    filterSections: groupToSections(context, source, gridItems),
                    newFilters: source.getNewAlbumFilters(context),
                    emptyBuilder: () => EmptyContent(
                      icon: AIcons.album,
                      text: context.l10n.albumEmpty,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // common with album selection page to move/copy entries

  static List<FilterGridItem<AlbumFilter>> getAlbumGridItems(BuildContext context, CollectionSource source) {
    final filters = source.rawAlbums.map((album) => AlbumFilter(album, source.getAlbumDisplayName(context, album))).toSet();

    return FilterNavigationPage.sort(settings.albumSortFactor, source, filters);
  }

  static Map<ChipSectionKey, List<FilterGridItem<AlbumFilter>>> groupToSections(BuildContext context, CollectionSource source, Iterable<FilterGridItem<AlbumFilter>> sortedMapEntries) {
    final newFilters = source.getNewAlbumFilters(context);
    final pinned = settings.pinnedFilters.whereType<AlbumFilter>();

    final List<FilterGridItem<AlbumFilter>> newMapEntries = [], pinnedMapEntries = [], unpinnedMapEntries = [];
    for (final item in sortedMapEntries) {
      final filter = item.filter;
      if (newFilters.contains(filter)) {
        newMapEntries.add(item);
      } else if (pinned.contains(filter)) {
        pinnedMapEntries.add(item);
      } else {
        unpinnedMapEntries.add(item);
      }
    }

    var sections = <ChipSectionKey, List<FilterGridItem<AlbumFilter>>>{};
    switch (settings.albumGroupFactor) {
      case AlbumChipGroupFactor.importance:
        final specialKey = AlbumImportanceSectionKey.special(context);
        final appsKey = AlbumImportanceSectionKey.apps(context);
        final regularKey = AlbumImportanceSectionKey.regular(context);
        sections = groupBy<FilterGridItem<AlbumFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          switch (covers.effectiveAlbumType(kv.filter.album)) {
            case AlbumType.regular:
              return regularKey;
            case AlbumType.app:
              return appsKey;
            default:
              return specialKey;
          }
        });

        sections = {
          // group ordering
          if (sections.containsKey(specialKey)) specialKey: sections[specialKey]!,
          if (sections.containsKey(appsKey)) appsKey: sections[appsKey]!,
          if (sections.containsKey(regularKey)) regularKey: sections[regularKey]!,
        };
        break;
      case AlbumChipGroupFactor.volume:
        sections = groupBy<FilterGridItem<AlbumFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          return StorageVolumeSectionKey(context, androidFileUtils.getStorageVolume(kv.filter.album));
        });
        break;
      case AlbumChipGroupFactor.none:
        return {
          if (sortedMapEntries.isNotEmpty)
            const ChipSectionKey(): [
              ...newMapEntries,
              ...pinnedMapEntries,
              ...unpinnedMapEntries,
            ],
        };
    }

    if (pinnedMapEntries.isNotEmpty) {
      sections = Map.fromEntries([
        MapEntry(AlbumImportanceSectionKey.pinned(context), pinnedMapEntries),
        ...sections.entries,
      ]);
    }

    if (newMapEntries.isNotEmpty) {
      sections = Map.fromEntries([
        MapEntry(AlbumImportanceSectionKey.newAlbum(context), newMapEntries),
        ...sections.entries,
      ]);
    }

    return sections;
  }
}
