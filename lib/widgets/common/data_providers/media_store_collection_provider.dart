import 'dart:math';

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
  final CollectionSource source = CollectionSource();

  static const EventChannel _eventChannel = EventChannel('deckers.thibault/aves/mediastore');

  Future<void> fetch() async {
    final stopwatch = Stopwatch()..start();
    source.stateNotifier.value = SourceState.loading;
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
    await source.loadDates(); // 100ms for 5400 entries

    var refreshCount = 10;
    const refreshCountMax = 1000;
    final allEntries = <ImageEntry>[];
    _eventChannel.receiveBroadcastStream().cast<Map>().listen(
      (entryMap) {
        allEntries.add(ImageEntry.fromMap(entryMap));
        if (allEntries.length >= refreshCount) {
          refreshCount = min(refreshCount * 10, refreshCountMax);
          source.addAll(allEntries);
          allEntries.clear();
//          debugPrint('$runtimeType streamed ${_source.entries.length} entries at ${stopwatch.elapsed.inMilliseconds}ms');
        }
      },
      onDone: () async {
        debugPrint('$runtimeType stream complete at ${stopwatch.elapsed.inMilliseconds}ms');
        source.addAll(allEntries);
        // TODO reduce setup time until here
        source.updateAlbums(); // <50ms
        source.stateNotifier.value = SourceState.cataloguing;
        await source.loadCatalogMetadata(); // 400ms for 5400 entries
        await source.catalogEntries(); // <50ms
        source.stateNotifier.value = SourceState.locating;
        await source.loadAddresses(); // 350ms
        await source.locateEntries(); // <50ms
        source.stateNotifier.value = SourceState.ready;
        debugPrint('$runtimeType setup end, elapsed=${stopwatch.elapsed}');
      },
      onError: (error) => debugPrint('$runtimeType mediastore stream error=$error'),
    );

    // TODO split image fetch AND/OR cache fetch across sessions
    debugPrint('$runtimeType stream start at ${stopwatch.elapsed.inMilliseconds}ms');
    await ImageFileService.getImageEntries(); // 460ms
  }
}
