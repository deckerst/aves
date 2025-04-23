import 'dart:convert';

import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/set_or.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:flutter/foundation.dart';

final AlbumGrouping albumGrouping = AlbumGrouping._private();

// group URI: "aves://albums/group?path=/group12/subgroup34"
// stored album URI: "aves://albums/stored?path=/volume/dir/path12"
// dynamic album URI: "aves://albums/dynamic?name=dynalbum12"
class AlbumGrouping with ChangeNotifier {
  static const _scheme = 'aves';
  static const _host = 'albums';
  static const _groupPath = '/group';
  static const _storedAlbumPath = '/stored';
  static const _dynamicAlbumPath = '/dynamic';
  static const _pathParamKey = 'path';
  static const _nameParamKey = 'name';

  final Map<Uri, Set<Uri>> _groups = {};

  AlbumGrouping._private() {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
  }

  Set<AlbumGroupFilter> list(Uri? currentGroupUri) {
    return _groups.entries.where((kv) => _getParentGroup(kv.key) == currentGroupUri).map((kv) {
      final groupUri = kv.key;
      final childrenUri = kv.value;
      final childrenFilters = childrenUri.map(uriToFilter).nonNulls.toSet();
      return AlbumGroupFilter(groupUri, SetOrFilter(childrenFilters));
    }).toSet();
  }

  CollectionFilter? uriToFilter(Uri uri) {
    switch (uri.path) {
      case _groupPath:
        return AlbumGroupFilter(uri, SetOrFilter(list(uri)));
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

  void ungroup(Set<Uri> uris) {
    _groups.forEach((_, childrenUris) {
      childrenUris.removeAll(uris);
    });
  }

  void group(Set<Uri> childrenUris, Uri destinationGroup) {
    ungroup(childrenUris);
    final children = _groups[destinationGroup] ?? {};
    children.addAll(childrenUris);
    _groups[destinationGroup] = children;
    notifyListeners();
  }

  Uri createGroup(Uri? parentGroupUri, String name) {
    final uri = buildGroupUri(parentGroupUri, name);
    _groups.putIfAbsent(uri, () => {});
    return uri;
  }

  static String? getGroupPath(Uri uri) => uri.queryParameters[_pathParamKey];

  static String? getStoredAlbumPath(Uri uri) => uri.queryParameters[_pathParamKey];

  static String? getDynamicAlbumName(Uri uri) => uri.queryParameters[_nameParamKey];

  // parent group URI is `null` for root
  static Uri buildGroupUri(Uri? parentGroupUri, String name) {
    if (parentGroupUri != null) {
      final path = getGroupPath(parentGroupUri);
      if (path != null) {
        return parentGroupUri.replace(
          queryParameters: {
            _pathParamKey: pContext.join(path, name),
          },
        );
      }
    }
    return Uri(
      scheme: _scheme,
      host: _host,
      path: _groupPath,
      queryParameters: {
        _pathParamKey: name,
      },
    );
  }

  static Uri _buildStoredAlbumUri(String album) {
    return Uri(
      scheme: _scheme,
      host: _host,
      path: _storedAlbumPath,
      queryParameters: {
        _pathParamKey: album,
      },
    );
  }

  static Uri _buildDynamicAlbumUri(String name) {
    return Uri(
      scheme: _scheme,
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

  // return `null` for root
  static Uri? _getParentGroup(Uri groupUri) {
    final path = getGroupPath(groupUri);
    if (path != null) {
      final segments = pContext.split(path);
      final newLength = segments.length - 1;
      if (newLength > 0) {
        return groupUri.replace(
          queryParameters: {
            _pathParamKey: pContext.joinAll(segments.take(newLength)),
          },
        );
      }
    }
    return null;
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
