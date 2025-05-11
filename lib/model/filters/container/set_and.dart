import 'package:aves/model/filters/container/container.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/theme/icons.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

// `AND` op for multiple filters
// can handle containing no filters
class SetAndFilter extends CollectionFilter with ContainerFilter {
  static const type = 'and';

  late final List<CollectionFilter> _filters;

  late final EntryPredicate _test;
  late final IconData? _genericIcon;

  @override
  List<Object?> get props => [_filters, reversed];

  CollectionFilter? get _first => _filters.firstOrNull;

  SetAndFilter(Set<CollectionFilter> filters, {super.reversed = false}) {
    _filters = filters.toList().sorted();
    _test = (entry) => _filters.every((v) => v.test(entry));
    switch (_first) {
      case StoredAlbumFilter():
        _genericIcon = AIcons.album;
      case LocationFilter(level: LocationLevel.country):
        _genericIcon = AIcons.country;
      case LocationFilter(level: LocationLevel.state):
        _genericIcon = AIcons.state;
      default:
        _genericIcon = null;
    }
  }

  static SetAndFilter? fromMap(Map<String, dynamic> json) {
    final filters = (json['filters'] as List).cast<String>().map(CollectionFilter.fromJson).nonNulls.toSet();
    if (filters.isEmpty) return null;

    return SetAndFilter(
      filters,
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'filters': _filters.map((v) => v.toJson()).toList(),
        'reversed': reversed,
      };

  @override
  EntryPredicate get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => _filters.map((v) => v.universalLabel).join(', ');

  @override
  String getLabel(BuildContext context) => _filters.map((v) => v.getLabel(context)).join(', ');

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return _genericIcon != null ? Icon(_genericIcon, size: size) : _first?.iconBuilder(context, size, allowGenericIcon: allowGenericIcon);
  }

  @override
  String get category => _first?.category ?? type;

  @override
  String get key => '$type-$reversed-${_filters.map((v) => v.key)}';

  // container

  @override
  Set<CollectionFilter> get innerFilters => _filters.toSet();

  @override
  SetAndFilter replaceFilters(CollectionFilter? Function(CollectionFilter oldFilter) toElement) {
    return SetAndFilter(
      _filters.map((v) => toElement(v)).nonNulls.toSet(),
      reversed: reversed,
    );
  }
}
