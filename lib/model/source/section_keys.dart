import 'package:flutter/foundation.dart';

class SectionKey {
  const SectionKey();
}

class EntryAlbumSectionKey extends SectionKey {
  final String? directory;

  const EntryAlbumSectionKey(this.directory);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is EntryAlbumSectionKey && other.directory == directory;
  }

  @override
  int get hashCode => directory.hashCode;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{directory=$directory}';
}

class EntryDateSectionKey extends SectionKey {
  final DateTime? date;

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
