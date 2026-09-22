import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class const EntryHeroInfo(
  final CollectionLens? collection,
  final AvesEntry? entry,
) extends Equatable {
  @override
  List<Object?> get props => [collection?.id, entry?.uri];

  // hero tag should include a collection identifier, so that it animates
  // between different views of the entry in the same collection (e.g. thumbnails <-> viewer)
  // but not between different collection instances, even with the same attributes (e.g. reloading collection page via drawer)
  int get tag => Object.hashAll([collection?.id, entry?.uri]);
}
