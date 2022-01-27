import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

mixin AlbumMixin on SourceBase {
  final Set<String?> _directories = {};
  final Set<String> _newAlbums = {};

  List<String> get rawAlbums => List.unmodifiable(_directories);

  Set<AlbumFilter> getNewAlbumFilters(BuildContext context) => Set.unmodifiable(_newAlbums.map((v) => AlbumFilter(v, getAlbumDisplayName(context, v))));

  int compareAlbumsByName(String a, String b) {
    final ua = getAlbumDisplayName(null, a);
    final ub = getAlbumDisplayName(null, b);
    final c = compareAsciiUpperCase(ua, ub);
    if (c != 0) return c;
    final va = androidFileUtils.getStorageVolume(a)?.path ?? '';
    final vb = androidFileUtils.getStorageVolume(b)?.path ?? '';
    return compareAsciiUpperCase(va, vb);
  }

  void _notifyAlbumChange() => eventBus.fire(AlbumsChangedEvent());

  String getAlbumDisplayName(BuildContext? context, String dirPath) {
    final separator = pContext.separator;
    assert(!dirPath.endsWith(separator));

    if (context != null) {
      final type = androidFileUtils.getAlbumType(dirPath);
      if (type == AlbumType.camera) return context.l10n.albumCamera;
      if (type == AlbumType.download) return context.l10n.albumDownload;
      if (type == AlbumType.screenshots) return context.l10n.albumScreenshots;
      if (type == AlbumType.screenRecordings) return context.l10n.albumScreenRecordings;
      if (type == AlbumType.videoCaptures) return context.l10n.albumVideoCaptures;
    }

    final dir = VolumeRelativeDirectory.fromPath(dirPath);
    if (dir == null) return dirPath;

    final relativeDir = dir.relativeDir;
    if (relativeDir.isEmpty) {
      final volume = androidFileUtils.getStorageVolume(dirPath)!;
      return volume.getDescription(context);
    }

    String unique(String dirPath, Set<String?> others) {
      final parts = pContext.split(dirPath);
      for (var i = parts.length - 1; i > 0; i--) {
        final name = pContext.joinAll(['', ...parts.skip(i)]);
        final testName = '$separator$name';
        if (others.every((item) => !item!.endsWith(testName))) return name;
      }
      return dirPath;
    }

    final otherAlbumsOnDevice = _directories.where((item) => item != dirPath).toSet();
    final uniqueNameInDevice = unique(dirPath, otherAlbumsOnDevice);
    if (uniqueNameInDevice.length <= relativeDir.length) {
      return uniqueNameInDevice;
    }

    final volumePath = dir.volumePath;
    String trimVolumePath(String? path) => path!.substring(dir.volumePath.length);
    final otherAlbumsOnVolume = otherAlbumsOnDevice.where((path) => path!.startsWith(volumePath)).map(trimVolumePath).toSet();
    final uniqueNameInVolume = unique(trimVolumePath(dirPath), otherAlbumsOnVolume);
    final volume = androidFileUtils.getStorageVolume(dirPath)!;
    if (volume.isPrimary) {
      return uniqueNameInVolume;
    } else {
      return '$uniqueNameInVolume (${volume.getDescription(context)})';
    }
  }

  Map<String, AvesEntry?> getAlbumEntries() {
    final entries = sortedEntriesByDate;
    final regularAlbums = <String>[], appAlbums = <String>[], specialAlbums = <String>[];
    for (final album in rawAlbums) {
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
    return Map.fromEntries([...specialAlbums, ...appAlbums, ...regularAlbums].map((album) => MapEntry(
          album,
          entries.firstWhereOrNull((entry) => entry.directory == album),
        )));
  }

  void updateDirectories() {
    final visibleDirectories = visibleEntries.map((entry) => entry.directory).toSet();
    addDirectories(visibleDirectories);
    cleanEmptyAlbums();
  }

  void addDirectories(Set<String?> albums) {
    if (!_directories.containsAll(albums)) {
      _directories.addAll(albums);
      _notifyAlbumChange();
    }
  }

  void cleanEmptyAlbums([Set<String?>? albums]) {
    final emptyAlbums = (albums ?? _directories).where((v) => _isEmptyAlbum(v) && !_newAlbums.contains(v)).toSet();
    if (emptyAlbums.isNotEmpty) {
      _directories.removeAll(emptyAlbums);
      _notifyAlbumChange();
      invalidateAlbumFilterSummary(directories: emptyAlbums);

      final bookmarks = settings.drawerAlbumBookmarks;
      final pinnedFilters = settings.pinnedFilters;
      emptyAlbums.forEach((album) {
        bookmarks?.remove(album);
        pinnedFilters.removeWhere((filter) => filter is AlbumFilter && filter.album == album);
      });
      settings.drawerAlbumBookmarks = bookmarks;
      settings.pinnedFilters = pinnedFilters;
    }
  }

  bool _isEmptyAlbum(String? album) => !visibleEntries.any((entry) => entry.directory == album);

  // filter summary

  // by directory
  final Map<String, int> _filterEntryCountMap = {};
  final Map<String, AvesEntry?> _filterRecentEntryMap = {};

  void invalidateAlbumFilterSummary({Set<AvesEntry>? entries, Set<String?>? directories}) {
    if (_filterEntryCountMap.isEmpty && _filterRecentEntryMap.isEmpty) return;

    if (entries == null && directories == null) {
      _filterEntryCountMap.clear();
      _filterRecentEntryMap.clear();
    } else {
      directories ??= {};
      if (entries != null) {
        directories.addAll(entries.map((entry) => entry.directory).whereNotNull());
      }
      directories.forEach((directory) {
        _filterEntryCountMap.remove(directory);
        _filterRecentEntryMap.remove(directory);
      });
    }
    eventBus.fire(AlbumSummaryInvalidatedEvent(directories));
  }

  int albumEntryCount(AlbumFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter.album, () => visibleEntries.where(filter.test).length);
  }

  AvesEntry? albumRecentEntry(AlbumFilter filter) {
    return _filterRecentEntryMap.putIfAbsent(filter.album, () => sortedEntriesByDate.firstWhereOrNull(filter.test));
  }

  void createAlbum(String directory) {
    _newAlbums.add(directory);
    addDirectories({directory});
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
}

class AlbumsChangedEvent {}

class AlbumSummaryInvalidatedEvent {
  final Set<String?>? directories;

  const AlbumSummaryInvalidatedEvent(this.directories);
}
