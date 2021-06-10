import 'package:aves/model/entry.dart';
import 'package:flutter/widgets.dart';

class HeroInfo {
  // hero tag should include a collection identifier, so that it animates
  // between different views of the entry in the same collection (e.g. thumbnails <-> viewer)
  // but not between different collection instances, even with the same attributes (e.g. reloading collection page via drawer)
  final int? collectionId;
  final AvesEntry? entry;

  const HeroInfo(this.collectionId, this.entry);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is HeroInfo && other.collectionId == collectionId && other.entry == entry;
  }

  @override
  int get hashCode => hashValues(collectionId, entry);
}
