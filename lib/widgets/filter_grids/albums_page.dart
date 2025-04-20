import 'package:aves/model/app_inventory.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/filters/covered/album_base.dart';
import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/album_set.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumListPage extends StatelessWidget {
  static const routeName = '/albums';

  const AlbumListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    return Selector<Settings, (AlbumChipGroupFactor, ChipSortFactor, bool, Set<CollectionFilter>)>(
      selector: (context, s) => (s.albumGroupFactor, s.albumSortFactor, s.albumSortReverse, s.pinnedFilters),
      shouldRebuild: (t1, t2) {
        // `Selector` by default uses `DeepCollectionEquality`, which does not go deep in collections within records
        const eq = DeepCollectionEquality();
        return !(eq.equals(t1.$1, t2.$1) && eq.equals(t1.$2, t2.$2) && eq.equals(t1.$3, t2.$3) && eq.equals(t1.$4, t2.$4));
      },
      builder: (context, s, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: appInventory.areAppNamesReadyNotifier,
          builder: (context, areAppNamesReady, child) {
            return AnimatedBuilder(
              animation: dynamicAlbums,
              builder: (context, child) => StreamBuilder(
                stream: source.eventBus.on<AlbumsChangedEvent>(),
                builder: (context, snapshot) {
                  final gridItems = getAlbumGridItems(context, source);
                  return StreamBuilder<Set<CollectionFilter>?>(
                    // to update sections by tier
                    stream: covers.packageChangeStream,
                    builder: (context, snapshot) => FilterNavigationPage<AlbumBaseFilter, AlbumChipSetActionDelegate>(
                      source: source,
                      title: context.l10n.albumPageTitle,
                      sortFactor: settings.albumSortFactor,
                      showHeaders: settings.albumGroupFactor != AlbumChipGroupFactor.none,
                      actionDelegate: AlbumChipSetActionDelegate(gridItems),
                      filterSections: groupToSections(context, source, gridItems),
                      newFilters: source.getNewAlbumFilters(context),
                      applyQuery: applyQuery,
                      emptyBuilder: () => EmptyContent(
                        icon: AIcons.album,
                        text: context.l10n.albumEmpty,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // common with album selection page to move/copy entries

  static List<FilterGridItem<AlbumBaseFilter>> applyQuery(BuildContext context, List<FilterGridItem<AlbumBaseFilter>> filters, String query) {
    return filters.where((item) => item.filter.match(query)).toList();
  }

  static List<FilterGridItem<AlbumBaseFilter>> getAlbumGridItems(BuildContext context, CollectionSource source, {bool storedAlbumsOnly = false}) {
    final filters = <AlbumBaseFilter>{
      ...source.rawAlbums.map((album) => StoredAlbumFilter(album, source.getStoredAlbumDisplayName(context, album))),
      if (!storedAlbumsOnly) ...dynamicAlbums.all,
    };

    return FilterNavigationPage.sort(settings.albumSortFactor, settings.albumSortReverse, source, filters);
  }

  static Map<ChipSectionKey, List<FilterGridItem<AlbumBaseFilter>>> groupToSections(BuildContext context, CollectionSource source, Iterable<FilterGridItem<AlbumBaseFilter>> sortedMapEntries) {
    final newFilters = source.getNewAlbumFilters(context);
    final pinned = settings.pinnedFilters.whereType<AlbumBaseFilter>();

    final List<FilterGridItem<AlbumBaseFilter>> newMapEntries = [], pinnedMapEntries = [], unpinnedMapEntries = [];
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

    var sections = <ChipSectionKey, List<FilterGridItem<AlbumBaseFilter>>>{};
    switch (settings.albumGroupFactor) {
      case AlbumChipGroupFactor.importance:
        final specialKey = AlbumImportanceSectionKey.special(context);
        final appsKey = AlbumImportanceSectionKey.apps(context);
        final vaultKey = AlbumImportanceSectionKey.vault(context);
        final regularKey = AlbumImportanceSectionKey.regular(context);
        final dynamicKey = AlbumImportanceSectionKey.dynamic(context);
        sections = groupBy<FilterGridItem<AlbumBaseFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          final filter = kv.filter;
          if (filter is StoredAlbumFilter) {
            switch (covers.effectiveAlbumType(filter.album)) {
              case AlbumType.regular:
                return regularKey;
              case AlbumType.app:
                return appsKey;
              case AlbumType.vault:
                return vaultKey;
              default:
                return specialKey;
            }
          } else if (filter is DynamicAlbumFilter) {
            return dynamicKey;
          }
          return specialKey;
        });

        sections = {
          // group ordering
          if (sections.containsKey(specialKey)) specialKey: sections[specialKey]!,
          if (sections.containsKey(appsKey)) appsKey: sections[appsKey]!,
          if (sections.containsKey(vaultKey)) vaultKey: sections[vaultKey]!,
          if (sections.containsKey(dynamicKey)) dynamicKey: sections[dynamicKey]!,
          if (sections.containsKey(regularKey)) regularKey: sections[regularKey]!,
        };
      case AlbumChipGroupFactor.mimeType:
        final visibleEntries = source.visibleEntries;
        sections = groupBy<FilterGridItem<AlbumBaseFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          final matches = visibleEntries.where(kv.filter.test);
          final hasImage = matches.any((v) => v.isImage);
          final hasVideo = matches.any((v) => v.isVideo);
          if (hasImage && !hasVideo) return MimeTypeSectionKey.images(context);
          if (!hasImage && hasVideo) return MimeTypeSectionKey.videos(context);
          return MimeTypeSectionKey.mixed(context);
        });
      case AlbumChipGroupFactor.volume:
        sections = groupBy<FilterGridItem<AlbumBaseFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          return StorageVolumeSectionKey(context, kv.filter.storageVolume);
        });
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
