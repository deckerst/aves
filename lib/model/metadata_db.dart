import 'dart:io';

import 'package:aves/model/image_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final MetadataDb metadataDb = MetadataDb._private();

class MetadataDb {
  Future<Database> _database;

  Future<String> get path async => join(await getDatabasesPath(), 'metadata.db');

  static const metadataTable = 'metadata';
  static const addressTable = 'address';
  static const favouriteTable = 'favourites';

  MetadataDb._private();

  Future<void> init() async {
    debugPrint('$runtimeType init');
    _database = openDatabase(
      await path,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE $metadataTable(contentId INTEGER PRIMARY KEY, dateMillis INTEGER, videoRotation INTEGER, xmpSubjects TEXT, xmpTitleDescription TEXT, latitude REAL, longitude REAL)');
        await db.execute('CREATE TABLE $addressTable(contentId INTEGER PRIMARY KEY, addressLine TEXT, countryName TEXT, adminArea TEXT, locality TEXT)');
        await db.execute('CREATE TABLE $favouriteTable(contentId INTEGER PRIMARY KEY, path TEXT)');
      },
      version: 1,
    );
  }

  Future<int> dbFileSize() async {
    final file = File((await path));
    return await file.exists() ? file.length() : 0;
  }

  Future<void> reset() async {
    debugPrint('$runtimeType reset');
    await (await _database).close();
    await deleteDatabase(await path);
    await init();
  }

  Future<void> clearMetadataEntries() async {
    final db = await _database;
    final count = await db.delete(metadataTable, where: '1');
    debugPrint('$runtimeType clearMetadataEntries deleted $count entries');
  }

  Future<List<CatalogMetadata>> loadMetadataEntries() async {
//    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final maps = await db.query(metadataTable);
    final metadataEntries = maps.map((map) => CatalogMetadata.fromMap(map)).toList();
//    debugPrint('$runtimeType loadMetadataEntries complete in ${stopwatch.elapsed.inMilliseconds}ms with ${metadataEntries.length} entries');
    return metadataEntries;
  }

  Future<void> saveMetadata(Iterable<CatalogMetadata> metadataEntries) async {
    if (metadataEntries == null || metadataEntries.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final batch = db.batch();
    metadataEntries.where((metadata) => metadata != null).forEach((metadata) => batch.insert(
          metadataTable,
          metadata.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ));
    await batch.commit(noResult: true);
    debugPrint('$runtimeType saveMetadata complete in ${stopwatch.elapsed.inMilliseconds}ms with ${metadataEntries.length} entries');
  }

  Future<void> clearAddresses() async {
    final db = await _database;
    final count = await db.delete(addressTable, where: '1');
    debugPrint('$runtimeType clearAddresses deleted $count entries');
  }

  Future<List<AddressDetails>> loadAddresses() async {
//    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final maps = await db.query(addressTable);
    final addresses = maps.map((map) => AddressDetails.fromMap(map)).toList();
//    debugPrint('$runtimeType loadAddresses complete in ${stopwatch.elapsed.inMilliseconds}ms with ${addresses.length} entries');
    return addresses;
  }

  Future<void> saveAddresses(Iterable<AddressDetails> addresses) async {
    if (addresses == null || addresses.isEmpty) return;
    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final batch = db.batch();
    addresses.where((address) => address != null).forEach((address) => batch.insert(
          addressTable,
          address.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ));
    await batch.commit(noResult: true);
    debugPrint('$runtimeType saveAddresses complete in ${stopwatch.elapsed.inMilliseconds}ms with ${addresses.length} entries');
  }

  // favourites

  Future<void> clearFavourites() async {
    final db = await _database;
    final count = await db.delete(favouriteTable, where: '1');
    debugPrint('$runtimeType clearFavourites deleted $count entries');
  }

  Future<List<FavouriteRow>> loadFavourites() async {
//    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final maps = await db.query(favouriteTable);
    final favouriteRows = maps.map((map) => FavouriteRow.fromMap(map)).toList();
//    debugPrint('$runtimeType loadFavourites complete in ${stopwatch.elapsed.inMilliseconds}ms with ${favouriteRows.length} entries');
    return favouriteRows;
  }

  Future<void> addFavourites(Iterable<FavouriteRow> favouriteRows) async {
    if (favouriteRows == null || favouriteRows.isEmpty) return;
//    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final batch = db.batch();
    favouriteRows.where((row) => row != null).forEach((row) => batch.insert(
          favouriteTable,
          row.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ));
    await batch.commit(noResult: true);
//    debugPrint('$runtimeType addFavourites complete in ${stopwatch.elapsed.inMilliseconds}ms with ${favouriteRows.length} entries');
  }

  Future<void> removeFavourites(Iterable<FavouriteRow> favouriteRows) async {
    if (favouriteRows == null || favouriteRows.isEmpty) return;
    final ids = favouriteRows.where((row) => row != null).map((row) => row.contentId);
    if (ids.isEmpty) return;

    // using array in `whereArgs` and using it with `where contentId IN ?` is a pain, so we prefer `batch` instead
//    final stopwatch = Stopwatch()..start();
    final db = await _database;
    final batch = db.batch();
    ids.forEach((id) => batch.delete(
          favouriteTable,
          where: 'contentId = ?',
          whereArgs: [id],
        ));
    await batch.commit(noResult: true);
//    debugPrint('$runtimeType removeFavourites complete in ${stopwatch.elapsed.inMilliseconds}ms with ${favouriteRows.length} entries');
  }
}
