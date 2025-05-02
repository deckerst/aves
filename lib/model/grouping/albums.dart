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

  // returns filters directly within the provided group, including subgroups as filters
  // providing the null root will yield its direct group filters
  Set<CollectionFilter> getDirectChildren(Uri? currentGroupUri) {
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

  CollectionFilter? uriToFilter(Uri? uri) {
    if (uri == null || uri.host != _host) return null;

    if (FilterGrouping.isGroupUri(uri)) {
      return AlbumGroupFilter(uri, SetOrFilter(getDirectChildren(uri)));
    }

    switch (uri.path) {
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

  void _cleanEmptyGroups() {
    final emptyGroupUris = _groups.entries.where((kv) => kv.value.isEmpty).map((v) => v.key).toSet();
    if (emptyGroupUris.isNotEmpty) {
      _removeFromGroups(emptyGroupUris);
      _groups.removeWhere((groupUri, _) => emptyGroupUris.contains(groupUri));
      _cleanEmptyGroups();
    }
  }

  void _reparentGroupPaths(Uri? parentGroupUri, Set<Uri> childrenUris) {
    final groupUris = childrenUris.where(FilterGrouping.isGroupUri).toSet();
    groupUris.forEach((groupUri) {
      final name = FilterGrouping.getGroupName(groupUri);
      if (name != null) {
        final groupChildrenUris = _groups.remove(groupUri);
        if (groupChildrenUris != null) {
          final newGroupUri = buildGroupUri(parentGroupUri, name);
          _groups[newGroupUri] = groupChildrenUris;
          _reparentGroupPaths(newGroupUri, groupChildrenUris);
        }
      }
    });
  }

  void _ensureGroupFromRoot(Uri groupUri) {
    final parentGroupUri = FilterGrouping.getParentGroup(groupUri);
    if (parentGroupUri != null) {
      final children = _groups[parentGroupUri] ?? {};
      children.addAll({groupUri});
      _groups[parentGroupUri] = children;
      _ensureGroupFromRoot(parentGroupUri);
    }
  }

  void addToGroup(Set<Uri> childrenUris, Uri? destinationGroup) {
    _removeFromGroups(childrenUris);
    if (destinationGroup != null) {
      _ensureGroupFromRoot(destinationGroup);
      final children = _groups[destinationGroup] ?? {};
      children.addAll(childrenUris);
      _groups[destinationGroup] = children;
    }
    _reparentGroupPaths(destinationGroup, childrenUris);
    _cleanEmptyGroups();
    notifyListeners();
  }

  bool exists(Uri? groupUri) => _groups.containsKey(groupUri);

  // returns number of filters within provided group, following subgroups without counting them
  // providing the null root will yield 0, rather than the total number of filters in the collection (which is out of scope)
  int countLeaves(Uri? groupUri) {
    int count = 0;
    if (groupUri != null) {
      final childrenUri = _groups[groupUri];
      if (childrenUri != null) {
        childrenUri.map(uriToFilter).nonNulls.forEach((filter) {
          if (filter is AlbumGroupFilter) {
            count += countLeaves(filter.uri);
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
