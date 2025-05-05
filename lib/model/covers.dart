import 'dart:async';

import 'package:aves/model/app_inventory.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
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

final Covers covers = Covers._private();

typedef CoverProps = (int? entryId, String? packageName, Color? color);

class Covers {
  final StreamController<Set<CollectionFilter>?> _entryChangeStreamController = StreamController.broadcast();
  final StreamController<Set<CollectionFilter>?> _packageChangeStreamController = StreamController.broadcast();
  final StreamController<Set<CollectionFilter>?> _colorChangeStreamController = StreamController.broadcast();

  Stream<Set<CollectionFilter>?> get entryChangeStream => _entryChangeStreamController.stream;

  Stream<Set<CollectionFilter>?> get packageChangeStream => _packageChangeStreamController.stream;

  Stream<Set<CollectionFilter>?> get colorChangeStream => _colorChangeStreamController.stream;

  Set<CoverRow> _rows = {};

  Covers._private();

  Future<void> init() async {
    _rows = await localMediaDb.loadAllCovers();
  }

  int get count => _rows.length;

  Set<CoverRow> get all => Set.unmodifiable(_rows);

  CoverProps? of(CollectionFilter filter) {
    if (filter is StoredAlbumFilter && vaults.isLocked(filter.album)) return null;

    final row = _rows.firstWhereOrNull((row) => row.filter == filter);
    return row != null ? (row.entryId, row.packageName, row.color) : null;
  }

  Future<CoverProps?> remove(CollectionFilter filter, {bool notify = true}) async {
    final props = of(filter);
    if (props != null) {
      await set(filter: filter, entryId: null, packageName: null, color: null);

      if (notify) {
        final (entryId, packageName, color) = props;
        if (entryId != null) _entryChangeStreamController.add({filter});
        if (packageName != null) _packageChangeStreamController.add({filter});
        if (color != null) _colorChangeStreamController.add({filter});
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
        final (entryId, packageName, color) = props;
        if (entryId != null) entryIdChanged.add(filter);
        if (packageName != null) packageNameChanged.add(filter);
        if (color != null) colorChanged.add(filter);
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
    }

    final oldRows = _rows.where((row) => row.filter == filter).toSet();
    _rows.removeAll(oldRows);
    await localMediaDb.removeCovers({filter});

    final oldRow = oldRows.firstOrNull;
    final oldEntry = oldRow?.entryId;
    final oldPackage = oldRow?.packageName;
    final oldColor = oldRow?.color;

    if (entryId != null || packageName != null || color != null) {
      final row = CoverRow(
        filter: filter,
        entryId: entryId,
        packageName: packageName,
        color: color,
      );
      _rows.add(row);
      await localMediaDb.addCovers({row});
    }

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
              packageName: row.packageName,
              color: row.color,
            ));
  }

  Future<void> moveEntry(AvesEntry entry) async {
    final entryId = entry.id;
    await _removeEntryFromRows(_rows.where((row) => row.entryId == entryId && !row.filter.test(entry)).toSet());
  }

  Future<void> removeIds(Set<int> entryIds) async {
    await _removeEntryFromRows(_rows.where((row) => entryIds.contains(row.entryId)).toSet());
  }

  Future<void> clear() async {
    await localMediaDb.clearCovers();
    _rows.clear();

    _entryChangeStreamController.add(null);
    _packageChangeStreamController.add(null);
    _colorChangeStreamController.add(null);
  }

  AlbumType effectiveAlbumType(String albumPath) {
    final filterPackage = of(StoredAlbumFilter(albumPath, null))?.$2;
    if (filterPackage != null) {
      return filterPackage.isEmpty ? AlbumType.regular : AlbumType.app;
    } else {
      return androidFileUtils.getAlbumType(albumPath);
    }
  }

  String? effectiveAlbumPackage(String albumPath) {
    final filterPackage = of(StoredAlbumFilter(albumPath, null))?.$2;
    return filterPackage ?? appInventory.getAlbumAppPackageName(albumPath);
  }

  // import/export

  List<Map<String, dynamic>>? export(CollectionSource source) {
    final visibleEntries = source.visibleEntries;
    final jsonList = all
        .map((row) {
          final entryId = row.entryId;
          final path = visibleEntries.firstWhereOrNull((entry) => entryId == entry.id)?.path;
          final volume = androidFileUtils.getStorageVolume(path)?.path;
          final relativePath = volume != null ? path?.substring(volume.length) : null;
          final packageName = row.packageName;
          final colorJson = row.color?.toJson();

          return {
            'filter': row.filter.toJson(),
            if (volume != null) 'volume': volume,
            if (relativePath != null) 'relativePath': relativePath,
            if (packageName != null) 'packageName': packageName,
            if (colorJson != null) 'color': colorJson,
          };
        })
        .nonNulls
        .toList();
    return jsonList.isNotEmpty ? jsonList : null;
  }

  void import(dynamic jsonList, CollectionSource source) {
    if (jsonList is! List) {
      debugPrint('failed to import covers for jsonMap=$jsonList');
      return;
    }

    final visibleEntries = source.visibleEntries;
    jsonList.forEach((row) {
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
class CoverRow extends Equatable {
  final CollectionFilter filter;
  final int? entryId;
  final String? packageName;
  final Color? color;

  @override
  List<Object?> get props => [filter, entryId, packageName, color];

  const CoverRow({
    required this.filter,
    required this.entryId,
    required this.packageName,
    required this.color,
  });

  static CoverRow? fromMap(Map map) {
    final filter = CollectionFilter.fromJson(map['filter']);
    if (filter == null) return null;

    final entryId = map['entryId'] as int?;
    final packageName = map['packageName'] as String?;
    final colorJson = map['color'] as String?;

    return CoverRow(
      filter: filter,
      entryId: entryId,
      packageName: packageName,
      color: ExtraColor.fromJson(colorJson),
    );
  }

  Map<String, dynamic> toMap() => {
        'filter': filter.toJson(),
        'entryId': entryId,
        'packageName': packageName,
        'color': color?.toJson(),
      };
}
