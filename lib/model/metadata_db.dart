import 'dart:io';

import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata_db_upgrade.dart';
import 'package:aves/model/video_playback.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

abstract class MetadataDb {
  Future<void> init();

  Future<int> dbFileSize();

  Future<void> reset();

  Future<void> removeIds(Set<int> contentIds, {required bool metadataOnly});

  // entries

  Future<void> clearEntries();

  Future<Set<AvesEntry>> loadAllEntries();

  Future<void> saveEntries(Iterable<AvesEntry> entries);

  Future<void> updateEntryId(int oldId, AvesEntry entry);

  Future<Set<AvesEntry>> searchEntries(String query, {int? limit});

  // date taken

  Future<void> clearDates();

  Future<Map<int?, int?>> loadDates();

  // catalog metadata

  Future<void> clearMetadataEntries();

  Future<List<CatalogMetadata>> loadAllMetadataEntries();

  Future<void> saveMetadata(Set<CatalogMetadata> metadataEntries);

  Future<void> updateMetadataId(int oldId, CatalogMetadata? metadata);

  // address

  Future<void> clearAddresses();

  Future<List<AddressDetails>> loadAllAddresses();

  Future<void> saveAddresses(Set<AddressDetails> addresses);

  Future<void> updateAddressId(int oldId, AddressDetails? address);

  // favourites

  Future<void> clearFavourites();

  Future<Set<FavouriteRow>> loadAllFavourites();

  Future<void> addFavourites(Iterable<FavouriteRow> rows);

  Future<void> updateFavouriteId(int oldId, FavouriteRow row);

  Future<void> removeFavourites(Iterable<FavouriteRow> rows);

  // covers

  Future<void> clearCovers();

  Future<Set<CoverRow>> loadAllCovers();

  Future<void> addCovers(Iterable<CoverRow> rows);

  Future<void> updateCoverEntryId(int oldId, CoverRow row);

  Future<void> removeCovers(Set<CollectionFilter> filters);

  // video playback

  Future<void> clearVideoPlayback();

  Future<Set<VideoPlaybackRow>> loadAllVideoPlayback();

  Future<VideoPlaybackRow?> loadVideoPlayback(int? contentId);

  Future<void> addVideoPlayback(Set<VideoPlaybackRow> rows);

  Future<void> updateVideoPlaybackId(int oldId, int? newId);

  Future<void> removeVideoPlayback(Set<int> contentIds);
}

class SqfliteMetadataDb implements MetadataDb {
  late Future<Database> _database;

  Future<String> get path async => pContext.join(await getDatabasesPath(), 'metadata.db');

  static const entryTable = 'entry';
  static const dateTakenTable = 'dateTaken';
  static const metadataTable = 'metadata';
  static const addressTable = 'address';
  static const favouriteTable = 'favourites';
  static const coverTable = 'covers';
  static const videoPlaybackTable = 'videoPlayback';

