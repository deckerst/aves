import 'package:aves/model/filters/container/group_base.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/filters.dart';

mixin AlbumBaseFilter on CollectionFilter {}

// placeholder to pick a group, distinguishing this root filter from cancelling
class _RootAlbumGroupFilter extends DummyCollectionFilter with AlbumBaseFilter {
  _RootAlbumGroupFilter._private({required super.reversed});
}

class AlbumGroupFilter extends GroupBaseFilter with AlbumBaseFilter {
  static const type = 'album_group';

  static AlbumBaseFilter root = _RootAlbumGroupFilter._private(reversed: false);

  AlbumGroupFilter(super.uri, super.filter, {super.reversed = false});

  factory AlbumGroupFilter.empty(Uri uri) => AlbumGroupFilter(uri, SetOrFilter(const {}));

  static AlbumGroupFilter? fromMap(Map<String, dynamic> json) {
    final props = GroupBaseFilter.fromMap(json);
    if (props == null) return null;

    final (uri, filter, reversed) = props;
    return AlbumGroupFilter(uri, filter, reversed: reversed);
  }

  @override
  String get category => type;

  // container

  @override
  AlbumGroupFilter? replaceFilters(CollectionFilter? Function(CollectionFilter oldFilter) toElement) {
    return AlbumGroupFilter(
      uri,
      filter.replaceFilters(toElement),
      reversed: reversed,
    );
  }
}
