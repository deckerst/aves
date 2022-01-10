import 'dart:convert';

import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/coordinate.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class CollectionFilter extends Equatable implements Comparable<CollectionFilter> {
  static const List<String> categoryOrder = [
    QueryFilter.type,
    MimeFilter.type,
    AlbumFilter.type,
    TypeFilter.type,
    LocationFilter.type,
    CoordinateFilter.type,
    FavouriteFilter.type,
    RatingFilter.type,
    TagFilter.type,
    PathFilter.type,
  ];

  static CollectionFilter? fromJson(String jsonString) {
    if (jsonString.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is Map<String, dynamic>) {
        final type = jsonMap['type'];
        switch (type) {
          case AlbumFilter.type:
            return AlbumFilter.fromMap(jsonMap);
          case CoordinateFilter.type:
            return CoordinateFilter.fromMap(jsonMap);
          case FavouriteFilter.type:
            return FavouriteFilter.instance;
          case LocationFilter.type:
            return LocationFilter.fromMap(jsonMap);
          case MimeFilter.type:
            return MimeFilter.fromMap(jsonMap);
          case PathFilter.type:
            return PathFilter.fromMap(jsonMap);
          case QueryFilter.type:
            return QueryFilter.fromMap(jsonMap);
          case RatingFilter.type:
            return RatingFilter.fromMap(jsonMap);
          case TagFilter.type:
            return TagFilter.fromMap(jsonMap);
          case TypeFilter.type:
            return TypeFilter.fromMap(jsonMap);
        }
      }
    } catch (error, stack) {
      debugPrint('failed to parse filter from json=$jsonString error=$error\n$stack');
    }
    debugPrint('failed to parse filter from json=$jsonString');
    return null;
  }

  const CollectionFilter();

  Map<String, dynamic> toMap();

  String toJson() => jsonEncode(toMap());

  EntryFilter get test;

  bool get isUnique => true;

  String get universalLabel;

  String getLabel(BuildContext context) => universalLabel;

  String getTooltip(BuildContext context) => getLabel(context);

  Widget? iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => null;

  Future<Color> color(BuildContext context) => SynchronousFuture(stringToColor(getLabel(context)));

  String get category;

  // to be used as widget key
  String get key;

  int get displayPriority => categoryOrder.indexOf(category);

  @override
  int compareTo(CollectionFilter other) {
    final c = displayPriority.compareTo(other.displayPriority);
    // assume we compare context-independent labels
    return c != 0 ? c : compareAsciiUpperCase(universalLabel, other.universalLabel);
  }
}

@immutable
class FilterGridItem<T extends CollectionFilter> with EquatableMixin {
  final T filter;
  final AvesEntry? entry;

  @override
  List<Object?> get props => [filter, entry?.uri];

  const FilterGridItem(this.filter, this.entry);
}

typedef EntryFilter = bool Function(AvesEntry);
