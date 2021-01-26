import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';

mixin AlbumMixin on SourceBase {
  final Set<String> _folderPaths = {};

  List<String> sortedAlbums = List.unmodifiable([]);

  int compareAlbumsByName(String a, String b) {
    final ua = getUniqueAlbumName(a);
    final ub = getUniqueAlbumName(b);
    final c = compareAsciiUpperCase(ua, ub);
    if (c != 0) return c;
    final va = androidFileUtils.getStorageVolume(a)?.path ?? '';
    final vb = androidFileUtils.getStorageVolume(b)?.path ?? '';
    return compareAsciiUpperCase(va, vb);
  }

  void updateAlbums() {
    final sorted = _folderPaths.toList()..sort(compareAlbumsByName);
    sortedAlbums = List.unmodifiable(sorted);
    invalidateFilterEntryCounts();
    eventBus.fire(AlbumsChangedEvent());
  }

  String getUniqueAlbumName(String album) {
    final otherAlbums = _folderPaths.where((item) => item != album);
    final parts = album.split(separator);
    var partCount = 0;
    String testName;
    do {
      testName = separator + parts.skip(parts.length - ++partCount).join(separator);
    } while (otherAlbums.any((item) => item.endsWith(testName)));
    final uniqueName = parts.skip(parts.length - partCount).join(separator);

    final volume = androidFileUtils.getStorageVolume(album);
    final volumeRoot = volume?.path ?? '';
    final albumRelativePath = album.substring(volumeRoot.length);
    if (uniqueName.length < albumRelativePath.length || volume == null) {
      return uniqueName;
    } else if (volume.isPrimary) {
      return albumRelativePath;
    } else {
      return '$albumRelativePath (${volume.description})';
    }
  }

  Map<String, AvesEntry> getAlbumEntries() {
    final entries = sortedEntriesForFilterList;
    final regularAlbums = <String>[], appAlbums = <String>[], specialAlbums = <String>[];
    for (final album in sortedAlbums) {
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
          entries.firstWhere((entry) => entry.directory == album, orElse: () => null),
        )));
  }

  void addFolderPath(Iterable<String> albums) => _folderPaths.addAll(albums);

  void cleanEmptyAlbums([Set<String> albums]) {
    final emptyAlbums = (albums ?? _folderPaths).where(_isEmptyAlbum).toList();
    if (emptyAlbums.isNotEmpty) {
      _folderPaths.removeAll(emptyAlbums);
      updateAlbums();

      final pinnedFilters = settings.pinnedFilters;
      emptyAlbums.forEach((album) => pinnedFilters.remove(AlbumFilter(album, getUniqueAlbumName(album))));
      settings.pinnedFilters = pinnedFilters;
    }
  }

  bool _isEmptyAlbum(String album) => !rawEntries.any((entry) => entry.directory == album);
}

class AlbumsChangedEvent {}
