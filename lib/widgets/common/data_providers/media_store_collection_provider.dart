import 'dart:math';

import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:pedantic/pedantic.dart';

class MediaStoreSource extends CollectionSource {
  Future<void> init() async {
    final stopwatch = Stopwatch()..start();
    stateNotifier.value = SourceState.loading;
    await metadataDb.init();
    await favourites.init();
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
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
    debugPrint('$runtimeType refresh start');
    final stopwatch = Stopwatch()..start();
    stateNotifier.value = SourceState.loading;

    final oldEntries = await metadataDb.loadEntries(); // 400ms for 5500 entries
    final knownEntryMap = Map.fromEntries(oldEntries.map((entry) => MapEntry(entry.contentId, entry.dateModifiedSecs)));
    final obsoleteEntries = await ImageFileService.getObsoleteEntries(knownEntryMap.keys.toList());
    oldEntries.removeWhere((entry) => obsoleteEntries.contains(entry.contentId));

    // show known entries
    addAll(oldEntries);
    await loadCatalogMetadata(); // 600ms for 5500 entries
    await loadAddresses(); // 200ms for 3000 entries
    debugPrint('$runtimeType refresh loaded ${oldEntries.length} known entries, elapsed=${stopwatch.elapsed}');

    // clean up obsolete entries
    metadataDb.removeIds(obsoleteEntries);

    // fetch new entries
    var refreshCount = 10;
    const refreshCountMax = 1000;
    final allNewEntries = <ImageEntry>[], pendingNewEntries = <ImageEntry>[];
    void addPendingEntries() {
      allNewEntries.addAll(pendingNewEntries);
      addAll(pendingNewEntries);
      pendingNewEntries.clear();
    }

    ImageFileService.getImageEntries(knownEntryMap).listen(
      (entry) {
        pendingNewEntries.add(entry);
        if (pendingNewEntries.length >= refreshCount) {
          refreshCount = min(refreshCount * 10, refreshCountMax);
          addPendingEntries();
        }
      },
      onDone: () async {
        addPendingEntries();
        debugPrint('$runtimeType refresh loaded ${allNewEntries.length} new entries, elapsed=${stopwatch.elapsed}');

        await metadataDb.saveEntries(allNewEntries); // 700ms for 5500 entries
        updateAlbums();
        final analytics = FirebaseAnalytics();
        unawaited(analytics.setUserProperty(name: 'local_item_count', value: (ceilBy(rawEntries.length, 3)).toString()));
        unawaited(analytics.setUserProperty(name: 'album_count', value: (ceilBy(sortedAlbums.length, 1)).toString()));

        stateNotifier.value = SourceState.cataloguing;
        await catalogEntries();
        unawaited(analytics.setUserProperty(name: 'tag_count', value: (ceilBy(sortedTags.length, 1)).toString()));

        stateNotifier.value = SourceState.locating;
        await locateEntries();
        unawaited(analytics.setUserProperty(name: 'country_count', value: (ceilBy(sortedCountries.length, 1)).toString()));

        stateNotifier.value = SourceState.ready;
        debugPrint('$runtimeType refresh done, elapsed=${stopwatch.elapsed}');
      },
      onError: (error) => debugPrint('$runtimeType stream error=$error'),
    );
  }
}
