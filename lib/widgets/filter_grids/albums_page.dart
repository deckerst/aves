import 'package:aves/model/app_inventory.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/providers/filter_group_provider.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/album_set.dart';
import 'package:aves/widgets/filter_grids/common/enums.dart';
import 'package:aves/widgets/filter_grids/common/filter_nav_page.dart';
import 'package:aves/widgets/filter_grids/common/section_keys.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumListPage extends StatelessWidget {
  static const routeName = '/albums';

  final Uri? initialGroup;

  const AlbumListPage({
    super.key,
    required this.initialGroup,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FilterGrouping>.value(value: albumGrouping),
        FilterGroupProvider(initialValue: initialGroup),
      ],
      child: Builder(
        // to access filter group provider from subtree context
        builder: (context) {
          final source = context.read<CollectionSource>();
          return Selector<Settings, (AlbumChipSectionFactor, ChipSortFactor, bool, Set<CollectionFilter>, Set<CollectionFilter>)>(
            selector: (context, s) => (s.albumSectionFactor, s.albumSortFactor, s.albumSortReverse, s.hiddenFilters, s.pinnedFilters),
            shouldRebuild: (t1, t2) {
              // `Selector` by default uses `DeepCollectionEquality`, which does not go deep in collections within records
              const eq = DeepCollectionEquality();
              return !(eq.equals(t1.$1, t2.$1) && eq.equals(t1.$2, t2.$2) && eq.equals(t1.$3, t2.$3) && eq.equals(t1.$4, t2.$4) && eq.equals(t1.$5, t2.$5));
            },
            builder: (context, s, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: appInventory.areAppNamesReadyNotifier,
                builder: (context, areAppNamesReady, child) {
                  return AnimatedBuilder(
                    animation: Listenable.merge({albumGrouping, dynamicAlbums}),
                    builder: (context, child) => StreamBuilder(
                      stream: source.eventBus.on<AlbumsChangedEvent>(),
                      builder: (context, snapshot) {
                        final groupUri = context.watch<FilterGroupNotifier>().value;
                        final gridItems = getGridItems(context, source, AlbumChipType.values, groupUri);
                        return StreamBuilder<Set<CollectionFilter>?>(
                          // to update sections by tier
                          stream: covers.packageChangeStream,
                          builder: (context, snapshot) => FilterNavigationPage<AlbumBaseFilter, AlbumChipSetActionDelegate>(
                            source: source,
                            title: context.l10n.albumPageTitle,
                            sortFactor: settings.albumSortFactor,
                            showHeaders: settings.albumSectionFactor != AlbumChipSectionFactor.none,
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
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // common with picking page

  static List<FilterGridItem<AlbumBaseFilter>> getGridItems(
    BuildContext context,
    CollectionSource source,
    Iterable<AlbumChipType> albumChipTypes,
    Uri? groupUri,
  ) {
    final groupContent = albumGrouping.getDirectChildren(groupUri);

    Set<T> whereTypeRecursively<T>(Set<CollectionFilter> filters) {
      return {
        ...filters.whereType<T>(),
        ...filters.whereType<AlbumGroupFilter>().expand((v) => whereTypeRecursively<T>(v.filter.innerFilters)),
      };
    }

    final listedStoredAlbums = <String>{};
    if (albumChipTypes.contains(AlbumChipType.stored)) {
      final allAlbums = source.rawAlbums;
      if (groupUri == null) {
        final withinGroups = whereTypeRecursively<StoredAlbumFilter>(groupContent).map((v) => v.album).toSet();
        listedStoredAlbums.addAll(allAlbums.whereNot(withinGroups.contains));
      } else {
        // check that group content is listed from source, to prevent displaying hidden content
        listedStoredAlbums.addAll(groupContent.whereType<StoredAlbumFilter>().map((v) => v.album).where(allAlbums.contains));
      }
    }

    final listedDynamicAlbums = <DynamicAlbumFilter>{};
    if (albumChipTypes.contains(AlbumChipType.dynamic)) {
      final allDynamicAlbums = dynamicAlbums.all.whereNot(settings.hiddenFilters.contains).toSet();
      if (groupUri == null) {
        final withinGroups = whereTypeRecursively<DynamicAlbumFilter>(groupContent).toSet();
        listedDynamicAlbums.addAll(allDynamicAlbums.whereNot(withinGroups.contains));
      } else {
        // check that group content is listed from source, to prevent displaying hidden content
        listedDynamicAlbums.addAll(groupContent.whereType<DynamicAlbumFilter>().where(allDynamicAlbums.contains));
      }
    }

    // always show groups, which are needed to navigate to other types
    final albumGroupFilters = groupContent.whereType<AlbumGroupFilter>().whereNot(settings.hiddenFilters.contains).toSet();

    final filters = <AlbumBaseFilter>{
      ...albumGroupFilters,
      ...listedStoredAlbums.map((album) => StoredAlbumFilter(album, source.getStoredAlbumDisplayName(context, album))),
      ...listedDynamicAlbums,
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
    switch (settings.albumSectionFactor) {
      case AlbumChipSectionFactor.importance:
        final groupKey = AlbumImportanceSectionKey.group(context);
        final specialKey = AlbumImportanceSectionKey.special(context);
        final appsKey = AlbumImportanceSectionKey.apps(context);
        final vaultKey = AlbumImportanceSectionKey.vault(context);
        final regularKey = AlbumImportanceSectionKey.regular(context);
        final dynamicKey = AlbumImportanceSectionKey.dynamic(context);
        sections = groupBy<FilterGridItem<AlbumBaseFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          final filter = kv.filter;
          switch (filter) {
            case StoredAlbumFilter _:
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
            case DynamicAlbumFilter _:
              return dynamicKey;
            case AlbumGroupFilter _:
              return groupKey;
          }
          return specialKey;
        });

        sections = {
          // group ordering
          if (sections.containsKey(groupKey)) groupKey: sections[groupKey]!,
          if (sections.containsKey(specialKey)) specialKey: sections[specialKey]!,
          if (sections.containsKey(appsKey)) appsKey: sections[appsKey]!,
          if (sections.containsKey(vaultKey)) vaultKey: sections[vaultKey]!,
          if (sections.containsKey(dynamicKey)) dynamicKey: sections[dynamicKey]!,
          if (sections.containsKey(regularKey)) regularKey: sections[regularKey]!,
        };
      case AlbumChipSectionFactor.mimeType:
        final visibleEntries = source.visibleEntries;
        sections = groupBy<FilterGridItem<AlbumBaseFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          final matches = visibleEntries.where(kv.filter.test);
          final hasImage = matches.any((v) => v.isImage);
          final hasVideo = matches.any((v) => v.isVideo);
          if (hasImage && !hasVideo) return MimeTypeSectionKey.images(context);
          if (!hasImage && hasVideo) return MimeTypeSectionKey.videos(context);
          return MimeTypeSectionKey.mixed(context);
        });
      case AlbumChipSectionFactor.volume:
        sections = groupBy<FilterGridItem<AlbumBaseFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          final filter = kv.filter;
          return StorageVolumeSectionKey(context, filter is StoredAlbumFilter ? filter.storageVolume : null);
        });
      case AlbumChipSectionFactor.none:
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
