import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/coordinate.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/missing.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/type.dart';
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
    await getIt.reset();
  });

  test('Filter serialization', () {
    CollectionFilter? jsonRoundTrip(filter) => CollectionFilter.fromJson(filter.toJson());

    final album = AlbumFilter('path/to/album', 'album');
    expect(album, jsonRoundTrip(album));

    final bounds = CoordinateFilter(LatLng(29.979167, 28.223615), LatLng(36.451000, 31.134167));
    expect(bounds, jsonRoundTrip(bounds));

    final date = DateFilter(DateLevel.ym, DateTime(1969, 7));
    expect(date, jsonRoundTrip(date));

    final onThisDay = DateFilter.onThisDay;
    expect(onThisDay, jsonRoundTrip(onThisDay));

    const fav = FavouriteFilter.instance;
    expect(fav, jsonRoundTrip(fav));

    final location = LocationFilter(LocationLevel.country, 'France${LocationFilter.locationSeparator}FR');
    expect(location, jsonRoundTrip(location));

    final mime = MimeFilter.video;
    expect(mime, jsonRoundTrip(mime));

    final missing = MissingFilter.title;
    expect(missing, jsonRoundTrip(missing));

    final path = PathFilter('/some/path/');
    expect(path, jsonRoundTrip(path));

    final query = QueryFilter('some query');
    expect(query, jsonRoundTrip(query));

    final rating = RatingFilter(3);
    expect(rating, jsonRoundTrip(rating));

    final recent = RecentlyAddedFilter.instance;
    expect(recent, jsonRoundTrip(recent));

    final tag = TagFilter('some tag');
    expect(tag, jsonRoundTrip(tag));

    final type = TypeFilter.sphericalVideo;
    expect(type, jsonRoundTrip(type));
  });

  test('Path filter', () {
    const rootAlbum = '${FakeStorageService.primaryPath}Pictures/test';
    const subAlbum = '${FakeStorageService.primaryPath}Pictures/test/sub';
    const siblingAlbum = '${FakeStorageService.primaryPath}Pictures/test sibling';

    final rootImage = FakeMediaStoreService.newImage(rootAlbum, 'image1');
    final subImage = FakeMediaStoreService.newImage(subAlbum, 'image1');
    final siblingImage = FakeMediaStoreService.newImage(siblingAlbum, 'image1');

    final path = PathFilter('$rootAlbum/');
    expect(path.test(rootImage), true);
    expect(path.test(subImage), true);
    expect(path.test(siblingImage), false);
  });
}
