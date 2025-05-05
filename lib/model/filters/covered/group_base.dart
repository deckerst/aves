import 'package:aves/model/filters/covered/covered.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/set_or.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/widgets.dart';

abstract class GroupBaseFilter extends CollectionFilter with CoveredFilter {
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
  EntryFilter get positiveTest => filter.test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => _name;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return allowGenericIcon ? Icon(AIcons.group, size: size) : null;
  }
}
