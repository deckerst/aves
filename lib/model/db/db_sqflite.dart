import 'dart:io';

import 'package:aves/model/covers.dart';
import 'package:aves/model/db/db.dart';
import 'package:aves/model/db/db_sqflite_schema.dart';
import 'package:aves/model/db/db_sqflite_upgrade.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/vaults/details.dart';
import 'package:aves/model/viewer/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteLocalMediaDb implements LocalMediaDb {
  late Database _db;

  @override
  Future<String> get path async => pContext.join(await getDatabasesPath(), 'metadata.db');

  static const entryTable = SqfliteLocalMediaDbSchema.entryTable;
  static const dateTakenTable = SqfliteLocalMediaDbSchema.dateTakenTable;
  static const metadataTable = SqfliteLocalMediaDbSchema.metadataTable;
  static const addressTable = SqfliteLocalMediaDbSchema.addressTable;
  static const favouriteTable = SqfliteLocalMediaDbSchema.favouriteTable;
  static const coverTable = SqfliteLocalMediaDbSchema.coverTable;
  static const dynamicAlbumTable = SqfliteLocalMediaDbSchema.dynamicAlbumTable;
  static const vaultTable = SqfliteLocalMediaDbSchema.vaultTable;
  static const trashTable = SqfliteLocalMediaDbSchema.trashTable;
  static const videoPlaybackTable = SqfliteLocalMediaDbSchema.videoPlaybackTable;

  static const _entryInsertSliceMaxCount = 10000; // number of entries
  static const _queryCursorBufferSize = 1000; // number of rows
  static int _lastId = 0;

  @override
  int get nextId => ++_lastId;

  @override
  Future<void> init() async {
    _db = await openDatabase(
      await path,
      onCreate: (db, version) => SqfliteLocalMediaDbSchema.createLatestVersion(db),
      onUpgrade: LocalMediaDbUpgrader.upgradeDb,
      version: 15,
    );

    final maxIdRows = await _db.rawQuery('SELECT MAX(id) AS maxId FROM $entryTable');
    _lastId = (maxIdRows.firstOrNull?['maxId'] as int?) ?? 0;
  }

  @override
  Future<int> dbFileSize() async {
    final file = File(await path);
    return await file.exists() ? await file.length() : 0;
  }

  @override
  Future<void> reset() async {
    debugPrint('$runtimeType reset');
    await _db.close();
    await deleteDatabase(await path);
    await init();
  }

  @override
  Future<void> removeIds(Set<int> ids, {Set<EntryDataType>? dataTypes}) async {
    if (ids.isEmpty) return;

    final _dataTypes = dataTypes ?? EntryDataType.values.toSet();

    // using array in `whereArgs` and using it with `where arg IN ?` is a pain, so we prefer `batch` instead
    final batch = _db.batch();
    const where = 'id = ?';
    const coverWhere = 'entryId = ?';
    ids.forEach((id) {
      final whereArgs = [id];
      if (_dataTypes.contains(EntryDataType.basic)) {
        batch.delete(entryTable, where: where, whereArgs: whereArgs);
      }
      if (_dataTypes.contains(EntryDataType.catalog)) {
        batch.delete(dateTakenTable, where: where, whereArgs: whereArgs);
        batch.delete(metadataTable, where: where, whereArgs: whereArgs);
      }
      if (_dataTypes.contains(EntryDataType.address)) {
        batch.delete(addressTable, where: where, whereArgs: whereArgs);
      }
      if (_dataTypes.contains(EntryDataType.references)) {
        batch.delete(favouriteTable, where: where, whereArgs: whereArgs);
        batch.delete(coverTable, where: coverWhere, whereArgs: whereArgs);
        batch.delete(trashTable, where: where, whereArgs: whereArgs);
        batch.delete(videoPlaybackTable, where: where, whereArgs: whereArgs);
      }
    });
    await batch.commit(noResult: true);
  }

  // entries

  @override
  Future<void> clearEntries() async {
    final count = await _db.delete(entryTable, where: '1');
    debugPrint('$runtimeType clearEntries deleted $count rows');
  }

  @override
  Future<Set<AvesEntry>> loadEntries({int? origin, String? directory}) async {
    String? where;
    final whereArgs = <Object?>[];

    if (origin != null) {
      where = 'origin = ?';
      whereArgs.add(origin);
    }

    final entries = <AvesEntry>{};
    if (directory != null) {
      final separator = pContext.separator;
      if (!directory.endsWith(separator)) {
        directory = '$directory$separator';
      }

      where = '${where != null ? '$where AND ' : ''}path LIKE ?';
      whereArgs.add('$directory%');
      final cursor = await _db.queryCursor(entryTable, where: where, whereArgs: whereArgs, bufferSize: _queryCursorBufferSize);

      final dirLength = directory.length;
      while (await cursor.moveNext()) {
        final row = cursor.current;
        // skip entries in subfolders
        final path = row['path'] as String?;
        if (path != null && !path.substring(dirLength).contains(separator)) {
          entries.add(AvesEntry.fromMap(row));
        }
      }
    } else {
      final cursor = await _db.queryCursor(entryTable, where: where, whereArgs: whereArgs, bufferSize: _queryCursorBufferSize);
      while (await cursor.moveNext()) {
        entries.add(AvesEntry.fromMap(cursor.current));
      }
    }

    return entries;
  }

  @override
  Future<Set<AvesEntry>> loadEntriesById(Set<int> ids) => _getByIds(ids, entryTable, AvesEntry.fromMap);

  @override
  Future<void> insertEntries(Set<AvesEntry> entries) async {
    if (entries.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    // slice entries to avoid memory issues
    int inserted = 0;
    await Future.forEach(entries.slices(_entryInsertSliceMaxCount), (slice) async {
      debugPrint('$runtimeType saveEntries inserting slice of [${inserted + 1}, ${inserted + slice.length}] entries');
      final batch = _db.batch();
      slice.forEach((entry) => _batchInsertEntry(batch, entry));
      await batch.commit(noResult: true);
      inserted += slice.length;
    });
    debugPrint('$runtimeType saveEntries complete in ${stopwatch.elapsed.inMilliseconds}ms for ${entries.length} entries');
  }

  @override
  Future<void> updateEntry(int id, AvesEntry entry) async {
    final batch = _db.batch();
    batch.delete(entryTable, where: 'id = ?', whereArgs: [id]);
    _batchInsertEntry(batch, entry);
    await batch.commit(noResult: true);
  }

  void _batchInsertEntry(Batch batch, AvesEntry entry) {
    batch.insert(
      entryTable,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Set<AvesEntry>> searchLiveEntries(String query, {int? limit}) async {
    final rows = await _db.query(
      entryTable,
      where: '(title LIKE ? OR path LIKE ?) AND trashed = ?',
      whereArgs: ['%$query%', '%$query%', 0],
      orderBy: 'sourceDateTakenMillis DESC',
      limit: limit,
    );
    return rows.map(AvesEntry.fromMap).toSet();
  }

  @override
  Future<Set<AvesEntry>> searchLiveDuplicates(int origin, Set<AvesEntry>? entries) async {
    String where = 'origin = ? AND trashed = ?';
    if (entries != null) {
      where += ' AND contentId IN (${entries.map((v) => v.contentId).join(',')})';
    }
    final rows = await _db.rawQuery(
      'SELECT *, MAX(id) AS id'
      ' FROM $entryTable'
      ' WHERE $where'
      ' GROUP BY contentId'
      ' HAVING COUNT(id) > 1',
      [origin, 0],
    );
    final duplicates = rows.map(AvesEntry.fromMap).toSet();
    if (duplicates.isNotEmpty) {
      debugPrint('Found duplicates=$duplicates');
    }
    // return most recent duplicate for each duplicated content ID
    return duplicates;
  }

  // date taken

  @override
  Future<void> clearDates() async {
    final count = await _db.delete(dateTakenTable, where: '1');
    debugPrint('$runtimeType clearDates deleted $count rows');
  }

  @override
  Future<Map<int?, int?>> loadDates() async {
    final result = <int?, int?>{};
    final cursor = await _db.queryCursor(dateTakenTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      final row = cursor.current;
      result[row['id'] as int] = row['dateMillis'] as int? ?? 0;
    }
    return result;
  }

  // catalog metadata

  @override
  Future<void> clearCatalogMetadata() async {
    final count = await _db.delete(metadataTable, where: '1');
    debugPrint('$runtimeType clearMetadataEntries deleted $count rows');
  }

  @override
  Future<Set<CatalogMetadata>> loadCatalogMetadata() async {
    final result = <CatalogMetadata>{};
    final cursor = await _db.queryCursor(metadataTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      result.add(CatalogMetadata.fromMap(cursor.current));
    }
    return result;
  }

  @override
  Future<Set<CatalogMetadata>> loadCatalogMetadataById(Set<int> ids) => _getByIds(ids, metadataTable, CatalogMetadata.fromMap);

  @override
  Future<void> saveCatalogMetadata(Set<CatalogMetadata> metadataEntries) async {
    if (metadataEntries.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    try {
      final batch = _db.batch();
      metadataEntries.forEach((metadata) => _batchInsertMetadata(batch, metadata));
      await batch.commit(noResult: true);
      debugPrint('$runtimeType saveMetadata complete in ${stopwatch.elapsed.inMilliseconds}ms for ${metadataEntries.length} entries');
    } catch (error, stack) {
      debugPrint('$runtimeType failed to save metadata with error=$error\n$stack');
    }
  }

  @override
  Future<void> updateCatalogMetadata(int id, CatalogMetadata? metadata) async {
    final batch = _db.batch();
    batch.delete(dateTakenTable, where: 'id = ?', whereArgs: [id]);
    batch.delete(metadataTable, where: 'id = ?', whereArgs: [id]);
    _batchInsertMetadata(batch, metadata);
    await batch.commit(noResult: true);
  }

  void _batchInsertMetadata(Batch batch, CatalogMetadata? metadata) {
    if (metadata == null) return;
    if (metadata.dateMillis != 0) {
      batch.insert(
        dateTakenTable,
        {
          'id': metadata.id,
          'dateMillis': metadata.dateMillis,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    batch.insert(
      metadataTable,
      metadata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // address

  @override
  Future<void> clearAddresses() async {
    final count = await _db.delete(addressTable, where: '1');
    debugPrint('$runtimeType clearAddresses deleted $count rows');
  }

  @override
  Future<Set<AddressDetails>> loadAddresses() async {
    final result = <AddressDetails>{};
    final cursor = await _db.queryCursor(addressTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      result.add(AddressDetails.fromMap(cursor.current));
    }
    return result;
  }

  @override
  Future<Set<AddressDetails>> loadAddressesById(Set<int> ids) => _getByIds(ids, addressTable, AddressDetails.fromMap);

  @override
  Future<void> saveAddresses(Set<AddressDetails> addresses) async {
    if (addresses.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    final batch = _db.batch();
    addresses.forEach((address) => _batchInsertAddress(batch, address));
    await batch.commit(noResult: true);
    debugPrint('$runtimeType saveAddresses complete in ${stopwatch.elapsed.inMilliseconds}ms for ${addresses.length} entries');
  }

  @override
  Future<void> updateAddress(int id, AddressDetails? address) async {
    final batch = _db.batch();
    batch.delete(addressTable, where: 'id = ?', whereArgs: [id]);
    _batchInsertAddress(batch, address);
    await batch.commit(noResult: true);
  }

  void _batchInsertAddress(Batch batch, AddressDetails? address) {
    if (address == null) return;
    batch.insert(
      addressTable,
      address.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // vaults

  @override
  Future<void> clearVaults() async {
    final count = await _db.delete(vaultTable, where: '1');
    debugPrint('$runtimeType clearVaults deleted $count rows');
  }

  @override
  Future<Set<VaultDetails>> loadAllVaults() async {
    final result = <VaultDetails>{};
    final cursor = await _db.queryCursor(vaultTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      result.add(VaultDetails.fromMap(cursor.current));
    }
    return result;
  }

  @override
  Future<void> addVaults(Set<VaultDetails> rows) async {
    if (rows.isEmpty) return;
    final batch = _db.batch();
    rows.forEach((row) => _batchInsertVault(batch, row));
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateVault(String oldName, VaultDetails row) async {
    final batch = _db.batch();
    batch.delete(vaultTable, where: 'name = ?', whereArgs: [oldName]);
    _batchInsertVault(batch, row);
    await batch.commit(noResult: true);
  }

  void _batchInsertVault(Batch batch, VaultDetails row) {
    batch.insert(
      vaultTable,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeVaults(Set<VaultDetails> rows) async {
    if (rows.isEmpty) return;

    // using array in `whereArgs` and using it with `where arg IN ?` is a pain, so we prefer `batch` instead
    final batch = _db.batch();
    rows.map((v) => v.name).forEach((name) => batch.delete(vaultTable, where: 'name = ?', whereArgs: [name]));
    await batch.commit(noResult: true);
  }

  // trash

  @override
  Future<void> clearTrashDetails() async {
    final count = await _db.delete(trashTable, where: '1');
    debugPrint('$runtimeType clearTrashDetails deleted $count rows');
  }

  @override
  Future<Set<TrashDetails>> loadAllTrashDetails() async {
    final result = <TrashDetails>{};
    final cursor = await _db.queryCursor(trashTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      result.add(TrashDetails.fromMap(cursor.current));
    }
    return result;
  }

  @override
  Future<void> updateTrash(int id, TrashDetails? details) async {
    final batch = _db.batch();
    batch.delete(trashTable, where: 'id = ?', whereArgs: [id]);
    _batchInsertTrashDetails(batch, details);
    await batch.commit(noResult: true);
  }

  void _batchInsertTrashDetails(Batch batch, TrashDetails? details) {
    if (details == null) return;
    batch.insert(
      trashTable,
      details.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // favourites

  @override
  Future<void> clearFavourites() async {
    final count = await _db.delete(favouriteTable, where: '1');
    debugPrint('$runtimeType clearFavourites deleted $count rows');
  }

  @override
  Future<Set<FavouriteRow>> loadAllFavourites() async {
    final result = <FavouriteRow>{};
    final cursor = await _db.queryCursor(favouriteTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      result.add(FavouriteRow.fromMap(cursor.current));
    }
    return result;
  }

  @override
  Future<void> addFavourites(Set<FavouriteRow> rows) async {
    if (rows.isEmpty) return;
    final batch = _db.batch();
    rows.forEach((row) => _batchInsertFavourite(batch, row));
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateFavouriteId(int id, FavouriteRow row) async {
    final batch = _db.batch();
    batch.delete(favouriteTable, where: 'id = ?', whereArgs: [id]);
    _batchInsertFavourite(batch, row);
    await batch.commit(noResult: true);
  }

  void _batchInsertFavourite(Batch batch, FavouriteRow row) {
    batch.insert(
      favouriteTable,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeFavourites(Set<FavouriteRow> rows) async {
    if (rows.isEmpty) return;
    final ids = rows.map((row) => row.entryId);
    if (ids.isEmpty) return;

    // using array in `whereArgs` and using it with `where arg IN ?` is a pain, so we prefer `batch` instead
    final batch = _db.batch();
    ids.forEach((id) => batch.delete(favouriteTable, where: 'id = ?', whereArgs: [id]));
    await batch.commit(noResult: true);
  }

  // covers

  @override
  Future<void> clearCovers() async {
    final count = await _db.delete(coverTable, where: '1');
    debugPrint('$runtimeType clearCovers deleted $count rows');
  }

  @override
  Future<Set<CoverRow>> loadAllCovers() async {
    final result = <CoverRow>{};
    final cursor = await _db.queryCursor(coverTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      final row = CoverRow.fromMap(cursor.current);
      if (row != null) {
        result.add(row);
      }
    }
    return result;
  }

  @override
  Future<void> addCovers(Set<CoverRow> rows) async {
    if (rows.isEmpty) return;

    final batch = _db.batch();
    rows.forEach((row) => _batchInsertCover(batch, row));
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateCoverEntryId(int id, CoverRow row) async {
    final batch = _db.batch();
    batch.delete(coverTable, where: 'entryId = ?', whereArgs: [id]);
    _batchInsertCover(batch, row);
    await batch.commit(noResult: true);
  }

  void _batchInsertCover(Batch batch, CoverRow row) {
    batch.insert(
      coverTable,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeCovers(Set<CollectionFilter> filters) async {
    if (filters.isEmpty) return;

    // for backward compatibility, remove stored JSON instead of removing de/reserialized filters
    final obsoleteFilterJson = <String>{};

    final rows = await _db.query(coverTable);
    rows.forEach((row) {
      final filterJson = row['filter'] as String?;
      if (filterJson != null) {
        final filter = CollectionFilter.fromJson(filterJson);
        if (filters.any((v) => filter == v)) {
          obsoleteFilterJson.add(filterJson);
        }
      }
    });

    // using array in `whereArgs` and using it with `where arg IN ?` is a pain, so we prefer `batch` instead
    final batch = _db.batch();
    obsoleteFilterJson.forEach((filterJson) => batch.delete(coverTable, where: 'filter = ?', whereArgs: [filterJson]));
    await batch.commit(noResult: true);
  }

  // dynamic albums

  @override
  Future<void> clearDynamicAlbums() async {
    final count = await _db.delete(dynamicAlbumTable, where: '1');
    debugPrint('$runtimeType clearDynamicAlbums deleted $count rows');
  }

  @override
  Future<Set<DynamicAlbumRow>> loadAllDynamicAlbums() async {
    final result = <DynamicAlbumRow>{};
    final cursor = await _db.queryCursor(dynamicAlbumTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      final row = DynamicAlbumRow.fromMap(cursor.current);
      if (row != null) {
        result.add(row);
      }
    }
    return result;
  }

  @override
  Future<void> addDynamicAlbums(Set<DynamicAlbumRow> rows) async {
    if (rows.isEmpty) return;

    final batch = _db.batch();
    rows.forEach((row) => _batchInsertDynamicAlbum(batch, row));
    await batch.commit(noResult: true);
  }

  void _batchInsertDynamicAlbum(Batch batch, DynamicAlbumRow row) {
    batch.insert(
      dynamicAlbumTable,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeDynamicAlbums(Set<String> names) async {
    if (names.isEmpty) return;

    // using array in `whereArgs` and using it with `where arg IN ?` is a pain, so we prefer `batch` instead
    final batch = _db.batch();
    names.forEach((name) => batch.delete(dynamicAlbumTable, where: 'name = ?', whereArgs: [name]));
    await batch.commit(noResult: true);
  }

  // video playback

  @override
  Future<void> clearVideoPlayback() async {
    final count = await _db.delete(videoPlaybackTable, where: '1');
    debugPrint('$runtimeType clearVideoPlayback deleted $count rows');
  }

  @override
  Future<Set<VideoPlaybackRow>> loadAllVideoPlayback() async {
    final result = <VideoPlaybackRow>{};
    final cursor = await _db.queryCursor(videoPlaybackTable, bufferSize: _queryCursorBufferSize);
    while (await cursor.moveNext()) {
      final row = VideoPlaybackRow.fromMap(cursor.current);
      if (row != null) {
        result.add(row);
      }
    }
    return result;
  }

  @override
  Future<VideoPlaybackRow?> loadVideoPlayback(int id) async {
    final rows = await _db.query(videoPlaybackTable, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;

    return VideoPlaybackRow.fromMap(rows.first);
  }

  @override
  Future<void> addVideoPlayback(Set<VideoPlaybackRow> rows) async {
    if (rows.isEmpty) return;

    final batch = _db.batch();
    rows.forEach((row) => _batchInsertVideoPlayback(batch, row));
    await batch.commit(noResult: true);
  }

  void _batchInsertVideoPlayback(Batch batch, VideoPlaybackRow row) {
    batch.insert(
      videoPlaybackTable,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeVideoPlayback(Set<int> ids) async {
    if (ids.isEmpty) return;

    // using array in `whereArgs` and using it with `where arg IN ?` is a pain, so we prefer `batch` instead
    final batch = _db.batch();
    ids.forEach((id) => batch.delete(videoPlaybackTable, where: 'id = ?', whereArgs: [id]));
    await batch.commit(noResult: true);
  }

  // convenience methods

  Future<Set<T>> _getByIds<T>(Set<int> ids, String table, T Function(Map<String, Object?> row) mapRow) async {
    final result = <T>{};
    if (ids.isNotEmpty) {
      final cursor = await _db.queryCursor(table, where: 'id IN (${ids.join(',')})', bufferSize: _queryCursorBufferSize);
      while (await cursor.moveNext()) {
        result.add(mapRow(cursor.current));
      }
    }
    return result;
  }
}
