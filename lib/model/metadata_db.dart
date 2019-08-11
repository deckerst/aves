import 'package:aves/model/image_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final MetadataDb metadataDb = MetadataDb._private();

class MetadataDb {
  Future<Database> _database;

  Future<String> get path async => join(await getDatabasesPath(), 'metadata.db');

  static final metadataTable = 'metadata';
  static final addressTable = 'address';

  MetadataDb._private();

  init() async {
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

  reset() async {
    debugPrint('$runtimeType reset');
    (await _database).close();
    deleteDatabase(await path);
    await init();
  }

  Future<List<CatalogMetadata>> getAllMetadata() async {
    debugPrint('$runtimeType getAllMetadata');
    final db = await _database;
    final maps = await db.query(metadataTable);
    return maps.map((map) => CatalogMetadata.fromMap(map)).toList();
  }

  Future<CatalogMetadata> getMetadata(int contentId) async {
    debugPrint('$runtimeType getMetadata contentId=$contentId');
    final db = await _database;
    List<Map> maps = await db.query(metadataTable, where: 'contentId = ?', whereArgs: [contentId]);
    if (maps.length > 0) {
      return CatalogMetadata.fromMap(maps.first);
    }
    return null;
  }

  insertMetadata(CatalogMetadata metadata) async {
//    debugPrint('$runtimeType insertMetadata metadata=$metadata');
    final db = await _database;
    await db.insert(
      metadataTable,
      metadata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AddressDetails>> getAllAddresses() async {
    debugPrint('$runtimeType getAllAddresses');
    final db = await _database;
    final maps = await db.query(addressTable);
    return maps.map((map) => AddressDetails.fromMap(map)).toList();
  }

  Future<AddressDetails> getAddress(int contentId) async {
    debugPrint('$runtimeType getAddress contentId=$contentId');
    final db = await _database;
    List<Map> maps = await db.query(addressTable, where: 'contentId = ?', whereArgs: [contentId]);
    if (maps.length > 0) {
      return AddressDetails.fromMap(maps.first);
    }
    return null;
  }

  insertAddress(AddressDetails metadata) async {
//    debugPrint('$runtimeType insertAddress metadata=$metadata');
    final db = await _database;
    await db.insert(
      addressTable,
      metadata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
