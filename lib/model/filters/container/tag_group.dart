import 'package:aves/model/filters/container/group_base.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/filters.dart';

mixin TagBaseFilter on CollectionFilter {}

// placeholder to pick a group, distinguishing this root filter from cancelling
class _RootTagGroupFilter extends DummyCollectionFilter with TagBaseFilter {
  _RootTagGroupFilter._private({required super.reversed});
}

class TagGroupFilter extends GroupBaseFilter with TagBaseFilter {
  static const type = 'tag_group';

  static TagBaseFilter root = _RootTagGroupFilter._private(reversed: false);

  TagGroupFilter(super.uri, super.filter, {super.reversed = false});

  factory TagGroupFilter.empty(Uri uri) => TagGroupFilter(uri, SetOrFilter(const {}));

  static TagGroupFilter? fromMap(Map<String, dynamic> json) {
    final props = GroupBaseFilter.fromMap(json);
    if (props == null) return null;

    final (uri, filter, reversed) = props;
    return TagGroupFilter(uri, filter, reversed: reversed);
  }

  @override
  String get category => type;

  // container

  @override
  TagGroupFilter? replaceFilters(CollectionFilter? Function(CollectionFilter oldFilter) toElement) {
    return TagGroupFilter(
      uri,
      filter.replaceFilters(toElement),
      reversed: reversed,
    );
  }
}
