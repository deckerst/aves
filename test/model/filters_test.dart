import 'package:aves/model/filters/aspect_ratio.dart';
import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/set_and.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/coordinate.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/missing.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/placeholder.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/filters/weekday.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';

import '../common.dart';
import '../fake/media_store_service.dart';
import '../fake/storage_service.dart';

void main() {
  setUpAll(() async {
    await setUpAllServices();
  });

  setUp(() async {
    await setUpServices();
  });

  tearDownAll(() async {
    await tearDownAllServices();
  });

  test('Filter serialization', () {
    CollectionFilter? jsonMapRoundTrip(CollectionFilter filter) => CollectionFilter.fromJson(filter.toJsonMap());
    CollectionFilter? jsonStringRoundTrip(CollectionFilter filter) => CollectionFilter.fromJson(filter.toJsonString());

    final aspectRatio = AspectRatioFilter.landscape;
    expect(aspectRatio, jsonMapRoundTrip(aspectRatio));
    expect(aspectRatio, jsonStringRoundTrip(aspectRatio));

    final bounds = CoordinateFilter(const LatLng(29.979167, 28.223615), const LatLng(36.451000, 31.134167));
    expect(bounds, jsonMapRoundTrip(bounds));
    expect(bounds, jsonStringRoundTrip(bounds));

    final date = DateFilter(DateLevel.ym, DateTime(1969, 7));
    expect(date, jsonMapRoundTrip(date));
    expect(date, jsonStringRoundTrip(date));

    final onThisDay = DateFilter.onThisDay;
    expect(onThisDay, jsonMapRoundTrip(onThisDay));
    expect(onThisDay, jsonStringRoundTrip(onThisDay));

    const fav = FavouriteFilter.instance;
    expect(fav, jsonMapRoundTrip(fav));
    expect(fav, jsonStringRoundTrip(fav));

    final mime = MimeFilter.video;
    expect(mime, jsonMapRoundTrip(mime));
    expect(mime, jsonStringRoundTrip(mime));

    final missing = MissingFilter.title;
    expect(missing, jsonMapRoundTrip(missing));
    expect(missing, jsonStringRoundTrip(missing));

    final path = PathFilter('/some/path/');
    expect(path, jsonMapRoundTrip(path));
    expect(path, jsonStringRoundTrip(path));

    final placeholder = PlaceholderFilter.country;
    expect(placeholder, jsonMapRoundTrip(placeholder));
    expect(placeholder, jsonStringRoundTrip(placeholder));

    final query = QueryFilter('some query');
    expect(query, jsonMapRoundTrip(query));
    expect(query, jsonStringRoundTrip(query));

    final rating = RatingFilter(3);
    expect(rating, jsonMapRoundTrip(rating));
    expect(rating, jsonStringRoundTrip(rating));

    final recent = RecentlyAddedFilter.instance;
    expect(recent, jsonMapRoundTrip(recent));
    expect(recent, jsonStringRoundTrip(recent));

    final type = TypeFilter.sphericalVideo;
    expect(type, jsonMapRoundTrip(type));
    expect(type, jsonStringRoundTrip(type));

    final weekday = WeekDayFilter(5);
    expect(weekday, jsonMapRoundTrip(weekday));
    expect(weekday, jsonStringRoundTrip(weekday));

    // covered

    final album = StoredAlbumFilter('path/to/album', 'album');
    expect(album, jsonMapRoundTrip(album));
    expect(album, jsonStringRoundTrip(album));

    final location = LocationFilter(LocationLevel.country, 'France${LocationFilter.locationSeparator}FR');
    expect(location, jsonMapRoundTrip(location));
    expect(location, jsonStringRoundTrip(location));

    final tag = TagFilter('some tag');
    expect(tag, jsonMapRoundTrip(tag));
    expect(tag, jsonStringRoundTrip(tag));

    // combinations

    final setAnd = SetAndFilter({album, location, tag});
    expect(setAnd, jsonMapRoundTrip(setAnd));
    expect(setAnd, jsonStringRoundTrip(setAnd));

    final setOr = SetOrFilter({album, location, tag});
    expect(setOr, jsonMapRoundTrip(setOr));
    expect(setOr, jsonStringRoundTrip(setOr));

    final dynamicAlbum = DynamicAlbumFilter('dynamic album', setAnd);
    expect(dynamicAlbum, jsonMapRoundTrip(dynamicAlbum));
    expect(dynamicAlbum, jsonStringRoundTrip(dynamicAlbum));

    // groups

    final albumGroup = AlbumGroupFilter(albumGrouping.buildGroupUri(null, 'some group'), setOr);
    expect(albumGroup, jsonMapRoundTrip(albumGroup));
    expect(albumGroup, jsonStringRoundTrip(albumGroup));
  });

  test('Path filter', () {
    const rootAlbum = '${FakeStorageService.primaryPath}Pictures/test';
    const subAlbum = '${FakeStorageService.primaryPath}Pictures/test/sub';
    const siblingAlbum = '${FakeStorageService.primaryPath}Pictures/test sibling';

    final rootImage = FakeMediaStoreService.newImage(rootAlbum, 'image1');
    final subImage = FakeMediaStoreService.newImage(subAlbum, 'image1');
    final siblingImage = FakeMediaStoreService.newImage(siblingAlbum, 'image1');

    final untrailedPath = PathFilter(rootAlbum);
    expect(untrailedPath.test(rootImage), true);
    expect(untrailedPath.test(subImage), true);
    expect(untrailedPath.test(siblingImage), false);

    final trailedPath = PathFilter('$rootAlbum/');
    expect(trailedPath.test(rootImage), true);
    expect(trailedPath.test(subImage), true);
    expect(trailedPath.test(siblingImage), false);
  });
}
