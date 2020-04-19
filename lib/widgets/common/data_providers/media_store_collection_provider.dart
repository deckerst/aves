import 'dart:math';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/collection_source.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class MediaStoreSource {
  CollectionSource _source;
  CollectionLens _baseLens;

  CollectionLens get collection => _baseLens;

  static const EventChannel _eventChannel = EventChannel('deckers.thibault/aves/mediastore');

  MediaStoreSource() {
    _source = CollectionSource();
    _baseLens = CollectionLens(
      source: _source,
      groupFactor: settings.collectionGroupFactor,
      sortFactor: settings.collectionSortFactor,
    );
  }

  Future<void> fetch() async {
    final stopwatch = Stopwatch()..start();
    await metadataDb.init(); // <20ms
    await favourites.init();
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone(); // <20ms
    final catalogTimeZone = settings.catalogTimeZone;
    if (currentTimeZone != catalogTimeZone) {
      // clear catalog metadata to get correct date/times when moving to a different time zone
      debugPrint('$runtimeType clear catalog metadata to get correct date/times');
      await metadataDb.clearDates();
      await metadataDb.clearMetadataEntries();
      settings.catalogTimeZone = currentTimeZone;
    }
    await _source.loadDates(); // 100ms for 5400 entries

    var refreshCount = 10;
    const refreshCountMax = 1000;
    final allEntries = <ImageEntry>[];
    _eventChannel.receiveBroadcastStream().cast<Map>().listen(
      (entryMap) {
        allEntries.add(ImageEntry.fromMap(entryMap));
        if (allEntries.length >= refreshCount) {
          refreshCount = min(refreshCount * 10, refreshCountMax);
          _source.addAll(allEntries);
          allEntries.clear();
//          debugPrint('$runtimeType streamed ${_source.entries.length} entries at ${stopwatch.elapsed.inMilliseconds}ms');
        }
      },
      onDone: () async {
        debugPrint('$runtimeType stream complete at ${stopwatch.elapsed.inMilliseconds}ms');
        _source.addAll(allEntries);
        // TODO reduce setup time until here
        _source.updateAlbums(); // <50ms
        await _source.loadCatalogMetadata(); // 400ms for 5400 entries
        await _source.catalogEntries(); // <50ms
        await _source.loadAddresses(); // 350ms
        await _source.locateEntries(); // <50ms
        debugPrint('$runtimeType setup end, elapsed=${stopwatch.elapsed}');
      },
      onError: (error) => debugPrint('$runtimeType mediastore stream error=$error'),
    );

    // TODO split image fetch AND/OR cache fetch across sessions
    debugPrint('$runtimeType stream start at ${stopwatch.elapsed.inMilliseconds}ms');
    await ImageFileService.getImageEntries(); // 460ms
  }
}
