import 'dart:math';

import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class MediaStoreSource extends CollectionSource {
  Future<void> init() async {
    final stopwatch = Stopwatch()..start();
    stateNotifier.value = SourceState.loading;
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
    await loadDates(); // 100ms for 5400 entries
    debugPrint('$runtimeType init done, elapsed=${stopwatch.elapsed}');
  }

  Future<void> refresh() async {
    final stopwatch = Stopwatch()..start();
    stateNotifier.value = SourceState.loading;

    var refreshCount = 10;
    const refreshCountMax = 1000;
    final allEntries = <ImageEntry>[];

    // TODO split image fetch AND/OR cache fetch across sessions
    ImageFileService.getImageEntries().listen(
      (entry) {
        allEntries.add(entry);
        if (allEntries.length >= refreshCount) {
          refreshCount = min(refreshCount * 10, refreshCountMax);
          addAll(allEntries);
          allEntries.clear();
//          debugPrint('$runtimeType streamed ${entries.length} entries at ${stopwatch.elapsed.inMilliseconds}ms');
        }
      },
      onDone: () async {
        debugPrint('$runtimeType stream done, elapsed=${stopwatch.elapsed}');
        addAll(allEntries);
        // TODO reduce setup time until here
        updateAlbums(); // <50ms
        stateNotifier.value = SourceState.cataloguing;
        await loadCatalogMetadata(); // 400ms for 5400 entries
        await catalogEntries(); // <50ms
        stateNotifier.value = SourceState.locating;
        await loadAddresses(); // 350ms
        await locateEntries(); // <50ms
        stateNotifier.value = SourceState.ready;
        debugPrint('$runtimeType refresh done, elapsed=${stopwatch.elapsed}');
      },
      onError: (error) => debugPrint('$runtimeType stream error=$error'),
    );
  }
}
