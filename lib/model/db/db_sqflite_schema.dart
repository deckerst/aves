import 'package:sqflite/sqflite.dart';

class SqfliteLocalMediaDbSchema {
  static const entryTable = 'entry';
  static const dateTakenTable = 'dateTaken';
  static const metadataTable = 'metadata';
  static const addressTable = 'address';
  static const favouriteTable = 'favourites';
  static const coverTable = 'covers';
  static const dynamicAlbumTable = 'dynamicAlbums';
  static const vaultTable = 'vaults';
  static const trashTable = 'trash';
  static const videoPlaybackTable = 'videoPlayback';

  static const allTables = [
    entryTable,
    dateTakenTable,
    metadataTable,
    addressTable,
    favouriteTable,
    coverTable,
    dynamicAlbumTable,
    vaultTable,
    trashTable,
    videoPlaybackTable,
  ];

  static Future<void> createLatestVersion(Database db) async {
    await Future.forEach(allTables, (table) => createTable(db, table));
  }

  static Future<void> createTable(Database db, String table) {
    switch (table) {
      case entryTable:
        return db.execute('CREATE TABLE $entryTable('
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
            ', dateAddedSecs INTEGER DEFAULT (strftime(\'%s\',\'now\'))'
            ', dateModifiedMillis INTEGER'
            ', sourceDateTakenMillis INTEGER'
            ', durationMillis INTEGER'
            ', trashed INTEGER DEFAULT 0'
            ', origin INTEGER DEFAULT 0'
            ')');
      case dateTakenTable:
        return db.execute('CREATE TABLE $dateTakenTable('
            'id INTEGER PRIMARY KEY'
            ', dateMillis INTEGER'
            ')');
      case metadataTable:
        return db.execute('CREATE TABLE $metadataTable('
            'id INTEGER PRIMARY KEY'
            ', mimeType TEXT'
            ', dateMillis INTEGER'
            ', flags INTEGER'
            ', rotationDegrees INTEGER'
            ', xmpSubjects TEXT'
            ', xmpTitle TEXT'
            ', latitude REAL'
            ', longitude REAL'
            ', rating INTEGER'
            ')');
      case addressTable:
        return db.execute('CREATE TABLE $addressTable('
            'id INTEGER PRIMARY KEY'
            ', addressLine TEXT'
            ', countryCode TEXT'
            ', countryName TEXT'
            ', adminArea TEXT'
            ', locality TEXT'
            ')');
      case favouriteTable:
        return db.execute('CREATE TABLE $favouriteTable('
            'id INTEGER PRIMARY KEY'
            ')');
      case coverTable:
        return db.execute('CREATE TABLE $coverTable('
            'filter TEXT PRIMARY KEY'
            ', entryId INTEGER'
            ', packageName TEXT'
            ', color TEXT'
            ')');
      case dynamicAlbumTable:
        return db.execute('CREATE TABLE $dynamicAlbumTable('
            'name TEXT PRIMARY KEY'
            ', filter TEXT'
            ')');
      case vaultTable:
        return db.execute('CREATE TABLE $vaultTable('
            'name TEXT PRIMARY KEY'
            ', autoLock INTEGER'
            ', useBin INTEGER'
            ', lockType TEXT'
            ')');
      case trashTable:
        return db.execute('CREATE TABLE $trashTable('
            'id INTEGER PRIMARY KEY'
            ', path TEXT'
            ', dateMillis INTEGER'
            ')');
      case videoPlaybackTable:
        return db.execute('CREATE TABLE $videoPlaybackTable('
            'id INTEGER PRIMARY KEY'
            ', resumeTimeMillis INTEGER'
            ')');
      default:
        throw Exception('unknown table=$table');
    }
  }
}
