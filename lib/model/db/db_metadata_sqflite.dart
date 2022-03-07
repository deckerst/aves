import 'dart:io';

import 'package:aves/model/covers.dart';
import 'package:aves/model/db/db_metadata.dart';
import 'package:aves/model/db/db_metadata_sqflite_upgrade.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteMetadataDb implements MetadataDb {
  late Database _db;

  Future<String> get path async => pContext.join(await getDatabasesPath(), 'metadata.db');

  static const entryTable = 'entry';
  static const dateTakenTable = 'dateTaken';
  static const metadataTable = 'metadata';
  static const addressTable = 'address';
  static const favouriteTable = 'favourites';
  static const coverTable = 'covers';
  static const trashTable = 'trash';
  static const videoPlaybackTable = 'videoPlayback';

  static int _lastId = 0;

  @override
  int get nextId => ++_lastId;

  @override
  Future<void> init() async {
    _db = await openDatabase(
      await path,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE $entryTable('
            'id INTEGER PRIMARY KEY'
            ', contentId INTEGER'
            ', uri TEXT'
            ', path TEXT'
            ', sourceMimeType TEXT'
            ', width INTEGER'
            ', height INTEGER'
            ', sourceRotationDegrees INTEGER'
            ', sizeBytes INTEGER'
            ', title TEXT'
            ', dateModifiedSecs INTEGER'
            ', sourceDateTakenMillis INTEGER'
            ', durationMillis INTEGER'
            ', trashed INTEGER DEFAULT 0'
            ')');
        await db.execute('CREATE TABLE $dateTakenTable('
            'id INTEGER PRIMARY KEY'
            ', dateMillis INTEGER'
            ')');
        await db.execute('CREATE TABLE $metadataTable('
            'id INTEGER PRIMARY KEY'
            ', mimeType TEXT'
            ', dateMillis INTEGER'
            ', flags INTEGER'
            ', rotationDegrees INTEGER'
            ', xmpSubjects TEXT'
            ', xmpTitleDescription TEXT'
            ', latitude REAL'
            ', longitude REAL'
            ', rating INTEGER'
            ')');
        await db.execute('CREATE TABLE $addressTable('
            'id INTEGER PRIMARY KEY'
            ', addressLine TEXT'
            ', countryCode TEXT'
            ', countryName TEXT'
            ', adminArea TEXT'
            ', locality TEXT'
            ')');
        await db.execute('CREATE TABLE $favouriteTable('
            'id INTEGER PRIMARY KEY'
            ')');
        await db.execute('CREATE TABLE $coverTable('
            'filter TEXT PRIMARY KEY'
            ', entryId INTEGER'
            ')');
        await db.execute('CREATE TABLE $trashTable('
            'id INTEGER PRIMARY KEY'
            ', path TEXT'
            ', dateMillis INTEGER'
            ')');
        await db.execute('CREATE TABLE $videoPlaybackTable('
            'id INTEGER PRIMARY KEY'
            ', resumeTimeMillis INTEGER'
            ')');
      },
      onUpgrade: MetadataDbUpgrader.upgradeDb,
      version: 7,
    );

    final maxIdRows = await _db.rawQuery('SELECT max(id) AS maxId FROM $entryTable');
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
  Future<void> removeIds(Iterable<int> ids, {Set<EntryDataType>? dataTypes}) async {
    if (ids.isEmpty) return;

    final _dataTypes = dataTypes ?? EntryDataType.values.toSet();

    // using array in `whereArgs` and using it with `where id IN ?` is a pain, so we prefer `batch` instead
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
  Future<Set<AvesEntry>> loadEntries({String? directory}) async {
    if (directory != null) {
      final separator = pContext.separator;
      if (!directory.endsWith(separator)) {
        directory = '$directory$separator';
      }

      const where = 'path LIKE ?';
      final whereArgs = ['$directory%'];
      final rows = await _db.query(entryTable, where: where, whereArgs: whereArgs);

      final dirLength = directory.length;
      return rows
          .whereNot((row) {
            // skip entries in subfolders
            final path = row['path'] as String?;
            return path == null || path.substring(dirLength).contains(separator);
          })
          .map(AvesEntry.fromMap)
          .toSet();
    }

    final rows = await _db.query(entryTable);
    return rows.map(AvesEntry.fromMap).toSet();
  }

  @override
  Future<Set<AvesEntry>> loadEntriesById(Iterable<int> ids) => _getByIds(ids, entryTable, AvesEntry.fromMap);

  @override
  Future<void> saveEntries(Iterable<AvesEntry> entries) async {
    if (entries.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    final batch = _db.batch();
    entries.forEach((entry) => _batchInsertEntry(batch, entry));
    await batch.commit(noResult: true);
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
      where: 'title LIKE ? AND trashed = ?',
      whereArgs: ['%$query%', 0],
      orderBy: 'sourceDateTakenMillis DESC',
      limit: limit,
    );
    return rows.map(AvesEntry.fromMap).toSet();
  }

  // date taken

  @override
  Future<void> clearDates() async {
    final count = await _db.delete(dateTakenTable, where: '1');
    debugPrint('$runtimeType clearDates deleted $count rows');
  }

  @override
  Future<Map<int?, int?>> loadDates() async {
    final rows = await _db.query(dateTakenTable);
    return Map.fromEntries(rows.map((map) => MapEntry(map['id'] as int, (map['dateMillis'] ?? 0) as int)));
  }

  // catalog metadata

  @override
  Future<void> clearCatalogMetadata() async {
    final count = await _db.delete(metadataTable, where: '1');
    debugPrint('$runtimeType clearMetadataEntries deleted $count rows');
  }

  @override
  Future<Set<CatalogMetadata>> loadCatalogMetadata() async {
    final rows = await _db.query(metadataTable);
    return rows.map(CatalogMetadata.fromMap).toSet();
  }

  @override
  Future<Set<CatalogMetadata>> loadCatalogMetadataById(Iterable<int> ids) => _getByIds(ids, metadataTable, CatalogMetadata.fromMap);

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
    final rows = await _db.query(addressTable);
    return rows.map(AddressDetails.fromMap).toSet();
  }

  @override
  Future<Set<AddressDetails>> loadAddressesById(Iterable<int> ids) => _getByIds(ids, addressTable, AddressDetails.fromMap);

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

  // trash

  @override
  Future<void> clearTrashDetails() async {
    final count = await _db.delete(trashTable, where: '1');
    debugPrint('$runtimeType clearTrashDetails deleted $count rows');
  }

  @override
  Future<Set<TrashDetails>> loadAllTrashDetails() async {
    final rows = await _db.query(trashTable);
    return rows.map(TrashDetails.fromMap).toSet();
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
    final rows = await _db.query(favouriteTable);
    return rows.map(FavouriteRow.fromMap).toSet();
  }

  @override
  Future<void> addFavourites(Iterable<FavouriteRow> rows) async {
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
  Future<void> removeFavourites(Iterable<FavouriteRow> rows) async {
    if (rows.isEmpty) return;
    final ids = rows.map((row) => row.entryId);
    if (ids.isEmpty) return;

    // using array in `whereArgs` and using it with `where id IN ?` is a pain, so we prefer `batch` instead
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
    final rows = await _db.query(coverTable);
    return rows.map(CoverRow.fromMap).whereNotNull().toSet();
  }

  @override
  Future<void> addCovers(Iterable<CoverRow> rows) async {
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

    // using array in `whereArgs` and using it with `where filter IN ?` is a pain, so we prefer `batch` instead
    final batch = _db.batch();
    filters.forEach((filter) => batch.delete(coverTable, where: 'filter = ?', whereArgs: [filter.toJson()]));
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
    final rows = await _db.query(videoPlaybackTable);
    return rows.map(VideoPlaybackRow.fromMap).whereNotNull().toSet();
  }

  @override
  Future<VideoPlaybackRow?> loadVideoPlayback(int? id) async {
    if (id == null) return null;

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
  Future<void> removeVideoPlayback(Iterable<int> ids) async {
    if (ids.isEmpty) return;

    // using array in `whereArgs` and using it with `where filter IN ?` is a pain, so we prefer `batch` instead
    final batch = _db.batch();
    ids.forEach((id) => batch.delete(videoPlaybackTable, where: 'id = ?', whereArgs: [id]));
    await batch.commit(noResult: true);
  }

  // convenience methods

  Future<Set<T>> _getByIds<T>(Iterable<int> ids, String table, T Function(Map<String, Object?> row) mapRow) async {
    if (ids.isEmpty) return {};
    final rows = await _db.query(
      table,
      where: 'id IN (${ids.join(',')})',
    );
    return rows.map(mapRow).toSet();
  }
}
