import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/group_base.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';

mixin GroupingConversion {
  static const _storedAlbumPath = '/stored';
  static const _dynamicAlbumPath = '/dynamic';
  static const _tagPath = '/tag';
  static const _nameParamKey = 'name';
  static const _storagePathParamKey = 'path';

  static CollectionFilter? uriToFilter(Uri uri) {
    switch (uri.path) {
      case _storedAlbumPath:
        final album = uri.queryParameters[_storagePathParamKey];
        if (album != null) {
          return StoredAlbumFilter(album, null);
        }
      case _dynamicAlbumPath:
        final name = uri.queryParameters[_nameParamKey];
        if (name != null) {
          return dynamicAlbums.get(name);
        }
      case _tagPath:
        final tag = uri.queryParameters[_nameParamKey];
        if (tag != null) {
          return TagFilter(tag);
        }
      default:
        throw Exception('unhandled path=${uri.path} with uri=$uri');
    }

    throw Exception('failed to convert to filter with uri=$uri');
  }

  static Uri? filterToUri(CollectionFilter filter) {
    switch (filter) {
      case GroupBaseFilter _:
        return filter.uri;
      case StoredAlbumFilter _:
        return _buildStoredAlbumUri(filter.album);
      case DynamicAlbumFilter _:
        return _buildDynamicAlbumUri(filter.name);
      case TagFilter _:
        return _buildTagUri(filter.tag);
      default:
        throw Exception('unknown type with filter=$filter');
    }
  }

  static Uri _buildStoredAlbumUri(String album) {
    return Uri(
      scheme: FilterGrouping.scheme,
      host: FilterGrouping.hostAlbums,
      path: _storedAlbumPath,
      queryParameters: {
        _storagePathParamKey: album,
      },
    );
  }

  static Uri _buildDynamicAlbumUri(String name) {
    return Uri(
      scheme: FilterGrouping.scheme,
      host: FilterGrouping.hostAlbums,
      path: _dynamicAlbumPath,
      queryParameters: {
        _nameParamKey: name,
      },
    );
  }

  static Uri _buildTagUri(String tag) {
    return Uri(
      scheme: FilterGrouping.scheme,
      host: FilterGrouping.hostTags,
      path: _tagPath,
      queryParameters: {
        _nameParamKey: tag,
      },
    );
  }
}
