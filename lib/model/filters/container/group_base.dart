import 'package:aves/model/filters/container/container.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/covered/covered.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/widgets.dart';

abstract class GroupBaseFilter extends CollectionFilter with ContainerFilter, CoveredFilter {
  final Uri uri;
  final SetOrFilter filter;
  late final String _name;

  // do not include contextual `filter` to `props`
  // stringify URI because its runtime type is undetermined and different types falsify equality checks
  @override
  List<Object?> get props => [uri.toString(), reversed];

  GroupBaseFilter(this.uri, this.filter, {super.reversed = false}) {
    _name = FilterGrouping.getGroupName(uri) ?? '';
  }

  @override
  EntryPredicate get positiveTest => filter.test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => _name;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return allowGenericIcon ? Icon(AIcons.group, size: size) : null;
  }

  @override
  String get key => '$category-$reversed-$uri';

  // container

  @override
  Set<CollectionFilter> get innerFilters => {filter};

  // serialization

  static (Uri, SetOrFilter, bool)? fromMap(Map<String, dynamic> json) {
    final filter = CollectionFilter.fromJson(json['filter']);
    if (filter == null || filter is! SetOrFilter) return null;

    final uriString = json['uri'];
    final uri = uriString is String ? Uri.tryParse(uriString) : null;
    if (uri == null) return null;

    final reversed = json['reversed'] ?? false;
    return (uri, filter, reversed);
  }

  @override
  Map<String, dynamic> toMap() => {
    'type': category,
    'uri': uri.toString(),
    'filter': filter.toJson(),
    'reversed': reversed,
  };
}
