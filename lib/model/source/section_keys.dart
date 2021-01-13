import 'package:flutter/foundation.dart';

class SectionKey {
  const SectionKey();
}

class AlbumSectionKey extends SectionKey {
  final String folderPath;

  const AlbumSectionKey(this.folderPath);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AlbumSectionKey && other.folderPath == folderPath;
  }

  @override
  int get hashCode => folderPath.hashCode;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{folderPath=$folderPath}';
}

class DateSectionKey extends SectionKey {
  final DateTime date;

  const DateSectionKey(this.date);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is DateSectionKey && other.date == date;
  }

  @override
  int get hashCode => date.hashCode;

  @override
  String toString() => '$runtimeType#${shortHash(this)}{date=$date}';
}
