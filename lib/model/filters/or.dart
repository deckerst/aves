import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/theme/icons.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class OrFilter extends CollectionFilter {
  static const type = 'or';

  late final List<CollectionFilter> _filters;

  late final EntryFilter _test;
  late final IconData? _genericIcon;

  @override
  List<Object?> get props => [_filters, reversed];

  CollectionFilter get _first => _filters.first;

  OrFilter(Set<CollectionFilter> filters, {super.reversed = false}) {
    _filters = filters.toList().sorted();
    _test = (entry) => _filters.any((v) => v.test(entry));
    switch (_first) {
      case AlbumFilter():
        _genericIcon = AIcons.album;
      case LocationFilter(level: LocationLevel.country):
        _genericIcon = AIcons.country;
      case LocationFilter(level: LocationLevel.state):
        _genericIcon = AIcons.state;
      default:
        _genericIcon = null;
    }
  }

  factory OrFilter.fromMap(Map<String, dynamic> json) {
    return OrFilter(
      (json['filters'] as List).cast<String>().map(CollectionFilter.fromJson).whereNotNull().toSet(),
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
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => _filters.map((v) => v.universalLabel).join(', ');

  @override
  String getLabel(BuildContext context) => _filters.map((v) => v.getLabel(context)).join(', ');

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) {
    return _genericIcon != null ? Icon(_genericIcon, size: size) : _first.iconBuilder(context, size, showGenericIcon: showGenericIcon);
  }

  @override
  String get category => _first.category;

  @override
  String get key => '$type-$reversed-${_filters.map((v) => v.key)}';
}
