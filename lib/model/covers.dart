import 'dart:async';

import 'package:aves/model/app_inventory.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/tag_group.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:synchronized/synchronized.dart';

final Covers covers = Covers._private();

class Covers {
  final Set<StreamSubscription> _subscriptions = {};
  final _lock = Lock();

  final StreamController<Set<CollectionFilter>?> _entryChangeStreamController = StreamController.broadcast();
  final StreamController<Set<CollectionFilter>?> _packageChangeStreamController = StreamController.broadcast();
  final StreamController<Set<CollectionFilter>?> _colorChangeStreamController = StreamController.broadcast();

  Stream<Set<CollectionFilter>?> get entryChangeStream => _entryChangeStreamController.stream;

  Stream<Set<CollectionFilter>?> get packageChangeStream => _packageChangeStreamController.stream;

  Stream<Set<CollectionFilter>?> get colorChangeStream => _colorChangeStreamController.stream;

  Set<CoverRow> _rows = {};

  final Map<String, AlbumType> _effectiveAlbumTypeCache = {};
  final Map<String, String?> _effectiveAlbumPackageCache = {};

  // do not subscribe to events from other modules in constructor
  // so that modules can subscribe to each other
  Covers._private();

  Future<void> init() async {
    _rows = await localMediaDb.loadAllCovers();
    _subscriptions.add(dynamicAlbums.eventBus.on<DynamicAlbumChangedEvent>().listen((e) => _updateCoveredDynamicAlbums(e.changes)));
    _subscriptions.add(albumGrouping.eventBus.on<GroupUriChangedEvent>().listen((e) => _updateCoveredGroup(e.oldGroupUri, e.newGroupUri)));
    _subscriptions.add(tagGrouping.eventBus.on<GroupUriChangedEvent>().listen((e) => _updateCoveredGroup(e.oldGroupUri, e.newGroupUri)));

    androidFileUtils.albumTypesChangeNotifier.addListener(_invalidateEffectiveAlbumPropCache);
    appInventory.areAppNamesReadyNotifier.addListener(_invalidateEffectiveAlbumPropCache);
    vaults.lockStateChangeNotifier.addListener(_invalidateEffectiveAlbumPropCache);
    _invalidateEffectiveAlbumPropCache();
  }

  int get count => _rows.length;

  Set<CoverRow> get all => Set.unmodifiable(_rows);

  CoverProps? of(CollectionFilter filter) {
    if (filter is StoredAlbumFilter && vaults.isLocked(filter.album)) return null;

    final row = _rows.firstWhereOrNull((row) => row.filter == filter);
    return row?.coverProps;
  }

  Future<CoverProps?> remove(CollectionFilter filter, {bool notify = true}) async {
    final props = of(filter);
    if (props != null) {
      await set(filter: filter, entryId: null, packageName: null, color: null);

      if (notify) {
        if (props.entryId != null) _entryChangeStreamController.add({filter});
        if (props.packageName != null) _packageChangeStreamController.add({filter});
        if (props.color != null) _colorChangeStreamController.add({filter});
      }
    }
    return props;
  }

  Future<void> removeAll(Set<CollectionFilter> filters, {bool notify = true}) async {
    final entryIdChanged = <CollectionFilter>{};
    final packageNameChanged = <CollectionFilter>{};
    final colorChanged = <CollectionFilter>{};

    for (final filter in filters) {
      final props = await remove(filter, notify: false);
      if (notify && props != null) {
        if (props.entryId != null) entryIdChanged.add(filter);
        if (props.packageName != null) packageNameChanged.add(filter);
        if (props.color != null) colorChanged.add(filter);
      }
    }

    if (notify) {
      if (entryIdChanged.isNotEmpty) _entryChangeStreamController.add(entryIdChanged);
      if (packageNameChanged.isNotEmpty) _packageChangeStreamController.add(packageNameChanged);
      if (colorChanged.isNotEmpty) _colorChangeStreamController.add(colorChanged);
    }
  }

