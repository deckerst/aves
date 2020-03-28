import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/country.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/gif.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/video.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class CollectionFilter implements Comparable<CollectionFilter> {
  static const List<String> collectionFilterOrder = [
    QueryFilter.type,
    FavouriteFilter.type,
    VideoFilter.type,
    GifFilter.type,
    AlbumFilter.type,
    CountryFilter.type,
    TagFilter.type,
  ];

  const CollectionFilter();

  bool filter(ImageEntry entry);

  String get label;

  String get tooltip => label;

  Widget iconBuilder(BuildContext context, double size);

  Future<Color> color(BuildContext context) => SynchronousFuture(stringToColor(label));

  String get typeKey;

  int get displayPriority => collectionFilterOrder.indexOf(typeKey);

  @override
  int compareTo(CollectionFilter other) {
    final c = displayPriority.compareTo(other.displayPriority);
    return c != 0 ? c : compareAsciiUpperCase(label, other.label);
  }
}
