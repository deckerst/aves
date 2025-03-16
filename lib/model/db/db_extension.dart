import 'package:sqflite/sqflite.dart';

extension ExtraDatabase on Database {
  // check table existence
  // proper way is to select from `sqlite_master` but this meta table may be missing on some devices
  // so we rely on failure check instead
  bool tableExists(String table) {
    try {
      query(table, limit: 1);
      return true;
    } catch (error) {
      return false;
    }
  }
}
