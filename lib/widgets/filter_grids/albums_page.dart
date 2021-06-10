import 'package:aves/model/actions/chip_actions.dart';
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
              title: context.l10n.albumPageTitle,
              sortFactor: settings.albumSortFactor,
              groupable: true,
              showHeaders: settings.albumGroupFactor != AlbumChipGroupFactor.none,
              chipSetActionDelegate: AlbumChipSetActionDelegate(),
              chipActionDelegate: AlbumChipActionDelegate(),
              chipActionsBuilder: (filter) {
                final dir = VolumeRelativeDirectory.fromPath(filter.album);
                // do not allow renaming volume root
                final canRename = dir != null && dir.relativeDir.isNotEmpty;
                return [
                  settings.pinnedFilters.contains(filter) ? ChipAction.unpin : ChipAction.pin,
                  ChipAction.setCover,
                  if (canRename) ChipAction.rename,
                  ChipAction.delete,
                  ChipAction.hide,
                ];
              },
              filterSections: getAlbumEntries(context, source),
              emptyBuilder: () => EmptyContent(
                icon: AIcons.album,
                text: context.l10n.albumEmpty,
              ),
            ),
          ),
        );
      },
    );
  }

  // common with album selection page to move/copy entries

  static Map<ChipSectionKey, List<FilterGridItem<AlbumFilter>>> getAlbumEntries(BuildContext context, CollectionSource source) {
    final filters = source.rawAlbums.map((album) => AlbumFilter(album, source.getAlbumDisplayName(context, album))).toSet();

    final sorted = FilterNavigationPage.sort(settings.albumSortFactor, source, filters);
    return _group(context, sorted);
  }

  static Map<ChipSectionKey, List<FilterGridItem<AlbumFilter>>> _group(BuildContext context, Iterable<FilterGridItem<AlbumFilter>> sortedMapEntries) {
    final pinned = settings.pinnedFilters.whereType<AlbumFilter>();
    final byPin = groupBy<FilterGridItem<AlbumFilter>, bool>(sortedMapEntries, (e) => pinned.contains(e.filter));
    final pinnedMapEntries = byPin[true] ?? [];
    final unpinnedMapEntries = byPin[false] ?? [];

    var sections = <ChipSectionKey, List<FilterGridItem<AlbumFilter>>>{};
    switch (settings.albumGroupFactor) {
      case AlbumChipGroupFactor.importance:
        final specialKey = AlbumImportanceSectionKey.special(context);
        final appsKey = AlbumImportanceSectionKey.apps(context);
        final regularKey = AlbumImportanceSectionKey.regular(context);
        sections = groupBy<FilterGridItem<AlbumFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          switch (androidFileUtils.getAlbumType(kv.filter.album)) {
            case AlbumType.regular:
              return regularKey;
            case AlbumType.app:
              return appsKey;
            default:
              return specialKey;
          }
        });
        sections = Map.fromEntries({
          // group ordering
          specialKey: sections[specialKey],
          appsKey: sections[appsKey],
          regularKey: sections[regularKey],
        }.entries.where((kv) => kv.value != null).cast<MapEntry<ChipSectionKey, List<FilterGridItem<AlbumFilter>>>>());
        break;
      case AlbumChipGroupFactor.volume:
        sections = groupBy<FilterGridItem<AlbumFilter>, ChipSectionKey>(unpinnedMapEntries, (kv) {
          return StorageVolumeSectionKey(context, androidFileUtils.getStorageVolume(kv.filter.album));
        });
        break;
      case AlbumChipGroupFactor.none:
        return {
          if (pinnedMapEntries.isNotEmpty || unpinnedMapEntries.isNotEmpty)
            const ChipSectionKey(): [
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

    return sections;
  }
}
