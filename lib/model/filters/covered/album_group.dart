import 'package:aves/model/filters/covered/group_base.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/set_or.dart';

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
    final filter = CollectionFilter.fromJson(json['filter']);
    if (filter == null || filter is! SetOrFilter) return null;

    final uriString = json['uri'];
    final uri = uriString is String ? Uri.tryParse(uriString) : null;
    if (uri == null) return null;

    return AlbumGroupFilter(
      uri,
      filter,
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'uri': uri.toString(),
        'filter': filter.toJson(),
        'reversed': reversed,
      };

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$uri';
}
