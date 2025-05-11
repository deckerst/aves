import 'package:aves/model/filters/aspect_ratio.dart';
import 'package:aves/model/filters/coordinate.dart';
import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
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
import 'package:aves/model/filters/container/set_and.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/filters/weekday.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/services/common/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../fake/media_store_service.dart';
import '../fake/storage_service.dart';

void main() {
  setUp(() async {
    // specify Posix style path context for consistent behaviour when running tests on Windows
    getIt.registerLazySingleton<p.Context>(() => p.Context(style: p.Style.posix));
  });

  tearDown(() async {
    albumGrouping.init({});
    await getIt.reset();
  });

  test('Filter serialization', () {
    CollectionFilter? jsonRoundTrip(filter) => CollectionFilter.fromJson(filter.toJson());

    final aspectRatio = AspectRatioFilter.landscape;
    expect(aspectRatio, jsonRoundTrip(aspectRatio));

    final bounds = CoordinateFilter(const LatLng(29.979167, 28.223615), const LatLng(36.451000, 31.134167));
    expect(bounds, jsonRoundTrip(bounds));

    final date = DateFilter(DateLevel.ym, DateTime(1969, 7));
    expect(date, jsonRoundTrip(date));

    final onThisDay = DateFilter.onThisDay;
    expect(onThisDay, jsonRoundTrip(onThisDay));

    const fav = FavouriteFilter.instance;
    expect(fav, jsonRoundTrip(fav));

    final mime = MimeFilter.video;
    expect(mime, jsonRoundTrip(mime));

    final missing = MissingFilter.title;
    expect(missing, jsonRoundTrip(missing));

    final path = PathFilter('/some/path/');
    expect(path, jsonRoundTrip(path));

    final placeholder = PlaceholderFilter.country;
    expect(placeholder, jsonRoundTrip(placeholder));

    final query = QueryFilter('some query');
    expect(query, jsonRoundTrip(query));

    final rating = RatingFilter(3);
    expect(rating, jsonRoundTrip(rating));

    final recent = RecentlyAddedFilter.instance;
    expect(recent, jsonRoundTrip(recent));

    final type = TypeFilter.sphericalVideo;
    expect(type, jsonRoundTrip(type));

    final weekday = WeekDayFilter(5);
    expect(weekday, jsonRoundTrip(weekday));

    // covered

    final album = StoredAlbumFilter('path/to/album', 'album');
    expect(album, jsonRoundTrip(album));

    final location = LocationFilter(LocationLevel.country, 'France${LocationFilter.locationSeparator}FR');
    expect(location, jsonRoundTrip(location));

    final tag = TagFilter('some tag');
    expect(tag, jsonRoundTrip(tag));

    // combinations

    final setAnd = SetAndFilter({album, location, tag});
    expect(setAnd, jsonRoundTrip(setAnd));

    final setOr = SetOrFilter({album, location, tag});
    expect(setOr, jsonRoundTrip(setOr));

    final dynamicAlbum = DynamicAlbumFilter('dynamic album', setAnd);
    expect(dynamicAlbum, jsonRoundTrip(dynamicAlbum));

    // groups

    final albumGroup = AlbumGroupFilter(albumGrouping.buildGroupUri(null, 'some group'), setOr);
    expect(albumGroup, jsonRoundTrip(albumGroup));
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
