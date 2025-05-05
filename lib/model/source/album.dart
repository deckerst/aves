import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

mixin AlbumMixin on SourceBase {
  final Set<String> _directories = {};
  final Set<String> _newAlbums = {};

  List<String> get rawAlbums => List.unmodifiable(_directories);

  Set<StoredAlbumFilter> getNewAlbumFilters(BuildContext context) => Set.unmodifiable(_newAlbums.map((v) => StoredAlbumFilter(v, getStoredAlbumDisplayName(context, v))));

  int compareAlbumsByName(String? a, String? b) {
    a ??= '';
    b ??= '';
    final ua = getStoredAlbumDisplayName(null, a);
    final ub = getStoredAlbumDisplayName(null, b);
    final c = compareAsciiUpperCaseNatural(ua, ub);
    if (c != 0) return c;
    final va = androidFileUtils.getStorageVolume(a)?.path ?? '';
    final vb = androidFileUtils.getStorageVolume(b)?.path ?? '';
    return compareAsciiUpperCaseNatural(va, vb);
  }

  void notifyAlbumsChanged() {
    eventBus.fire(AlbumsChangedEvent());
  }

  void _onAlbumChanged({bool notify = true}) {
    invalidateStoredAlbumDisplayNames();
    if (notify) {
      notifyAlbumsChanged();
    }
  }

  Map<String, AvesEntry?> getAlbumEntries() {
    final entries = sortedEntriesByDate;
    final regularAlbums = <String>[], appAlbums = <String>[], specialAlbums = <String>[];
    for (final album in rawAlbums) {
      switch (androidFileUtils.getAlbumType(album)) {
        case AlbumType.regular:
          regularAlbums.add(album);
        case AlbumType.app:
          appAlbums.add(album);
        default:
          specialAlbums.add(album);
      }
    }
    return Map.fromEntries([...specialAlbums, ...appAlbums, ...regularAlbums].map((album) => MapEntry(
          album,
          entries.firstWhereOrNull((entry) => entry.directory == album),
        )));
  }

  void updateDirectories() {
    addDirectories(albums: {
      ...visibleEntries.map((entry) => entry.directory),
      ...vaults.all.map((v) => v.path),
    });
    cleanEmptyAlbums();
  }

  void addDirectories({required Set<String?> albums, bool notify = true}) {
    if (!_directories.containsAll(albums)) {
      _directories.addAll(albums.nonNulls);
      _onAlbumChanged(notify: notify);
    }
  }

  void cleanEmptyAlbums([Set<String>? albums]) {
    final removableAlbums = (albums ?? _directories).where(_isRemovable).toSet();
    if (removableAlbums.isNotEmpty) {
      _directories.removeAll(removableAlbums);
      _onAlbumChanged();
      invalidateAlbumFilterSummary(directories: removableAlbums);
    }
  }

  bool _isRemovable(String album) {
    if (visibleEntries.any((entry) => entry.directory == album)) return false;
    if (_newAlbums.contains(album)) return false;
    if (vaults.isVault(album)) return false;
    if (settings.pinnedFilters.whereType<StoredAlbumFilter>().map((v) => v.album).contains(album)) return false;
    return true;
  }

  // filter summary

  // by filter key
  final Map<String, int> _filterEntryCountMap = {}, _filterSizeMap = {};
  final Map<String, AvesEntry?> _filterRecentEntryMap = {};

  void invalidateAlbumFilterSummary({
    Set<AvesEntry>? entries,
    Set<String?>? directories,
    bool notify = true,
  }) {
    if (_filterEntryCountMap.isEmpty && _filterSizeMap.isEmpty && _filterRecentEntryMap.isEmpty) return;

    if (entries == null && directories == null) {
      _filterEntryCountMap.clear();
      _filterSizeMap.clear();
      _filterRecentEntryMap.clear();
    } else {
      // clear entries only for modified album directories
      directories ??= {};
      if (entries != null) {
        directories.addAll(entries.map((entry) => entry.directory).nonNulls);
      }
      directories.nonNulls.map((v) => StoredAlbumFilter(v, null).key).forEach((key) {
        _filterEntryCountMap.remove(key);
        _filterSizeMap.remove(key);
        _filterRecentEntryMap.remove(key);
      });

      // clear entries for all dynamic albums and groups
      invalidateDynamicAlbumFilterSummary(notify: false);
      invalidateAlbumGroupFilterSummary(notify: false);
    }
    if (notify) {
      eventBus.fire(StoredAlbumSummaryInvalidatedEvent(directories));
      eventBus.fire(const DynamicAlbumSummaryInvalidatedEvent());
      eventBus.fire(const AlbumGroupSummaryInvalidatedEvent());
    }
  }

  void invalidateDynamicAlbumFilterSummary({bool notify = true}) {
    _filterEntryCountMap.removeWhere(_isDynamicAlbumKey);
    _filterSizeMap.removeWhere(_isDynamicAlbumKey);
    _filterRecentEntryMap.removeWhere(_isDynamicAlbumKey);

    if (notify) {
      eventBus.fire(const DynamicAlbumSummaryInvalidatedEvent());
    }
  }

  void invalidateAlbumGroupFilterSummary({bool notify = true}) {
    _filterEntryCountMap.removeWhere(_isAlbumGroupKey);
    _filterSizeMap.removeWhere(_isAlbumGroupKey);
    _filterRecentEntryMap.removeWhere(_isAlbumGroupKey);

    if (notify) {
      eventBus.fire(const AlbumGroupSummaryInvalidatedEvent());
    }
  }

  bool _isDynamicAlbumKey(String key, _) => key.startsWith('${DynamicAlbumFilter.type}-');

  bool _isAlbumGroupKey(String key, _) => key.startsWith('${AlbumGroupFilter.type}-');

  int albumEntryCount(AlbumBaseFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter.key, () => visibleEntries.where(filter.test).length);
  }

  int albumSize(AlbumBaseFilter filter) {
    return _filterSizeMap.putIfAbsent(filter.key, () => visibleEntries.where(filter.test).map((v) => v.sizeBytes).sum);
  }

  AvesEntry? albumRecentEntry(AlbumBaseFilter filter) {
    return _filterRecentEntryMap.putIfAbsent(filter.key, () => sortedEntriesByDate.firstWhereOrNull(filter.test));
  }

  // new albums

  void createStoredAlbum(String directory) {
    if (!_directories.contains(directory)) {
      _newAlbums.add(directory);
      addDirectories(albums: {directory});
    }
  }

  void renameNewAlbum(String source, String destination) {
    if (_newAlbums.remove(source)) {
      cleanEmptyAlbums({source});
      createStoredAlbum(destination);
    }
  }

  void forgetNewAlbums(Set<String> directories) {
    _newAlbums.removeAll(directories);
  }

  // display names

  final Map<String, String> _albumDisplayNamesWithContext = {}, _albumDisplayNamesWithoutContext = {};

  void invalidateStoredAlbumDisplayNames() {
    _albumDisplayNamesWithContext.clear();
    _albumDisplayNamesWithoutContext.clear();
  }

  String _computeStoredAlbumDisplayName(BuildContext? context, String dirPath) {
    final separator = pContext.separator;
    assert(!dirPath.endsWith(separator));

    final type = androidFileUtils.getAlbumType(dirPath);
    if (context != null) {
      final name = type.getName(context);
      if (name != null) return name;
    }

    if (type == AlbumType.vault) return pContext.basename(dirPath);

    final dir = androidFileUtils.relativeDirectoryFromPath(dirPath);
    if (dir == null) return dirPath;

    final relativeDir = dir.relativeDir;
    if (relativeDir.isEmpty) {
      final volume = androidFileUtils.getStorageVolume(dirPath)!;
      return volume.getDescription(context);
    }

    String unique(String dirPath, Set<String> others) {
      final parts = pContext.split(dirPath);
      for (var i = parts.length - 1; i > 0; i--) {
        final name = pContext.joinAll(['', ...parts.skip(i)]);
        final testName = '$separator${name.toLowerCase()}';
        if (others.every((item) => !item.endsWith(testName))) return name;
      }
      return dirPath;
    }

    final otherAlbumsOnDevice = _directories.nonNulls.where((item) => item != dirPath).map((v) => v.toLowerCase()).toSet();
    final uniqueNameInDevice = unique(dirPath, otherAlbumsOnDevice);
    if (uniqueNameInDevice.length <= relativeDir.length) {
      return uniqueNameInDevice;
    }

    final volumePath = dir.volumePath.toLowerCase();
    String trimVolumePath(String? path) => path!.substring(dir.volumePath.length);
    final otherAlbumsOnVolume = otherAlbumsOnDevice.where((path) => path.startsWith(volumePath)).map(trimVolumePath).toSet();
    final uniqueNameInVolume = unique(trimVolumePath(dirPath), otherAlbumsOnVolume);
    final volume = androidFileUtils.getStorageVolume(dirPath)!;
    if (volume.isPrimary) {
      return uniqueNameInVolume;
    } else {
      return '$uniqueNameInVolume (${volume.getDescription(context)})';
    }
  }

  String getStoredAlbumDisplayName(BuildContext? context, String dirPath) {
    final names = (context != null ? _albumDisplayNamesWithContext : _albumDisplayNamesWithoutContext);
    return names.putIfAbsent(dirPath, () => _computeStoredAlbumDisplayName(context, dirPath));
  }
}

class AlbumsChangedEvent {}

class DynamicAlbumSummaryInvalidatedEvent {
  const DynamicAlbumSummaryInvalidatedEvent();
}

class AlbumGroupSummaryInvalidatedEvent {
  const AlbumGroupSummaryInvalidatedEvent();
}

class StoredAlbumSummaryInvalidatedEvent {
  final Set<String?>? directories;

  const StoredAlbumSummaryInvalidatedEvent(this.directories);
}
