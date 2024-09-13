import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class EntryHeroInfo extends Equatable {
  // hero tag should include a collection identifier, so that it animates
  // between different views of the entry in the same collection (e.g. thumbnails <-> viewer)
  // but not between different collection instances, even with the same attributes (e.g. reloading collection page via drawer)
  final CollectionLens? collection;
  final AvesEntry? entry;

  @override
  List<Object?> get props => [collection?.id, entry?.uri];

  const EntryHeroInfo(this.collection, this.entry);

  int get tag => Object.hashAll([collection?.id, entry?.uri]);
}