  Future<void> set({
    required CollectionFilter filter,
    required int? entryId,
    required String? packageName,
    required Color? color,
    bool notify = true,
  }) async {
    // erase contextual properties from filters before saving them
    switch (filter) {
      case StoredAlbumFilter _:
        filter = StoredAlbumFilter(filter.album, null);
      case AlbumGroupFilter _:
        filter = AlbumGroupFilter.empty(filter.uri);
      case TagGroupFilter _:
        filter = TagGroupFilter.empty(filter.uri);
    }

    final oldRows = _rows.where((row) => row.filter == filter).toSet();
    _rows.removeAll(oldRows);
    await localMediaDb.removeCovers({filter});

    final oldCoverProps = oldRows.firstOrNull?.coverProps;
    final oldEntry = oldCoverProps?.entryId;
    final oldPackage = oldCoverProps?.packageName;
    final oldColor = oldCoverProps?.color;

    if (entryId != null || packageName != null || color != null) {
      final row = CoverRow(
        filter: filter,
        coverProps: CoverProps(
          entryId,
          packageName,
          color,
        ),
      );
      _rows.add(row);
      await localMediaDb.addCovers({row});
    }

    _invalidateEffectiveAlbumPropCache();
    if (notify) {
      if (oldEntry != entryId) _entryChangeStreamController.add({filter});
      if (oldPackage != packageName) _packageChangeStreamController.add({filter});
      if (oldColor != color) _colorChangeStreamController.add({filter});
    }
  }

  Future<void> _removeEntryFromRows(Set<CoverRow> rows) {
    return Future.forEach<CoverRow>(
      rows,
      (row) => set(
        filter: row.filter,
        entryId: null,
        packageName: row.coverProps.packageName,
        color: row.coverProps.color,
      ),
    );
  }

  Future<void> moveEntry(AvesEntry entry) async {
    final entryId = entry.id;
    await _removeEntryFromRows(_rows.where((row) => row.coverProps.entryId == entryId && !row.filter.test(entry)).toSet());
  }

  Future<void> removeIds(Set<int> entryIds) async {
    await _removeEntryFromRows(_rows.where((row) => entryIds.contains(row.coverProps.entryId)).toSet());
  }

  Future<void> clear() async {
    await localMediaDb.clearCovers();
    _rows.clear();

    _invalidateEffectiveAlbumPropCache();
    _entryChangeStreamController.add(null);
    _packageChangeStreamController.add(null);
    _colorChangeStreamController.add(null);
  }

  void _invalidateEffectiveAlbumPropCache() {
    _effectiveAlbumTypeCache.clear();
    _effectiveAlbumPackageCache.clear();
  }

  AlbumType effectiveAlbumType(String albumPath) {
    return _effectiveAlbumTypeCache.putIfAbsent(albumPath, () {
      final filterPackage = of(StoredAlbumFilter(albumPath, null))?.packageName;
      if (filterPackage != null) {
        return filterPackage.isEmpty ? AlbumType.regular : AlbumType.app;
      } else {
        return androidFileUtils.getAlbumType(albumPath);
      }
    });
  }

  String? effectiveAlbumPackage(String albumPath) {
    return _effectiveAlbumPackageCache.putIfAbsent(albumPath, () {
      final filterPackage = of(StoredAlbumFilter(albumPath, null))?.packageName;
      return filterPackage ?? appInventory.getAlbumAppPackageName(albumPath);
    });
  }

  Future<void> _updateCoveredDynamicAlbums(Map<DynamicAlbumFilter, DynamicAlbumFilter?> changes) async {
    await _lock.synchronized(() async {
      await Future.forEach(changes.entries, (kv) async {
        final oldFilter = kv.key;
        final newFilter = kv.value;

        final cover = await covers.remove(oldFilter, notify: false);
        if (cover != null && newFilter != null) {
          await covers.set(
            filter: newFilter,
            entryId: cover.entryId,
            packageName: cover.packageName,
            color: cover.color,
            notify: true,
          );
        }
      });
    });
  }

