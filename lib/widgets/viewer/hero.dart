import 'package:aves/model/entry.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class HeroInfo extends Equatable {
  // hero tag should include a collection identifier, so that it animates
  // between different views of the entry in the same collection (e.g. thumbnails <-> viewer)
  // but not between different collection instances, even with the same attributes (e.g. reloading collection page via drawer)
  final int? collectionId;
  final AvesEntry? entry;

  @override
  List<Object?> get props => [collectionId, entry?.uri];

  const HeroInfo(this.collectionId, this.entry);
}
