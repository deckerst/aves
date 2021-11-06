import 'package:aves/model/metadata_db.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class MetadataDbUpgrader {
  static const entryTable = SqfliteMetadataDb.entryTable;
  static const metadataTable = SqfliteMetadataDb.metadataTable;
  static const coverTable = SqfliteMetadataDb.coverTable;
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
}