  Future<void> _updateCoveredGroup(Uri oldGroupUri, Uri newGroupUri) async {
    await _lock.synchronized(() async {
      final grouping = FilterGrouping.forUri(oldGroupUri);
      if (grouping != null) {
        final oldFilter = grouping.uriToFilter(oldGroupUri);
        final newFilter = grouping.uriToFilter(newGroupUri);

        if (oldFilter != null) {
          final cover = await covers.remove(oldFilter, notify: false);
          if (cover != null && newFilter != null) {
            await covers.set(
              filter: newFilter,
              entryId: cover.entryId,
              packageName: cover.packageName,
              color: cover.color,
              notify: true,
            );
          }
        }
      }
    });
  }

  // import/export

  List<Map<String, Object?>>? export(CollectionSource source) {
    final visibleEntries = source.visibleEntries;
    final jsonList = all
        .map((row) {
          final cover = row.coverProps;
          final entryId = cover.entryId;
          final path = visibleEntries.firstWhereOrNull((entry) => entryId == entry.id)?.path;
          final volume = androidFileUtils.getStorageVolume(path)?.path;
          final relativePath = volume != null ? path?.substring(volume.length) : null;
          final packageName = cover.packageName;
          final colorJson = cover.color?.toJsonMap();

          return {
            'filter': row.filter.toJsonMap(),
            'volume': ?volume,
            'relativePath': ?relativePath,
            'packageName': ?packageName,
            'color': ?colorJson,
          };
        })
        .nonNulls
        .toList();
    return jsonList.isNotEmpty ? jsonList : null;
  }

  void import(Object jsonList, CollectionSource source) {
    if (jsonList is! List) {
      debugPrint('failed to import covers for jsonMap=$jsonList');
      return;
    }

    final visibleEntries = source.visibleEntries;
    jsonList.cast<Map<String, Object?>>().forEach((row) {
      try {
        final filter = CollectionFilter.fromJson(row['filter']);
        if (filter == null) {
          debugPrint('failed to import cover for row=$row');
          return;
        }

        final volume = row['volume'] as String?;
        final relativePath = row['relativePath'] as String?;
        final packageName = row['packageName'] as String?;
        final color = row['color'];
        // for backward compatibility, color used to be an `int`, now a `string`
        final colorJson = color is String ? color : null;

        AvesEntry? entry;
        if (volume != null && relativePath != null) {
          final path = pContext.join(volume, relativePath);
          entry = visibleEntries.firstWhereOrNull((entry) => entry.path == path && filter.test(entry));
          if (entry == null) {
            debugPrint('failed to import cover entry for path=$path, filter=$filter');
          }
        }

        if (entry != null || packageName != null || colorJson != null) {
          set(
            filter: filter,
            entryId: entry?.id,
            packageName: packageName,
            color: ExtraColor.fromJson(colorJson),
          );
        }
      } catch (error, stack) {
        debugPrint('failed to import cover for row=$row with error=$error\n$stack');
      }
    });
  }
}

@immutable
class CoverProps extends Equatable {
  final int? entryId;
  final String? packageName;
  final Color? color;

  @override
  List<Object?> get props => [entryId, packageName, color];

  const CoverProps(this.entryId, this.packageName, this.color);
}

@immutable
class CoverRow extends Equatable {
  final CollectionFilter filter;
  final CoverProps coverProps;

  @override
  List<Object?> get props => [filter, coverProps];

  const CoverRow({
    required this.filter,
    required this.coverProps,
  });

  static CoverRow? fromMap(Map map) {
    final filter = CollectionFilter.fromJson(map['filter']);
    if (filter == null) return null;

    return CoverRow(
      filter: filter,
      coverProps: CoverProps(
        map['entryId'] as int?,
        map['packageName'] as String?,
        ExtraColor.fromJson(map['color']),
      ),
    );
  }

  Map<String, Object?> toMap() => {
    'filter': filter.toJsonMap(),
    'entryId': coverProps.entryId,
    'packageName': coverProps.packageName,
    'color': coverProps.color?.toJsonMap(),
  };

  Map<String, Object?> toDbMap() => {
    'filter': filter.toJsonString(),
    'entryId': coverProps.entryId,
    'packageName': coverProps.packageName,
    'color': coverProps.color?.toJsonString(),
  };
}
