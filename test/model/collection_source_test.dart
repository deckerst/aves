import 'dart:async';

import 'package:aves/model/availability.dart';
import 'package:aves/model/covers.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/media_store_source.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/device_service.dart';
import 'package:aves/services/media/media_file_service.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:aves/services/metadata/metadata_fetch_service.dart';
import 'package:aves/services/storage_service.dart';
import 'package:aves/services/window_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves_report/aves_report.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;

import '../fake/android_app_service.dart';
import '../fake/availability.dart';
import '../fake/device_service.dart';
import '../fake/media_file_service.dart';
import '../fake/media_store_service.dart';
import '../fake/metadata_db.dart';
import '../fake/metadata_fetch_service.dart';
import '../fake/report_service.dart';
import '../fake/storage_service.dart';
import '../fake/window_service.dart';

void main() {
  const testAlbum = '${FakeStorageService.primaryPath}Pictures/test';
  const sourceAlbum = '${FakeStorageService.primaryPath}Pictures/source';
  const destinationAlbum = '${FakeStorageService.primaryPath}Pictures/destination';

  const aTag = 'sometag';
  final australiaLatLng = LatLng(-26, 141);
  const australiaAddress = AddressDetails(
    countryCode: 'AU',
    countryName: 'AUS',
  );

  setUp(() async {
    // specify Posix style path context for consistent behaviour when running tests on Windows
    getIt.registerLazySingleton<p.Context>(() => p.Context(style: p.Style.posix));
    getIt.registerLazySingleton<AvesAvailability>(FakeAvesAvailability.new);
    getIt.registerLazySingleton<MetadataDb>(FakeMetadataDb.new);

    getIt.registerLazySingleton<AndroidAppService>(FakeAndroidAppService.new);
    getIt.registerLazySingleton<DeviceService>(FakeDeviceService.new);
    getIt.registerLazySingleton<MediaFileService>(FakeMediaFileService.new);
    getIt.registerLazySingleton<MediaStoreService>(FakeMediaStoreService.new);
    getIt.registerLazySingleton<MetadataFetchService>(FakeMetadataFetchService.new);
    getIt.registerLazySingleton<ReportService>(FakeReportService.new);
    getIt.registerLazySingleton<StorageService>(FakeStorageService.new);
    getIt.registerLazySingleton<WindowService>(FakeWindowService.new);

    await settings.init(monitorPlatformSettings: false);
    settings.canUseAnalysisService = false;
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<MediaStoreSource> _initSource() async {
    final source = MediaStoreSource();
    final readyCompleter = Completer();
    source.stateNotifier.addListener(() {
      if (source.stateNotifier.value == SourceState.ready) {
        readyCompleter.complete();
      }
    });
    await source.init();
    await source.refresh();
    await readyCompleter.future;
    return source;
  }

  test('album/country/tag hidden on launch when their items are hidden by entry prop', () async {
    settings.hiddenFilters = {const AlbumFilter(testAlbum, 'whatever')};

    final image1 = FakeMediaStoreService.newImage(testAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };
    (metadataFetchService as FakeMetadataFetchService).setUp(
      image1,
      CatalogMetadata(
        contentId: image1.contentId,
        xmpSubjects: aTag,
        latitude: australiaLatLng.latitude,
        longitude: australiaLatLng.longitude,
      ),
    );

    final source = await _initSource();
    expect(source.rawAlbums.length, 0);
    expect(source.sortedCountries.length, 0);
    expect(source.sortedTags.length, 0);
  });

  test('album/country/tag hidden on launch when their items are hidden by metadata', () async {
    settings.hiddenFilters = {TagFilter(aTag)};

    final image1 = FakeMediaStoreService.newImage(testAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };
    (metadataFetchService as FakeMetadataFetchService).setUp(
      image1,
      CatalogMetadata(
        contentId: image1.contentId,
        xmpSubjects: aTag,
        latitude: australiaLatLng.latitude,
        longitude: australiaLatLng.longitude,
      ),
    );
    expect(image1.tags, <String>{});

    final source = await _initSource();
    expect(image1.tags, {aTag});
    expect(image1.addressDetails, australiaAddress.copyWith(contentId: image1.contentId));

    expect(source.visibleEntries.length, 0);
    expect(source.rawAlbums.length, 0);
    expect(source.sortedCountries.length, 0);
    expect(source.sortedTags.length, 0);
  });

  test('add/remove favourite entry', () async {
    final image1 = FakeMediaStoreService.newImage(testAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };

    await _initSource();
    expect(favourites.count, 0);

    await image1.toggleFavourite();
    expect(favourites.count, 1);
    expect(image1.isFavourite, true);

    await image1.toggleFavourite();
    expect(favourites.count, 0);
    expect(image1.isFavourite, false);
  });

  test('set/unset entry as album cover', () async {
    final image1 = FakeMediaStoreService.newImage(testAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };

    final source = await _initSource();
    expect(source.rawAlbums.length, 1);
    expect(covers.count, 0);

    const albumFilter = AlbumFilter(testAlbum, 'whatever');
    expect(albumFilter.test(image1), true);
    expect(covers.count, 0);
    expect(covers.coverContentId(albumFilter), null);

    await covers.set(albumFilter, image1.contentId);
    expect(covers.count, 1);
    expect(covers.coverContentId(albumFilter), image1.contentId);

    await covers.set(albumFilter, null);
    expect(covers.count, 0);
    expect(covers.coverContentId(albumFilter), null);
  });

  test('favourites and covers are kept when renaming entries', () async {
    final image1 = FakeMediaStoreService.newImage(testAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };

    final source = await _initSource();
    await image1.toggleFavourite();
    const albumFilter = AlbumFilter(testAlbum, 'whatever');
    await covers.set(albumFilter, image1.contentId);
    await source.renameEntry(image1, 'image1b.jpg', persist: true);

    expect(favourites.count, 1);
    expect(image1.isFavourite, true);
    expect(covers.count, 1);
    expect(covers.coverContentId(albumFilter), image1.contentId);
  });

  test('favourites and covers are cleared when removing entries', () async {
    final image1 = FakeMediaStoreService.newImage(testAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };

    final source = await _initSource();
    await image1.toggleFavourite();
    final albumFilter = AlbumFilter(image1.directory!, 'whatever');
    await covers.set(albumFilter, image1.contentId);
    await source.removeEntries({image1.uri});

    expect(source.rawAlbums.length, 0);
    expect(favourites.count, 0);
    expect(covers.count, 0);
    expect(covers.coverContentId(albumFilter), null);
  });

  test('albums are updated when moving entries', () async {
    final image1 = FakeMediaStoreService.newImage(sourceAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };

    final source = await _initSource();
    expect(source.rawAlbums.contains(sourceAlbum), true);
    expect(source.rawAlbums.contains(destinationAlbum), false);

    const sourceAlbumFilter = AlbumFilter(sourceAlbum, 'whatever');
    const destinationAlbumFilter = AlbumFilter(destinationAlbum, 'whatever');
    expect(sourceAlbumFilter.test(image1), true);
    expect(destinationAlbumFilter.test(image1), false);

    await source.updateAfterMove(
      todoEntries: {image1},
      copy: false,
      destinationAlbum: destinationAlbum,
      movedOps: {
        FakeMediaStoreService.moveOpEventFor(image1, sourceAlbum, destinationAlbum),
      },
    );

    expect(source.rawAlbums.contains(sourceAlbum), false);
    expect(source.rawAlbums.contains(destinationAlbum), true);
    expect(sourceAlbumFilter.test(image1), false);
    expect(destinationAlbumFilter.test(image1), true);
  });

  test('favourites are kept when moving entries', () async {
    final image1 = FakeMediaStoreService.newImage(sourceAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };

    final source = await _initSource();
    await image1.toggleFavourite();

    await source.updateAfterMove(
      todoEntries: {image1},
      copy: false,
      destinationAlbum: destinationAlbum,
      movedOps: {
        FakeMediaStoreService.moveOpEventFor(image1, sourceAlbum, destinationAlbum),
      },
    );

    expect(favourites.count, 1);
    expect(image1.isFavourite, true);
  });

  test('album cover is reset when moving cover entry', () async {
    final image1 = FakeMediaStoreService.newImage(sourceAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
      FakeMediaStoreService.newImage(sourceAlbum, 'image2'),
    };

    final source = await _initSource();
    expect(source.rawAlbums.length, 1);
    const sourceAlbumFilter = AlbumFilter(sourceAlbum, 'whatever');
    await covers.set(sourceAlbumFilter, image1.contentId);

    await source.updateAfterMove(
      todoEntries: {image1},
      copy: false,
      destinationAlbum: destinationAlbum,
      movedOps: {
        FakeMediaStoreService.moveOpEventFor(image1, sourceAlbum, destinationAlbum),
      },
    );

    expect(source.rawAlbums.length, 2);
    expect(covers.count, 0);
    expect(covers.coverContentId(sourceAlbumFilter), null);
  });

  test('favourites and covers are kept when renaming albums', () async {
    final image1 = FakeMediaStoreService.newImage(sourceAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };

    final source = await _initSource();
    await image1.toggleFavourite();
    var albumFilter = const AlbumFilter(sourceAlbum, 'whatever');
    await covers.set(albumFilter, image1.contentId);
    await source.renameAlbum(sourceAlbum, destinationAlbum, {
      image1
    }, {
      FakeMediaStoreService.moveOpEventFor(image1, sourceAlbum, destinationAlbum),
    });
    albumFilter = const AlbumFilter(destinationAlbum, 'whatever');

    expect(favourites.count, 1);
    expect(image1.isFavourite, true);
    expect(covers.count, 1);
    expect(covers.coverContentId(albumFilter), image1.contentId);
  });

  testWidgets('unique album names', (tester) async {
    (mediaStoreService as FakeMediaStoreService).entries = {
      FakeMediaStoreService.newImage('${FakeStorageService.primaryPath}Pictures/Elea/Zeno', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.primaryPath}Pictures/Citium/Zeno', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.primaryPath}Pictures/Cleanthes', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.primaryPath}Pictures/Chrysippus', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.removablePath}Pictures/Chrysippus', '1'),
      FakeMediaStoreService.newImage(FakeStorageService.primaryPath, '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.primaryPath}Pictures/Seneca', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.primaryPath}Seneca', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.removablePath}Pictures/Cicero', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.removablePath}Marcus Aurelius', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.primaryPath}Pictures/Hannah Arendt', '1'),
      FakeMediaStoreService.newImage('${FakeStorageService.primaryPath}Pictures/Arendt', '1'),
    };

    await androidFileUtils.init();
    final source = await _initSource();
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.primaryPath}Pictures/Elea/Zeno'), 'Elea/Zeno');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.primaryPath}Pictures/Citium/Zeno'), 'Citium/Zeno');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.primaryPath}Pictures/Cleanthes'), 'Cleanthes');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.primaryPath}Pictures/Chrysippus'), 'Chrysippus');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.removablePath}Pictures/Chrysippus'), 'Chrysippus (${FakeStorageService.removableDescription})');
          expect(source.getAlbumDisplayName(context, FakeStorageService.primaryRootAlbum), FakeStorageService.primaryDescription);
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.primaryPath}Pictures/Seneca'), 'Pictures/Seneca');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.primaryPath}Seneca'), 'Seneca');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.removablePath}Pictures/Cicero'), 'Cicero');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.removablePath}Marcus Aurelius'), 'Marcus Aurelius');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.primaryPath}Pictures/Hannah Arendt'), 'Hannah Arendt');
          expect(source.getAlbumDisplayName(context, '${FakeStorageService.primaryPath}Pictures/Arendt'), 'Arendt');
          return const Placeholder();
        },
      ),
    );
  });
}
