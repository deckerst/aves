import 'dart:async';
import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/favourite_repo.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/media_store_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:pedantic/pedantic.dart';

class MediaStoreSource extends CollectionSource {
  bool _initialized = false;

  @override
  bool get initialized => _initialized;

  @override
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
    _initialized = true;
    debugPrint('$runtimeType init done, elapsed=${stopwatch.elapsed}');
  }

  @override
  Future<void> refresh() async {
    assert(_initialized);
    debugPrint('$runtimeType refresh start');
    final stopwatch = Stopwatch()..start();
    stateNotifier.value = SourceState.loading;
    clearEntries();

    final oldEntries = await metadataDb.loadEntries(); // 400ms for 5500 entries
    final knownDateById = Map.fromEntries(oldEntries.map((entry) => MapEntry(entry.contentId, entry.dateModifiedSecs)));
    final obsoleteContentIds = (await MediaStoreService.checkObsoleteContentIds(knownDateById.keys.toList())).toSet();
    oldEntries.removeWhere((entry) => obsoleteContentIds.contains(entry.contentId));

    // show known entries
    addEntries(oldEntries);
    await loadCatalogMetadata(); // 600ms for 5500 entries
    await loadAddresses(); // 200ms for 3000 entries
    debugPrint('$runtimeType refresh loaded ${oldEntries.length} known entries, elapsed=${stopwatch.elapsed}');

    // clean up obsolete entries
    metadataDb.removeIds(obsoleteContentIds, updateFavourites: true);

    // verify paths because some apps move files without updating their `last modified date`
    final knownPathById = Map.fromEntries(allEntries.map((entry) => MapEntry(entry.contentId, entry.path)));
    final movedContentIds = (await MediaStoreService.checkObsoletePaths(knownPathById)).toSet();
    movedContentIds.forEach((contentId) {
      // make obsolete by resetting its modified date
      knownDateById[contentId] = 0;
    });

    // fetch new entries
    // refresh after the first 10 entries, then after 100 more, then every 1000 entries
    var refreshCount = 10;
    const refreshCountMax = 1000;
    final allNewEntries = <AvesEntry>{}, pendingNewEntries = <AvesEntry>{};
    void addPendingEntries() {
      allNewEntries.addAll(pendingNewEntries);
      addEntries(pendingNewEntries);
      pendingNewEntries.clear();
    }

    MediaStoreService.getEntries(knownDateById).listen(
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

        if (allNewEntries.isNotEmpty) {
          // new entries include existing entries with obsolete paths
          // so directories may be added, but also removed or simply have their content summary changed
          invalidateAlbumFilterSummary();
          updateDirectories();
        }

        final analytics = FirebaseAnalytics();
        unawaited(analytics.setUserProperty(name: 'local_item_count', value: (ceilBy(allEntries.length, 3)).toString()));
        unawaited(analytics.setUserProperty(name: 'album_count', value: (ceilBy(rawAlbums.length, 1)).toString()));

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

  // returns URIs to retry later. They could be URIs that are:
  // 1) currently being processed during bulk move/deletion
  // 2) registered in the Media Store but still being processed by their owner in a temporary location
  // For example, when taking a picture with a Galaxy S10e default camera app, querying the Media Store
  // sometimes yields an entry with its temporary path: `/data/sec/camera/!@#$%^..._temp.jpg`
  Future<Set<String>> refreshUris(Set<String> changedUris) async {
    if (!_initialized || !isMonitoring) return changedUris;

    final uriByContentId = Map.fromEntries(changedUris.map((uri) {
      if (uri == null) return null;
      final pathSegments = Uri.parse(uri).pathSegments;
      // e.g. URI `content://media/` has no path segment
      if (pathSegments.isEmpty) return null;
      final idString = pathSegments.last;
      final contentId = int.tryParse(idString);
      if (contentId == null) return null;
      return MapEntry(contentId, uri);
    }).where((kv) => kv != null));

    // clean up obsolete entries
    final obsoleteContentIds = (await MediaStoreService.checkObsoleteContentIds(uriByContentId.keys.toList())).toSet();
    final obsoleteUris = obsoleteContentIds.map((contentId) => uriByContentId[contentId]).toSet();
    removeEntries(obsoleteUris);
    obsoleteContentIds.forEach(uriByContentId.remove);

    // fetch new entries
    final tempUris = <String>{};
    final newEntries = <AvesEntry>{};
    final existingDirectories = <String>{};
    for (final kv in uriByContentId.entries) {
      final contentId = kv.key;
      final uri = kv.value;
      final sourceEntry = await ImageFileService.getEntry(uri, null);
      if (sourceEntry != null) {
        final existingEntry = allEntries.firstWhere((entry) => entry.contentId == contentId, orElse: () => null);
        // compare paths because some apps move files without updating their `last modified date`
        if (existingEntry == null || sourceEntry.dateModifiedSecs > existingEntry.dateModifiedSecs || sourceEntry.path != existingEntry.path) {
          final volume = androidFileUtils.getStorageVolume(sourceEntry.path);
          if (volume != null) {
            newEntries.add(sourceEntry);
            if (existingEntry != null) {
              existingDirectories.add(existingEntry.directory);
            }
          } else {
            debugPrint('$runtimeType refreshUris entry=$sourceEntry is not located on a known storage volume. Will retry soon...');
            tempUris.add(uri);
          }
        }
      }
    }

    if (newEntries.isNotEmpty) {
      invalidateAlbumFilterSummary(directories: existingDirectories);
      addEntries(newEntries);
      await metadataDb.saveEntries(newEntries);
      cleanEmptyAlbums(existingDirectories);

      stateNotifier.value = SourceState.cataloguing;
      await catalogEntries();

      stateNotifier.value = SourceState.locating;
      await locateEntries();

      stateNotifier.value = SourceState.ready;
    }

    return tempUris;
  }

  @override
  Future<void> refreshMetadata(Set<AvesEntry> entries) {
    final contentIds = entries.map((entry) => entry.contentId).toSet();
    metadataDb.removeIds(contentIds, updateFavourites: false);
    return refresh();
  }
}
