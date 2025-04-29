import 'dart:convert';

import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/set_or.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

final AlbumGrouping albumGrouping = AlbumGrouping._private();

// group URI: "aves://albums/group?path=/group12/subgroup34"
// stored album URI: "aves://albums/stored?path=/volume/dir/path12"
// dynamic album URI: "aves://albums/dynamic?name=dynalbum12"
class AlbumGrouping with ChangeNotifier {
  static const _host = 'albums';
  static const _storedAlbumPath = '/stored';
  static const _dynamicAlbumPath = '/dynamic';
  static const _nameParamKey = 'name';
  static const _storagePathParamKey = 'path';

  final Map<Uri, Set<Uri>> _groups = {};

  AlbumGrouping._private() {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
  }

  Set<CollectionFilter> listGroupContent(Uri? currentGroupUri) {
    if (currentGroupUri == null) {
      return _groups.entries.where((kv) => FilterGrouping.getParentGroup(kv.key) == currentGroupUri).map((kv) {
        final groupUri = kv.key;
        final childrenUri = kv.value;
        final childrenFilters = childrenUri.map(uriToFilter).nonNulls.toSet();
        return AlbumGroupFilter(groupUri, SetOrFilter(childrenFilters));
      }).toSet();
    }

    final childrenUri = _groups.entries.firstWhereOrNull((kv) => kv.key == currentGroupUri)?.value;
    if (childrenUri != null) {
      return childrenUri.map(uriToFilter).nonNulls.toSet();
    }

    return {};
  }

  CollectionFilter? uriToFilter(Uri uri) {
    if (uri.host != _host) return null;

    switch (uri.path) {
      case FilterGrouping.groupPath:
        return AlbumGroupFilter(uri, SetOrFilter(listGroupContent(uri)));
      case _storedAlbumPath:
        final album = getStoredAlbumPath(uri);
        if (album != null) {
          return StoredAlbumFilter(album, null);
        }
      case _dynamicAlbumPath:
        final name = getDynamicAlbumName(uri);
        if (name != null) {
          return dynamicAlbums.get(name);
        }
      default:
        debugPrint('unhandled path=${uri.path} in uri=$uri');
    }
    return null;
  }

  void _removeFromGroups(Set<Uri> uris) {
    _groups.forEach((_, childrenUris) {
      childrenUris.removeAll(uris);
    });
  }

  void addToGroup(Set<Uri> childrenUris, Uri? destinationGroup) {
    _removeFromGroups(childrenUris);
    if (destinationGroup != null) {
      final children = _groups[destinationGroup] ?? {};
      children.addAll(childrenUris);
      _groups[destinationGroup] = children;
    }
    notifyListeners();
  }

  Uri createGroup(Uri? parentGroupUri, String name) {
    final uri = buildGroupUri(parentGroupUri, name);
    _groups.putIfAbsent(uri, () => {});
    return uri;
  }

  bool exists(Uri groupUri) => _groups.containsKey(groupUri);

  int countContent(Uri? groupUri) {
    int count = 0;
    if (groupUri != null) {
      final childrenUri = _groups[groupUri];
      if (childrenUri != null) {
        childrenUri.map(uriToFilter).nonNulls.forEach((filter) {
          if (filter is AlbumGroupFilter) {
            count += countContent(filter.uri);
          } else {
            count++;
          }
        });
      }
    }
    return count;
  }

  static String? getStoredAlbumPath(Uri uri) => uri.queryParameters[_storagePathParamKey];

  static String? getDynamicAlbumName(Uri uri) => uri.queryParameters[_nameParamKey];

  static Uri buildGroupUri(Uri? parentGroupUri, String name) {
    return FilterGrouping.buildGroupUri(_host, parentGroupUri, name);
  }

  static Uri _buildStoredAlbumUri(String album) {
    return Uri(
      scheme: FilterGrouping.scheme,
      host: _host,
      path: _storedAlbumPath,
      queryParameters: {
        _storagePathParamKey: album,
      },
    );
  }

  static Uri _buildDynamicAlbumUri(String name) {
    return Uri(
      scheme: FilterGrouping.scheme,
      host: _host,
      path: _dynamicAlbumPath,
      queryParameters: {
        _nameParamKey: name,
      },
    );
  }

  static Uri? filterToUri(CollectionFilter filter) {
    switch (filter) {
      case StoredAlbumFilter():
        return _buildStoredAlbumUri(filter.album);
      case DynamicAlbumFilter():
        return _buildDynamicAlbumUri(filter.name);
      case AlbumGroupFilter():
        return filter.uri;
      default:
        return null;
    }
  }

  // serialization

  static String toJson(Map<Uri, Set<Uri>> groups) => jsonEncode(groups.map((parentUri, childrenUris) {
        return MapEntry(parentUri.toString(), childrenUris.map((v) => v.toString()));
      }));

  static Map<Uri, Set<Uri>>? fromJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;

    final jsonMap = jsonDecode(jsonString);
    if (jsonMap is! Map) return null;

    return jsonMap.map((parent, children) {
      final Uri? parentUri = parent is String ? Uri.tryParse(parent) : null;
      final Set<Uri> childrenUris = children is Iterable ? children.whereType<String>().map(Uri.tryParse).nonNulls.toSet() : {};
      return MapEntry(parentUri, childrenUris);
    }).whereNotNullKey();
  }
}
