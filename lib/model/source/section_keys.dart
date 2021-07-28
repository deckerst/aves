import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class SectionKey {
  const SectionKey();
}

class EntryAlbumSectionKey extends SectionKey with EquatableMixin {
  final String? directory;

  @override
  List<Object?> get props => [directory];

  const EntryAlbumSectionKey(this.directory);
}

class EntryDateSectionKey extends SectionKey with EquatableMixin {
  final DateTime? date;

  @override
  List<Object?> get props => [date];

  const EntryDateSectionKey(this.date);
}
