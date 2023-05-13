import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/album.dart';
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

  Set<AlbumFilter> getNewAlbumFilters(BuildContext context) => Set.unmodifiable(_newAlbums.map((v) => AlbumFilter(v, getAlbumDisplayName(context, v))));

  int compareAlbumsByName(String a, String b) {
    final ua = getAlbumDisplayName(null, a);
    final ub = getAlbumDisplayName(null, b);
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
    invalidateAlbumDisplayNames();
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
      _directories.addAll(albums.whereNotNull());
      _onAlbumChanged(notify: notify);
    }
  }

  void cleanEmptyAlbums([Set<String>? albums]) {
    final removableAlbums = (albums ?? _directories).where(_isRemovable).toSet();
    if (removableAlbums.isNotEmpty) {
      _directories.removeAll(removableAlbums);
      _onAlbumChanged();
      invalidateAlbumFilterSummary(directories: removableAlbums);

      final bookmarks = settings.drawerAlbumBookmarks;
      removableAlbums.forEach((album) {
        bookmarks?.remove(album);
      });
      settings.drawerAlbumBookmarks = bookmarks;
    }
  }

  bool _isRemovable(String album) {
    return !(visibleEntries.any((entry) => entry.directory == album) || _newAlbums.contains(album) || vaults.isVault(album));
  }

  // filter summary

  // by directory
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
      directories ??= {};
      if (entries != null) {
        directories.addAll(entries.map((entry) => entry.directory).whereNotNull());
      }
      directories.forEach((directory) {
        _filterEntryCountMap.remove(directory);
        _filterSizeMap.remove(directory);
        _filterRecentEntryMap.remove(directory);
      });
    }
    if (notify) {
      eventBus.fire(AlbumSummaryInvalidatedEvent(directories));
    }
  }

  int albumEntryCount(AlbumFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter.album, () => visibleEntries.where(filter.test).length);
  }

  int albumSize(AlbumFilter filter) {
    return _filterSizeMap.putIfAbsent(filter.album, () => visibleEntries.where(filter.test).map((v) => v.sizeBytes).sum);
  }

  AvesEntry? albumRecentEntry(AlbumFilter filter) {
    return _filterRecentEntryMap.putIfAbsent(filter.album, () => sortedEntriesByDate.firstWhereOrNull(filter.test));
  }

  // new albums

  void createAlbum(String directory) {
    _newAlbums.add(directory);
    addDirectories(albums: {directory});
  }

  void renameNewAlbum(String source, String destination) {
    if (_newAlbums.remove(source)) {
      cleanEmptyAlbums({source});
      createAlbum(destination);
    }
  }

  void forgetNewAlbums(Set<String> directories) {
    _newAlbums.removeAll(directories);
  }

  // display names

  final Map<String, String> _albumDisplayNamesWithContext = {}, _albumDisplayNamesWithoutContext = {};

  void invalidateAlbumDisplayNames() {
    _albumDisplayNamesWithContext.clear();
    _albumDisplayNamesWithoutContext.clear();
  }

  String _computeDisplayName(BuildContext? context, String dirPath) {
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
        final testName = '$separator$name';
        if (others.every((item) => !item.endsWith(testName))) return name;
      }
      return dirPath;
    }

    final otherAlbumsOnDevice = _directories.whereNotNull().where((item) => item != dirPath).toSet();
    final uniqueNameInDevice = unique(dirPath, otherAlbumsOnDevice);
    if (uniqueNameInDevice.length <= relativeDir.length) {
      return uniqueNameInDevice;
    }

    final volumePath = dir.volumePath;
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

  String getAlbumDisplayName(BuildContext? context, String dirPath) {
    final names = (context != null ? _albumDisplayNamesWithContext : _albumDisplayNamesWithoutContext);
    return names.putIfAbsent(dirPath, () => _computeDisplayName(context, dirPath));
  }
}

class AlbumsChangedEvent {}

class AlbumSummaryInvalidatedEvent {
  final Set<String?>? directories;

  const AlbumSummaryInvalidatedEvent(this.directories);
}