  @override
  Future<void> init() async {
    _database = openDatabase(
      await path,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE $entryTable('
            'contentId INTEGER PRIMARY KEY'
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
            ')');
        await db.execute('CREATE TABLE $dateTakenTable('
            'contentId INTEGER PRIMARY KEY'
            ', dateMillis INTEGER'
            ')');
        await db.execute('CREATE TABLE $metadataTable('
            'contentId INTEGER PRIMARY KEY'
            ', mimeType TEXT'
            ', dateMillis INTEGER'
            ', flags INTEGER'
            ', rotationDegrees INTEGER'
            ', xmpSubjects TEXT'
            ', xmpTitleDescription TEXT'
            ', latitude REAL'
            ', longitude REAL'
            ')');
        await db.execute('CREATE TABLE $addressTable('
            'contentId INTEGER PRIMARY KEY'
            ', addressLine TEXT'
            ', countryCode TEXT'
            ', countryName TEXT'
            ', adminArea TEXT'
            ', locality TEXT'
            ')');
        await db.execute('CREATE TABLE $favouriteTable('
            'contentId INTEGER PRIMARY KEY'
            ', path TEXT'
            ')');
        await db.execute('CREATE TABLE $coverTable('
            'filter TEXT PRIMARY KEY'
            ', contentId INTEGER'
            ')');
        await db.execute('CREATE TABLE $videoPlaybackTable('
            'contentId INTEGER PRIMARY KEY'
            ', resumeTimeMillis INTEGER'
            ')');
      },
      onUpgrade: MetadataDbUpgrader.upgradeDb,
      version: 5,
    );
  }

  @override
  Future<int> dbFileSize() async {
    final file = File(await path);
    return await file.exists() ? await file.length() : 0;
  }

  @override
  Future<void> reset() async {
    debugPrint('$runtimeType reset');
    await (await _database).close();
    await deleteDatabase(await path);
    await init();
  }

  @override
  Future<void> removeIds(Set<int> contentIds, {required bool metadataOnly}) async {
    if (contentIds.isEmpty) return;

    final db = await _database;
    // using array in `whereArgs` and using it with `where contentId IN ?` is a pain, so we prefer `batch` instead
    final batch = db.batch();
    const where = 'contentId = ?';
    contentIds.forEach((id) {
      final whereArgs = [id];
      batch.delete(entryTable, where: where, whereArgs: whereArgs);
      batch.delete(dateTakenTable, where: where, whereArgs: whereArgs);
      batch.delete(metadataTable, where: where, whereArgs: whereArgs);
      batch.delete(addressTable, where: where, whereArgs: whereArgs);
      if (!metadataOnly) {
        batch.delete(favouriteTable, where: where, whereArgs: whereArgs);
        batch.delete(coverTable, where: where, whereArgs: whereArgs);
        batch.delete(videoPlaybackTable, where: where, whereArgs: whereArgs);
      }
    });
    await batch.commit(noResult: true);
  }

  // entries

  @override
  Future<void> clearEntries() async {
    final db = await _database;
    final count = await db.delete(entryTable, where: '1');
    debugPrint('$runtimeType clearEntries deleted $count rows');
  }

  @override
  Future<Set<AvesEntry>> loadAllEntries() async {
    final db = await _database;
    final maps = await db.query(entryTable);
    final entries = maps.map((map) => AvesEntry.fromMap(map)).toSet();
    return entries;
  }

  @override
  Future<void> saveEntries(Iterable<AvesEntry> entries) async {
    if (entries.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final batch = db.batch();
    entries.forEach((entry) => _batchInsertEntry(batch, entry));
    await batch.commit(noResult: true);
    debugPrint('$runtimeType saveEntries complete in ${stopwatch.elapsed.inMilliseconds}ms for ${entries.length} entries');
  }

  @override
  Future<void> updateEntryId(int oldId, AvesEntry entry) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete(entryTable, where: 'contentId = ?', whereArgs: [oldId]);
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
  Future<Set<AvesEntry>> searchEntries(String query, {int? limit}) async {
    final db = await _database;
    final maps = await db.query(
      entryTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'sourceDateTakenMillis DESC',
      limit: limit,
    );
    return maps.map((map) => AvesEntry.fromMap(map)).toSet();
  }

  // date taken

  @override
  Future<void> clearDates() async {
    final db = await _database;
    final count = await db.delete(dateTakenTable, where: '1');
    debugPrint('$runtimeType clearDates deleted $count rows');
  }

  @override
  Future<Map<int?, int?>> loadDates() async {
    final db = await _database;
    final maps = await db.query(dateTakenTable);
    final metadataEntries = Map.fromEntries(maps.map((map) => MapEntry(map['contentId'] as int, (map['dateMillis'] ?? 0) as int)));
    return metadataEntries;
  }

  // catalog metadata

  @override
  Future<void> clearMetadataEntries() async {
    final db = await _database;
    final count = await db.delete(metadataTable, where: '1');
    debugPrint('$runtimeType clearMetadataEntries deleted $count rows');
  }

  @override
  Future<List<CatalogMetadata>> loadAllMetadataEntries() async {
    final db = await _database;
    final maps = await db.query(metadataTable);
    final metadataEntries = maps.map((map) => CatalogMetadata.fromMap(map)).toList();
    return metadataEntries;
  }

  @override
  Future<void> saveMetadata(Set<CatalogMetadata> metadataEntries) async {
    if (metadataEntries.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    try {
      final db = await _database;
      final batch = db.batch();
      metadataEntries.forEach((metadata) => _batchInsertMetadata(batch, metadata));
      await batch.commit(noResult: true);
      debugPrint('$runtimeType saveMetadata complete in ${stopwatch.elapsed.inMilliseconds}ms for ${metadataEntries.length} entries');
    } catch (error, stack) {
      debugPrint('$runtimeType failed to save metadata with error=$error\n$stack');
    }
  }

  @override
  Future<void> updateMetadataId(int oldId, CatalogMetadata? metadata) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete(dateTakenTable, where: 'contentId = ?', whereArgs: [oldId]);
    batch.delete(metadataTable, where: 'contentId = ?', whereArgs: [oldId]);
    _batchInsertMetadata(batch, metadata);
    await batch.commit(noResult: true);
  }

  void _batchInsertMetadata(Batch batch, CatalogMetadata? metadata) {
    if (metadata == null) return;
    if (metadata.dateMillis != 0) {
      batch.insert(
        dateTakenTable,
        {
          'contentId': metadata.contentId,
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
    final db = await _database;
    final count = await db.delete(addressTable, where: '1');
    debugPrint('$runtimeType clearAddresses deleted $count rows');
  }

  @override
  Future<List<AddressDetails>> loadAllAddresses() async {
    final db = await _database;
    final maps = await db.query(addressTable);
    final addresses = maps.map((map) => AddressDetails.fromMap(map)).toList();
    return addresses;
  }

  @override
  Future<void> saveAddresses(Set<AddressDetails> addresses) async {
    if (addresses.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final batch = db.batch();
    addresses.forEach((address) => _batchInsertAddress(batch, address));
    await batch.commit(noResult: true);
    debugPrint('$runtimeType saveAddresses complete in ${stopwatch.elapsed.inMilliseconds}ms for ${addresses.length} entries');
  }

  @override
  Future<void> updateAddressId(int oldId, AddressDetails? address) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete(addressTable, where: 'contentId = ?', whereArgs: [oldId]);
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

  // favourites

  @override
  Future<void> clearFavourites() async {
    final db = await _database;
    final count = await db.delete(favouriteTable, where: '1');
    debugPrint('$runtimeType clearFavourites deleted $count rows');
  }

  @override
  Future<Set<FavouriteRow>> loadAllFavourites() async {
    final db = await _database;
    final maps = await db.query(favouriteTable);
    final rows = maps.map((map) => FavouriteRow.fromMap(map)).toSet();
    return rows;
  }

  @override
  Future<void> addFavourites(Iterable<FavouriteRow> rows) async {
    if (rows.isEmpty) return;
    final db = await _database;
    final batch = db.batch();
    rows.forEach((row) => _batchInsertFavourite(batch, row));
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateFavouriteId(int oldId, FavouriteRow row) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete(favouriteTable, where: 'contentId = ?', whereArgs: [oldId]);
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
    final ids = rows.map((row) => row.contentId);
    if (ids.isEmpty) return;

    final db = await _database;
    // using array in `whereArgs` and using it with `where contentId IN ?` is a pain, so we prefer `batch` instead
    final batch = db.batch();
    ids.forEach((id) => batch.delete(favouriteTable, where: 'contentId = ?', whereArgs: [id]));
    await batch.commit(noResult: true);
  }

  // covers

  @override
  Future<void> clearCovers() async {
    final db = await _database;
    final count = await db.delete(coverTable, where: '1');
    debugPrint('$runtimeType clearCovers deleted $count rows');
  }

  @override
  Future<Set<CoverRow>> loadAllCovers() async {
    final db = await _database;
    final maps = await db.query(coverTable);
    final rows = maps.map(CoverRow.fromMap).whereNotNull().toSet();
    return rows;
  }

  @override
  Future<void> addCovers(Iterable<CoverRow> rows) async {
    if (rows.isEmpty) return;

    final db = await _database;
    final batch = db.batch();
    rows.forEach((row) => _batchInsertCover(batch, row));
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateCoverEntryId(int oldId, CoverRow row) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete(coverTable, where: 'contentId = ?', whereArgs: [oldId]);
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

    final db = await _database;
    // using array in `whereArgs` and using it with `where filter IN ?` is a pain, so we prefer `batch` instead
    final batch = db.batch();
    filters.forEach((filter) => batch.delete(coverTable, where: 'filter = ?', whereArgs: [filter.toJson()]));
    await batch.commit(noResult: true);
  }

  // video playback

  @override
  Future<void> clearVideoPlayback() async {
    final db = await _database;
    final count = await db.delete(videoPlaybackTable, where: '1');
    debugPrint('$runtimeType clearVideoPlayback deleted $count rows');
  }

  @override
  Future<Set<VideoPlaybackRow>> loadAllVideoPlayback() async {
    final db = await _database;
    final maps = await db.query(videoPlaybackTable);
    final rows = maps.map(VideoPlaybackRow.fromMap).whereNotNull().toSet();
    return rows;
  }

  @override
  Future<VideoPlaybackRow?> loadVideoPlayback(int? contentId) async {
    if (contentId == null) return null;

    final db = await _database;
    final maps = await db.query(videoPlaybackTable, where: 'contentId = ?', whereArgs: [contentId]);
    if (maps.isEmpty) return null;

    return VideoPlaybackRow.fromMap(maps.first);
  }

  @override
  Future<void> addVideoPlayback(Set<VideoPlaybackRow> rows) async {
    if (rows.isEmpty) return;

    final db = await _database;
    final batch = db.batch();
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
  Future<void> updateVideoPlaybackId(int oldId, int? newId) async {
    if (newId != null) {
      final db = await _database;
      await db.update(videoPlaybackTable, {'contentId': newId}, where: 'contentId = ?', whereArgs: [oldId]);
    } else {
      await removeVideoPlayback({oldId});
    }
  }

  @override
  Future<void> removeVideoPlayback(Set<int> contentIds) async {
    if (contentIds.isEmpty) return;

    final db = await _database;
    // using array in `whereArgs` and using it with `where filter IN ?` is a pain, so we prefer `batch` instead
    final batch = db.batch();
    contentIds.forEach((id) => batch.delete(videoPlaybackTable, where: 'contentId = ?', whereArgs: [id]));
    await batch.commit(noResult: true);
  }
}
