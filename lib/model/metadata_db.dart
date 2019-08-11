import 'package:aves/model/image_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final MetadataDb metadataDb = MetadataDb._private();

class MetadataDb {
  Future<Database> _database;

  Future<String> get path async => join(await getDatabasesPath(), 'metadata.db');

  static final table = 'metadata';

  MetadataDb._private();

  init() async {
    debugPrint('$runtimeType init');
    _database = openDatabase(
      await path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $table(contentId INTEGER PRIMARY KEY, dateMillis INTEGER, videoRotation INTEGER, xmpSubjects TEXT, latitude REAL, longitude REAL)',
        );
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

  Future<List<CatalogMetadata>> getAll() async {
    debugPrint('$runtimeType getAll');
    final db = await _database;
    final maps = await db.query(table);
    return maps.map((map) => CatalogMetadata.fromMap(map)).toList();
  }

  Future<CatalogMetadata> get(int contentId) async {
    debugPrint('$runtimeType get contentId=$contentId');
    final db = await _database;
    List<Map> maps = await db.query(table, where: 'contentId = ?', whereArgs: [contentId]);
    if (maps.length > 0) {
      return CatalogMetadata.fromMap(maps.first);
    }
    return null;
  }

  insert(CatalogMetadata metadata) async {
//    debugPrint('$runtimeType insert metadata=$metadata');
    final db = await _database;
    await db.insert(
      table,
      metadata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
