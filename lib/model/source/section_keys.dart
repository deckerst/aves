import 'package:flutter/foundation.dart';

class SectionKey {
  const SectionKey();
}

class EntryAlbumSectionKey extends SectionKey {
  final String folderPath;

  const EntryAlbumSectionKey(this.folderPath);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is EntryAlbumSectionKey && other.folderPath == folderPath;
  }

  @override
  int get hashCode => folderPath.hashCode;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{folderPath=$folderPath}';
}

class EntryDateSectionKey extends SectionKey {
  final DateTime date;

  const EntryDateSectionKey(this.date);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is EntryDateSectionKey && other.date == date;
  }

  @override
  int get hashCode => date.hashCode;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{date=$date}';
}
