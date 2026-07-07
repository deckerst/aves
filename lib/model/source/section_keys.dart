import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class SectionKey {
  const SectionKey();
}

class EntryAlbumSectionKey extends SectionKey with Equatable {
  final String? directory;

  @override
  List<Object?> get props => [directory];

  const EntryAlbumSectionKey(this.directory);
}

class EntryDateSectionKey extends SectionKey with Equatable {
  final int? year, month, day;

  @override
  List<Object?> get props => [year, month, day];

  const EntryDateSectionKey({this.year, this.month, this.day});

  static const EntryDateSectionKey unknown = EntryDateSectionKey();
}

class EntryRatingSectionKey extends SectionKey with Equatable {
  final int rating;

  @override
  List<Object?> get props => [rating];

  const EntryRatingSectionKey(this.rating);
}
