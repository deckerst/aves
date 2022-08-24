import 'package:aves/model/db/db_metadata_sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class MetadataDbUpgrader {
  static const entryTable = SqfliteMetadataDb.entryTable;
  static const dateTakenTable = SqfliteMetadataDb.dateTakenTable;
  static const metadataTable = SqfliteMetadataDb.metadataTable;
  static const addressTable = SqfliteMetadataDb.addressTable;
  static const favouriteTable = SqfliteMetadataDb.favouriteTable;
  static const coverTable = SqfliteMetadataDb.coverTable;
  static const trashTable = SqfliteMetadataDb.trashTable;
  static const videoPlaybackTable = SqfliteMetadataDb.videoPlaybackTable;

  // warning: "ALTER TABLE ... RENAME COLUMN ..." is not supported
  // on SQLite <3.25.0, bundled on older Android devices
  static Future<void> upgradeDb(Database db, int oldVersion, int newVersion) async {
    while (oldVersion < newVersion) {
      switch (oldVersion) {
        case 1:
          await _upgradeFrom1(db);
          break;
        case 2:
          await _upgradeFrom2(db);
          break;
        case 3:
          await _upgradeFrom3(db);
          break;
        case 4:
          await _upgradeFrom4(db);
          break;
        case 5:
          await _upgradeFrom5(db);
          break;
        case 6:
          await _upgradeFrom6(db);
          break;
        case 7:
          await _upgradeFrom7(db);
          break;
        case 8:
          await _upgradeFrom8(db);
          break;
      }
      oldVersion++;
    }
  }

  static Future<void> _upgradeFrom1(Database db) async {
    debugPrint('upgrading DB from v1');
    // rename column 'orientationDegrees' to 'sourceRotationDegrees'
    await db.transaction((txn) async {
      const newEntryTable = '${entryTable}TEMP';
      await db.execute('CREATE TABLE $newEntryTable('
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
      await db.rawInsert('INSERT INTO $newEntryTable(contentId,uri,path,sourceMimeType,width,height,sourceRotationDegrees,sizeBytes,title,dateModifiedSecs,sourceDateTakenMillis,durationMillis)'
          ' SELECT contentId,uri,path,sourceMimeType,width,height,orientationDegrees,sizeBytes,title,dateModifiedSecs,sourceDateTakenMillis,durationMillis'
          ' FROM $entryTable;');
      await db.execute('DROP TABLE $entryTable;');
      await db.execute('ALTER TABLE $newEntryTable RENAME TO $entryTable;');
    });

    // rename column 'videoRotation' to 'rotationDegrees'
    await db.transaction((txn) async {
      const newMetadataTable = '${metadataTable}TEMP';
      await db.execute('CREATE TABLE $newMetadataTable('
          'contentId INTEGER PRIMARY KEY'
          ', mimeType TEXT'
          ', dateMillis INTEGER'
          ', isAnimated INTEGER'
          ', rotationDegrees INTEGER'
          ', xmpSubjects TEXT'
          ', xmpTitleDescription TEXT'
          ', latitude REAL'
          ', longitude REAL'
          ')');
      await db.rawInsert('INSERT INTO $newMetadataTable(contentId,mimeType,dateMillis,isAnimated,rotationDegrees,xmpSubjects,xmpTitleDescription,latitude,longitude)'
          ' SELECT contentId,mimeType,dateMillis,isAnimated,videoRotation,xmpSubjects,xmpTitleDescription,latitude,longitude'
          ' FROM $metadataTable;');
      await db.rawInsert('UPDATE $newMetadataTable SET rotationDegrees = NULL WHERE rotationDegrees = 0;');
      await db.execute('DROP TABLE $metadataTable;');
      await db.execute('ALTER TABLE $newMetadataTable RENAME TO $metadataTable;');
    });

    // new column 'isFlipped'
    await db.execute('ALTER TABLE $metadataTable ADD COLUMN isFlipped INTEGER;');
  }

  static Future<void> _upgradeFrom2(Database db) async {
    debugPrint('upgrading DB from v2');
    // merge columns 'isAnimated' and 'isFlipped' into 'flags'
    await db.transaction((txn) async {
      const newMetadataTable = '${metadataTable}TEMP';
      await db.execute('CREATE TABLE $newMetadataTable('
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
      await db.rawInsert('INSERT INTO $newMetadataTable(contentId,mimeType,dateMillis,flags,rotationDegrees,xmpSubjects,xmpTitleDescription,latitude,longitude)'
          ' SELECT contentId,mimeType,dateMillis,ifnull(isAnimated,0)+ifnull(isFlipped,0)*2,rotationDegrees,xmpSubjects,xmpTitleDescription,latitude,longitude'
          ' FROM $metadataTable;');
      await db.execute('DROP TABLE $metadataTable;');
      await db.execute('ALTER TABLE $newMetadataTable RENAME TO $metadataTable;');
    });
  }

  static Future<void> _upgradeFrom3(Database db) async {
    debugPrint('upgrading DB from v3');
    await db.execute('CREATE TABLE $coverTable('
        'filter TEXT PRIMARY KEY'
        ', contentId INTEGER'
        ')');
  }

  static Future<void> _upgradeFrom4(Database db) async {
    debugPrint('upgrading DB from v4');
    await db.execute('CREATE TABLE $videoPlaybackTable('
        'contentId INTEGER PRIMARY KEY'
        ', resumeTimeMillis INTEGER'
        ')');
  }

  static Future<void> _upgradeFrom5(Database db) async {
    debugPrint('upgrading DB from v5');
    await db.execute('ALTER TABLE $metadataTable ADD COLUMN rating INTEGER;');
  }

  static Future<void> _upgradeFrom6(Database db) async {
    debugPrint('upgrading DB from v6');
    // new primary key column `id` instead of `contentId`
    // new column `trashed`
    await db.transaction((txn) async {
      const newEntryTable = '${entryTable}TEMP';
      await db.execute('CREATE TABLE $newEntryTable('
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
      await db.rawInsert('INSERT INTO $newEntryTable(id,contentId,uri,path,sourceMimeType,width,height,sourceRotationDegrees,sizeBytes,title,dateModifiedSecs,sourceDateTakenMillis,durationMillis)'
          ' SELECT contentId,contentId,uri,path,sourceMimeType,width,height,sourceRotationDegrees,sizeBytes,title,dateModifiedSecs,sourceDateTakenMillis,durationMillis'
          ' FROM $entryTable;');
      await db.execute('DROP TABLE $entryTable;');
      await db.execute('ALTER TABLE $newEntryTable RENAME TO $entryTable;');
    });

    // rename column `contentId` to `id`
    await db.transaction((txn) async {
      const newDateTakenTable = '${dateTakenTable}TEMP';
      await db.execute('CREATE TABLE $newDateTakenTable('
          'id INTEGER PRIMARY KEY'
          ', dateMillis INTEGER'
          ')');
      await db.rawInsert('INSERT INTO $newDateTakenTable(id,dateMillis)'
          ' SELECT contentId,dateMillis'
          ' FROM $dateTakenTable;');
      await db.execute('DROP TABLE $dateTakenTable;');
      await db.execute('ALTER TABLE $newDateTakenTable RENAME TO $dateTakenTable;');
    });

    // rename column `contentId` to `id`
    await db.transaction((txn) async {
      const newMetadataTable = '${metadataTable}TEMP';
      await db.execute('CREATE TABLE $newMetadataTable('
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
      await db.rawInsert('INSERT INTO $newMetadataTable(id,mimeType,dateMillis,flags,rotationDegrees,xmpSubjects,xmpTitleDescription,latitude,longitude,rating)'
          ' SELECT contentId,mimeType,dateMillis,flags,rotationDegrees,xmpSubjects,xmpTitleDescription,latitude,longitude,rating'
          ' FROM $metadataTable;');
      await db.execute('DROP TABLE $metadataTable;');
      await db.execute('ALTER TABLE $newMetadataTable RENAME TO $metadataTable;');
    });

    // rename column `contentId` to `id`
    await db.transaction((txn) async {
      const newAddressTable = '${addressTable}TEMP';
      await db.execute('CREATE TABLE $newAddressTable('
          'id INTEGER PRIMARY KEY'
          ', addressLine TEXT'
          ', countryCode TEXT'
          ', countryName TEXT'
          ', adminArea TEXT'
          ', locality TEXT'
          ')');
      await db.rawInsert('INSERT INTO $newAddressTable(id,addressLine,countryCode,countryName,adminArea,locality)'
          ' SELECT contentId,addressLine,countryCode,countryName,adminArea,locality'
          ' FROM $addressTable;');
      await db.execute('DROP TABLE $addressTable;');
      await db.execute('ALTER TABLE $newAddressTable RENAME TO $addressTable;');
    });

    // rename column `contentId` to `id`
    await db.transaction((txn) async {
      const newVideoPlaybackTable = '${videoPlaybackTable}TEMP';
      await db.execute('CREATE TABLE $newVideoPlaybackTable('
          'id INTEGER PRIMARY KEY'
          ', resumeTimeMillis INTEGER'
          ')');
      await db.rawInsert('INSERT INTO $newVideoPlaybackTable(id,resumeTimeMillis)'
          ' SELECT contentId,resumeTimeMillis'
          ' FROM $videoPlaybackTable;');
      await db.execute('DROP TABLE $videoPlaybackTable;');
      await db.execute('ALTER TABLE $newVideoPlaybackTable RENAME TO $videoPlaybackTable;');
    });

    // rename column `contentId` to `id`
    // remove column `path`
    await db.transaction((txn) async {
      const newFavouriteTable = '${favouriteTable}TEMP';
      await db.execute('CREATE TABLE $newFavouriteTable('
          'id INTEGER PRIMARY KEY'
          ')');
      await db.rawInsert('INSERT INTO $newFavouriteTable(id)'
          ' SELECT contentId'
          ' FROM $favouriteTable;');
      await db.execute('DROP TABLE $favouriteTable;');
      await db.execute('ALTER TABLE $newFavouriteTable RENAME TO $favouriteTable;');
    });

    // rename column `contentId` to `entryId`
    await db.transaction((txn) async {
      const newCoverTable = '${coverTable}TEMP';
      await db.execute('CREATE TABLE $newCoverTable('
          'filter TEXT PRIMARY KEY'
          ', entryId INTEGER'
          ')');
      await db.rawInsert('INSERT INTO $newCoverTable(filter,entryId)'
          ' SELECT filter,contentId'
          ' FROM $coverTable;');
      await db.execute('DROP TABLE $coverTable;');
      await db.execute('ALTER TABLE $newCoverTable RENAME TO $coverTable;');
    });

    // new table
    await db.execute('CREATE TABLE $trashTable('
        'id INTEGER PRIMARY KEY'
        ', path TEXT'
        ', dateMillis INTEGER'
        ')');
  }

  static Future<void> _upgradeFrom7(Database db) async {
    debugPrint('upgrading DB from v7');
    await db.execute('ALTER TABLE $coverTable ADD COLUMN packageName TEXT;');
    await db.execute('ALTER TABLE $coverTable ADD COLUMN color INTEGER;');
  }

  static Future<void> _upgradeFrom8(Database db) async {
    debugPrint('upgrading DB from v8');

    // new column `dateAddedSecs`
    await db.transaction((txn) async {
      const newEntryTable = '${entryTable}TEMP';
      await db.execute('CREATE TABLE $newEntryTable('
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
          ', dateModifiedSecs INTEGER'
          ', sourceDateTakenMillis INTEGER'
          ', durationMillis INTEGER'
          ', trashed INTEGER DEFAULT 0'
          ')');
      await db.rawInsert('INSERT INTO $newEntryTable(id,contentId,uri,path,sourceMimeType,width,height,sourceRotationDegrees,sizeBytes,title,dateModifiedSecs,sourceDateTakenMillis,durationMillis,trashed)'
          ' SELECT id,contentId,uri,path,sourceMimeType,width,height,sourceRotationDegrees,sizeBytes,title,dateModifiedSecs,sourceDateTakenMillis,durationMillis,trashed'
          ' FROM $entryTable;');
      await db.execute('DROP TABLE $entryTable;');
      await db.execute('ALTER TABLE $newEntryTable RENAME TO $entryTable;');
    });

    // rename column `xmpTitleDescription` to `xmpTitle`
    await db.transaction((txn) async {
      const newMetadataTable = '${metadataTable}TEMP';
      await db.execute('CREATE TABLE $newMetadataTable('
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
      await db.rawInsert('INSERT INTO $newMetadataTable(id,mimeType,dateMillis,flags,rotationDegrees,xmpSubjects,xmpTitle,latitude,longitude,rating)'
          ' SELECT id,mimeType,dateMillis,flags,rotationDegrees,xmpSubjects,xmpTitleDescription,latitude,longitude,rating'
          ' FROM $metadataTable;');
      await db.execute('DROP TABLE $metadataTable;');
      await db.execute('ALTER TABLE $newMetadataTable RENAME TO $metadataTable;');
    });
  }
}
