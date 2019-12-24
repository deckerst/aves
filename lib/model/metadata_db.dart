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

  MetadataDb._private();

  Future<void> init() async {
    debugPrint('$runtimeType init');
    _database = openDatabase(
      await path,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE $metadataTable(contentId INTEGER PRIMARY KEY, dateMillis INTEGER, videoRotation INTEGER, xmpSubjects TEXT, latitude REAL, longitude REAL)');
        await db.execute('CREATE TABLE $addressTable(contentId INTEGER PRIMARY KEY, addressLine TEXT, countryName TEXT, adminArea TEXT, locality TEXT)');
      },
      version: 1,
    );
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
    final start = DateTime.now();
    final db = await _database;
    final maps = await db.query(metadataTable);
    final metadataEntries = maps.map((map) => CatalogMetadata.fromMap(map)).toList();
    debugPrint('$runtimeType loadMetadataEntries complete in ${DateTime.now().difference(start).inMilliseconds}ms with ${metadataEntries.length} entries');
    return metadataEntries;
  }

  Future<void> saveMetadata(Iterable<CatalogMetadata> metadataEntries) async {
    if (metadataEntries == null || metadataEntries.isEmpty) return;
    final start = DateTime.now();
    final db = await _database;
    final batch = db.batch();
    metadataEntries.where((metadata) => metadata != null).forEach((metadata) => batch.insert(
          metadataTable,
          metadata.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ));
    await batch.commit(noResult: true);
    debugPrint('$runtimeType saveMetadata complete in ${DateTime.now().difference(start).inMilliseconds}ms with ${metadataEntries.length} entries');
  }

  Future<void> clearAddresses() async {
    final db = await _database;
    final count = await db.delete(addressTable, where: '1');
    debugPrint('$runtimeType clearAddresses deleted $count entries');
  }

  Future<List<AddressDetails>> loadAddresses() async {
    final start = DateTime.now();
    final db = await _database;
    final maps = await db.query(addressTable);
    final addresses = maps.map((map) => AddressDetails.fromMap(map)).toList();
    debugPrint('$runtimeType loadAddresses complete in ${DateTime.now().difference(start).inMilliseconds}ms with ${addresses.length} entries');
    return addresses;
  }

  Future<void> saveAddresses(Iterable<AddressDetails> addresses) async {
    if (addresses == null || addresses.isEmpty) return;
    final start = DateTime.now();
    final db = await _database;
    final batch = db.batch();
    addresses.where((address) => address != null).forEach((address) => batch.insert(
          addressTable,
          address.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ));
    await batch.commit(noResult: true);
    debugPrint('$runtimeType saveAddresses complete in ${DateTime.now().difference(start).inMilliseconds}ms with ${addresses.length} entries');
  }
}
