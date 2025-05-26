import 'dart:async';
import 'dart:convert';

import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/group_base.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/convert.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

final FilterGrouping albumGrouping = FilterGrouping._private(FilterGrouping.hostAlbums, AlbumGroupFilter.new);

// album group URI: "aves://albums/group?path=/group12/subgroup34"
// stored album URI: "aves://albums/stored?path=/volume/dir/path12"
// dynamic album URI: "aves://albums/dynamic?name=dynalbum12"
class FilterGrouping<T extends GroupBaseFilter> with ChangeNotifier {
  static const scheme = 'aves';
  static const hostAlbums = 'albums';

  static const _groupPath = '/group';
  static const _groupPathParamKey = 'path';

  final EventBus eventBus = EventBus();

  final String _host;
  final T Function(Uri uri, SetOrFilter filter) _createGroupFilter;
  final Map<Uri, Set<Uri>> _groups = {};
  final Set<StreamSubscription> _subscriptions = {};
  final Map<CollectionSource, Set<StreamSubscription>> _sourceSubscriptions = {};
  CollectionSource? _source;

  Map<Uri, Set<Uri>> get allGroups => Map.unmodifiable(_groups);

  // do not subscribe to events from other modules in constructor
  // so that modules can subscribe to each other
  FilterGrouping._private(this._host, this._createGroupFilter) {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);
  }

  void init() {
    _subscriptions.add(dynamicAlbums.eventBus.on<DynamicAlbumChangedEvent>().listen((e) => _clearObsoleteFilters()));
  }

  void setGroups(Map<Uri, Set<Uri>> groups) {
    _groups.clear();
    _groups.addAll(groups);
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _sourceSubscriptions.keys.toSet().forEach(unregisterSource);
    super.dispose();
  }

  void registerSource(CollectionSource source) {
    unregisterSource(_source);
    final sourceEvents = source.eventBus;
    _sourceSubscriptions[source] = {
      sourceEvents.on<EntryMovedEvent>().listen((e) => _clearObsoleteFilters()),
      sourceEvents.on<EntryRemovedEvent>().listen((e) => _clearObsoleteFilters()),
      sourceEvents.on<AlbumsChangedEvent>().listen((e) => _clearObsoleteFilters()),
    };
    _source = source;
  }

  void unregisterSource(CollectionSource? source) {
    _sourceSubscriptions.remove(source)
      ?..forEach((sub) => sub.cancel())
      ..clear();
  }

  void addToGroup(Set<Uri> childrenUris, Uri? destinationGroup) {
    _removeFromGroups(childrenUris);
    if (destinationGroup != null) {
      _ensureGroupFromRoot(destinationGroup);
      final children = _groups[destinationGroup] ?? {};
      children.addAll(childrenUris);
      _groups[destinationGroup] = children;
    }
    _reparentGroupPaths(childrenUris, destinationGroup);
    _cleanEmptyGroups();
    notifyListeners();
  }

  void rename(Uri oldUri, Uri newUri) {
    final childrenUris = _groups[oldUri];
    if (childrenUris == null) return;

    // local copy to prevent concurrent modification
    addToGroup(Set.of(childrenUris), newUri);
    eventBus.fire(GroupUriChangedEvent(oldUri, newUri));
  }

  bool get isNotEmpty => _groups.isNotEmpty;

  bool exists(Uri? groupUri) => _groups.containsKey(groupUri);

  Set<Uri> getGroups() => _groups.keys.toSet();

  // returns number of filters within provided group, following subgroups without counting them
  // providing the null root will yield 0, rather than the total number of filters in the collection (which is out of scope)
  int countLeaves(Uri? groupUri) {
    int count = 0;
    if (groupUri != null) {
      final childrenUris = _groups[groupUri];
      if (childrenUris != null) {
        childrenUris.map(uriToFilter).nonNulls.forEach((filter) {
          if (filter is GroupBaseFilter) {
            count += countLeaves(filter.uri);
          } else {
            count++;
          }
        });
      }
    }
    return count;
  }

  // returns filters directly within the provided group, including subgroups as filters
  // providing the null root will yield its direct group filters
  Set<CollectionFilter> getDirectChildren(Uri? currentGroupUri) {
    if (currentGroupUri == null) {
      return _groups.entries.where((kv) => getParentGroup(kv.key) == currentGroupUri).map((kv) {
        final groupUri = kv.key;
        final childrenUris = kv.value;
        final childrenFilters = childrenUris.map(uriToFilter).nonNulls.toSet();
        return _createGroupFilter(groupUri, SetOrFilter(childrenFilters));
      }).toSet();
    }

    final childrenUris = _groups.entries.firstWhereOrNull((kv) => kv.key == currentGroupUri)?.value;
    if (childrenUris != null) {
      return childrenUris.map(uriToFilter).nonNulls.toSet();
    }

    return {};
  }

  Uri buildGroupUri(Uri? parentGroupUri, String name) {
    return _buildGroupUri(_host, parentGroupUri, name);
  }

  CollectionFilter? uriToFilter(Uri? uri) {
    if (uri == null || uri.host != _host) return null;

    if (FilterGrouping.isGroupUri(uri)) {
      return _createGroupFilter(uri, SetOrFilter(getDirectChildren(uri)));
    }

    return GroupingConversion.uriToFilter(uri);
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

  void _reparentGroupPaths(Set<Uri> childrenUris, Uri? parentGroupUri) {
    final groupUris = childrenUris.where(FilterGrouping.isGroupUri).toSet();
    groupUris.forEach((oldGroupUri) {
      final name = FilterGrouping.getGroupName(oldGroupUri);
      if (name != null) {
        final groupChildrenUris = _groups.remove(oldGroupUri);
        if (groupChildrenUris != null) {
          // create child group with updated URI
          final newGroupUri = buildGroupUri(parentGroupUri, name);
          _groups[newGroupUri] = groupChildrenUris;

          // update child group URI in parent group itself
          if (parentGroupUri != null) {
            final children = _groups[parentGroupUri];
            if (children != null && children.remove(oldGroupUri)) {
              children.add(newGroupUri);
            }
          }

          eventBus.fire(GroupUriChangedEvent(oldGroupUri, newGroupUri));
          _reparentGroupPaths(groupChildrenUris, newGroupUri);
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

  void _clearObsoleteFilters() {
    final source = _source;
    if (source == null || source.targetScope != CollectionSource.fullScope || !source.isReady) return;

    _groups.entries.forEach((kv) {
      final groupUri = kv.key;
      final childrenUris = kv.value;

      final rawAlbums = source.rawAlbums;
      final allEntries = source.allEntries;

      childrenUris.toSet().forEach((childUri) {
        final filter = uriToFilter(childUri);
        var valid = false;
        if (filter != null) {
          switch (filter) {
            case GroupBaseFilter _:
              valid = true;
            case StoredAlbumFilter _:
              // check album itself
              final isVisibleAlbum = rawAlbums.contains(filter.album);
              if (isVisibleAlbum) {
                valid = true;
              } else {
                // check non-visible content (hidden, trash, etc.)
                valid = allEntries.any(filter.test);
              }
            case DynamicAlbumFilter _:
              valid = dynamicAlbums.contains(filter.name);
          }
        }
        if (!valid) {
          childrenUris.remove(childUri);
          debugPrint('Removed obsolete childUri=$childUri from group=$groupUri');
        }
      });
    });
    _cleanEmptyGroups();
  }

  // group uri / filter conversion

  static String? getGroupPath(Uri? uri) => uri?.queryParameters[_groupPathParamKey];

  static String? getGroupName(Uri? uri) {
    final path = getGroupPath(uri);
    return path != null ? pContext.split(path).lastOrNull : null;
  }

  static bool isGroupUri(Uri uri) => uri.path == FilterGrouping._groupPath;

  // parent group URI is `null` for root
  static Uri _buildGroupUri(String host, Uri? parentGroupUri, String name) {
    if (parentGroupUri != null) {
      final path = getGroupPath(parentGroupUri);
      if (path != null) {
        return parentGroupUri.replace(
          queryParameters: {
            _groupPathParamKey: pContext.join(path, name),
          },
        );
      }
    }
    return Uri(
      scheme: scheme,
      host: host,
      path: _groupPath,
      queryParameters: {
        _groupPathParamKey: name,
      },
    );
  }

  // returns `null` for root
  Uri? getFilterParent(CollectionFilter filter) {
    final uri = GroupingConversion.filterToUri(filter);
    if (uri == null) return null;

    if (isGroupUri(uri)) {
      return getParentGroup(uri);
    } else {
      return _groups.entries.firstWhereOrNull((kv) {
        return kv.value.contains(uri);
      })?.key;
    }
  }

  // returns `null` for root
  static Uri? getParentGroup(Uri? groupUri) {
    if (groupUri == null) return null;

    final path = getGroupPath(groupUri);
    if (path != null) {
      final segments = pContext.split(path);
      final newLength = segments.length - 1;
      if (newLength > 0) {
        return groupUri.replace(
          queryParameters: {
            _groupPathParamKey: pContext.joinAll(segments.take(newLength)),
          },
        );
      }
    }
    return null;
  }

  static FilterGrouping? forUri(Uri uri) {
    switch (uri.host) {
      case hostAlbums:
        return albumGrouping;
      default:
        return null;
    }
  }

  // serialization

  static String toJson(Map<Uri, Set<Uri>> groups) => jsonEncode(groups.map((parentUri, childrenUris) {
        return MapEntry(parentUri.toString(), childrenUris.map((v) => v.toString()).toList());
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

@immutable
class GroupUriChangedEvent {
  final Uri oldGroupUri;
  final Uri newGroupUri;

  const GroupUriChangedEvent(this.oldGroupUri, this.newGroupUri);
}
