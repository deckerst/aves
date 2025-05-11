import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/container.dart';
import 'package:aves/model/filters/covered/covered.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/widgets.dart';

// a dynamic album can act as:
// - an alias, when inner filter is a simple filter,
// - a combination, when inner filter is a container.
class DynamicAlbumFilter extends CollectionFilter with ContainerFilter, CoveredFilter, AlbumBaseFilter {
  static const type = 'dynamic_album';

  final String name;
  final CollectionFilter filter;

  @override
  List<Object?> get props => [name, filter, reversed];

  DynamicAlbumFilter(this.name, this.filter, {super.reversed = false});

  static DynamicAlbumFilter? fromMap(Map<String, dynamic> json) {
    final filter = CollectionFilter.fromJson(json['filter']);
    if (filter == null) return null;

    return DynamicAlbumFilter(
      json['name'],
      filter,
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'name': name,
        'filter': filter.toJson(),
        'reversed': reversed,
      };

  @override
  EntryPredicate get positiveTest => filter.test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => name;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return allowGenericIcon ? Icon(AIcons.dynamicAlbum, size: size) : null;
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$name';

  // container

  @override
  Set<CollectionFilter> get innerFilters => {filter};

  @override
  DynamicAlbumFilter? replaceFilters(CollectionFilter? Function(CollectionFilter oldFilter) toElement) {
    final newFilter = toElement(filter);
    return newFilter != null
        ? DynamicAlbumFilter(
            name,
            newFilter,
            reversed: reversed,
          )
        : null;
  }
}
