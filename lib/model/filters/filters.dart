import 'dart:convert';

import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/aspect_ratio.dart';
import 'package:aves/model/filters/coordinate.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/missing.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/theme/colors.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

@immutable
abstract class CollectionFilter extends Equatable implements Comparable<CollectionFilter> {
  static const List<String> categoryOrder = [
    TrashFilter.type,
    QueryFilter.type,
    MimeFilter.type,
    AlbumFilter.type,
    TypeFilter.type,
    RecentlyAddedFilter.type,
    DateFilter.type,
    LocationFilter.type,
    CoordinateFilter.type,
    FavouriteFilter.type,
    RatingFilter.type,
    TagFilter.type,
    AspectRatioFilter.type,
    MissingFilter.type,
    PathFilter.type,
  ];

  final bool reversed;

  const CollectionFilter({required this.reversed});

  static CollectionFilter? _fromMap(Map<String, dynamic> jsonMap) {
    final type = jsonMap['type'];
    switch (type) {
      case AlbumFilter.type:
        return AlbumFilter.fromMap(jsonMap);
      case AspectRatioFilter.type:
        return AspectRatioFilter.fromMap(jsonMap);
      case CoordinateFilter.type:
        return CoordinateFilter.fromMap(jsonMap);
      case DateFilter.type:
        return DateFilter.fromMap(jsonMap);
      case FavouriteFilter.type:
        return FavouriteFilter.fromMap(jsonMap);
      case LocationFilter.type:
        return LocationFilter.fromMap(jsonMap);
      case MimeFilter.type:
        return MimeFilter.fromMap(jsonMap);
      case MissingFilter.type:
        return MissingFilter.fromMap(jsonMap);
      case PathFilter.type:
        return PathFilter.fromMap(jsonMap);
      case QueryFilter.type:
        return QueryFilter.fromMap(jsonMap);
      case RatingFilter.type:
        return RatingFilter.fromMap(jsonMap);
      case RecentlyAddedFilter.type:
        return RecentlyAddedFilter.fromMap(jsonMap);
      case TagFilter.type:
        return TagFilter.fromMap(jsonMap);
      case TypeFilter.type:
        return TypeFilter.fromMap(jsonMap);
      case TrashFilter.type:
        return TrashFilter.fromMap(jsonMap);
    }
    return null;
  }

  static CollectionFilter? fromJson(String jsonString) {
    if (jsonString.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is Map<String, dynamic>) {
        return _fromMap(jsonMap);
      }
    } catch (error, stack) {
      debugPrint('failed to parse filter from json=$jsonString error=$error\n$stack');
    }
    debugPrint('failed to parse filter from json=$jsonString');
    return null;
  }

  Map<String, dynamic> toMap();

  String toJson() => jsonEncode(toMap());

  EntryFilter get positiveTest;

  EntryFilter get test => reversed ? (v) => !positiveTest(v) : positiveTest;

  CollectionFilter reverse() => _fromMap(toMap()..['reversed'] = !reversed)!;

  bool get exclusiveProp;

  bool isCompatible(CollectionFilter other) {
    if (category != other.category) return true;
    if (!reversed && !other.reversed) return !exclusiveProp;
    if (reversed && other.reversed) return true;
    if (this == other.reverse()) return false;
    return true;
  }

  String get universalLabel;

  String getLabel(BuildContext context) => universalLabel;

  String getTooltip(BuildContext context) => getLabel(context);

  Widget? iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => null;

  Future<Color> color(BuildContext context) {
    final colors = context.read<AvesColorsData>();
    return SynchronousFuture(colors.fromString(getLabel(context)));
  }

  String get category;

  // to be used as widget key
  String get key;

  int get displayPriority => categoryOrder.indexOf(category);

  @override
  int compareTo(CollectionFilter other) {
    final c = displayPriority.compareTo(other.displayPriority);
    // assume we compare context-independent labels
    return c != 0 ? c : compareAsciiUpperCaseNatural(universalLabel, other.universalLabel);
  }
}

@immutable
abstract class CoveredCollectionFilter extends CollectionFilter {
  const CoveredCollectionFilter({required super.reversed});

  @override
  Future<Color> color(BuildContext context) {
    final customColor = covers.of(this)?.item3;
    if (customColor != null) {
      return SynchronousFuture(customColor);
    }
    return super.color(context);
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
