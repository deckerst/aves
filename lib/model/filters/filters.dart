import 'dart:convert';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/aspect_ratio.dart';
import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/set_and.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/container/tag_group.dart';
import 'package:aves/model/filters/coordinate.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/missing.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/placeholder.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/filters/weekday.dart';
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
    SetAndFilter.type,
    SetOrFilter.type,
    MimeFilter.type,
    AlbumGroupFilter.type,
    TagGroupFilter.type,
    DynamicAlbumFilter.type,
    StoredAlbumFilter.type,
    TypeFilter.type,
    RecentlyAddedFilter.type,
    DateFilter.type,
    WeekDayFilter.type,
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
      case AlbumGroupFilter.type:
        return AlbumGroupFilter.fromMap(jsonMap);
      case TagGroupFilter.type:
        return TagGroupFilter.fromMap(jsonMap);
      case AspectRatioFilter.type:
        return AspectRatioFilter.fromMap(jsonMap);
      case CoordinateFilter.type:
        return CoordinateFilter.fromMap(jsonMap);
      case DateFilter.type:
        return DateFilter.fromMap(jsonMap);
      case DynamicAlbumFilter.type:
        return DynamicAlbumFilter.fromMap(jsonMap);
      case FavouriteFilter.type:
        return FavouriteFilter.fromMap(jsonMap);
      case LocationFilter.type:
        return LocationFilter.fromMap(jsonMap);
      case MimeFilter.type:
        return MimeFilter.fromMap(jsonMap);
      case MissingFilter.type:
        return MissingFilter.fromMap(jsonMap);
      case SetAndFilter.type:
        return SetAndFilter.fromMap(jsonMap);
      case SetOrFilter.type:
        return SetOrFilter.fromMap(jsonMap);
      case PathFilter.type:
        return PathFilter.fromMap(jsonMap);
      case PlaceholderFilter.type:
        return PlaceholderFilter.fromMap(jsonMap);
      case QueryFilter.type:
        return QueryFilter.fromMap(jsonMap);
      case RatingFilter.type:
        return RatingFilter.fromMap(jsonMap);
      case RecentlyAddedFilter.type:
        return RecentlyAddedFilter.fromMap(jsonMap);
      case StoredAlbumFilter.type:
        return StoredAlbumFilter.fromMap(jsonMap);
      case TagFilter.type:
        return TagFilter.fromMap(jsonMap);
      case TypeFilter.type:
        return TypeFilter.fromMap(jsonMap);
      case TrashFilter.type:
        return TrashFilter.fromMap(jsonMap);
      case WeekDayFilter.type:
        return WeekDayFilter.fromMap(jsonMap);
    }
    debugPrint('failed to deserialize filter from JSON map=$jsonMap');
    return null;
  }

  static CollectionFilter? fromJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is Map<String, dynamic>) {
        return _fromMap(jsonMap);
      }
      debugPrint('failed to parse filter from json=$jsonString');
    } catch (error) {
      // no need for stack
      debugPrint('failed to parse filter from json=$jsonString error=$error');
    }
    return null;
  }

  Map<String, dynamic> toMap();

  String toJson() => jsonEncode(toMap());

  EntryPredicate get positiveTest;

  EntryPredicate get test => reversed ? (v) => !positiveTest(v) : positiveTest;

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

  bool matchLabel(BuildContext context, String query) => getLabel(context).toUpperCase().contains(query);

  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => null;

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
class FilterGridItem<T extends CollectionFilter> with EquatableMixin {
  final T filter;
  final AvesEntry? entry;

  @override
  List<Object?> get props => [filter, entry?.uri];

  const FilterGridItem(this.filter, this.entry);
}

typedef EntryPredicate = bool Function(AvesEntry entry);
typedef CollectionFilterPredicate = bool Function(CollectionFilter filter);

abstract class DummyCollectionFilter extends CollectionFilter {
  const DummyCollectionFilter({required super.reversed});

  @override
  String get category => throw UnimplementedError();

  @override
  bool get exclusiveProp => throw UnimplementedError();

  @override
  String get key => throw UnimplementedError();

  @override
  EntryPredicate get positiveTest => throw UnimplementedError();

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  Map<String, dynamic> toMap() => throw UnimplementedError();

  @override
  String get universalLabel => throw UnimplementedError();
}
