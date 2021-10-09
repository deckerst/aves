import 'dart:async';
import 'dart:math';

import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

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
    await covers.init();
    final currentTimeZone = await deviceService.getDefaultTimeZone();
    if (currentTimeZone != null) {
      final catalogTimeZone = settings.catalogTimeZone;
      if (currentTimeZone != catalogTimeZone) {
        // clear catalog metadata to get correct date/times when moving to a different time zone
        debugPrint('$runtimeType clear catalog metadata to get correct date/times');
        await metadataDb.clearDates();
        await metadataDb.clearMetadataEntries();
        settings.catalogTimeZone = currentTimeZone;
      }
    }
    await loadDates();
    _initialized = true;
    debugPrint('$runtimeType init complete in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  @override
  Future<void> refresh() async {
    assert(_initialized);
    debugPrint('$runtimeType refresh start');
    final stopwatch = Stopwatch()..start();
    stateNotifier.value = SourceState.loading;
    clearEntries();

    debugPrint('$runtimeType refresh ${stopwatch.elapsed} fetch known entries');
    final oldEntries = await metadataDb.loadEntries();
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} check obsolete entries');
    final knownDateById = Map.fromEntries(oldEntries.map((entry) => MapEntry(entry.contentId!, entry.dateModifiedSecs!)));
    final obsoleteContentIds = (await mediaStoreService.checkObsoleteContentIds(knownDateById.keys.toList())).toSet();
    oldEntries.removeWhere((entry) => obsoleteContentIds.contains(entry.contentId));

    // show known entries
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} add known entries');
    addEntries(oldEntries);
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} load catalog metadata');
    await loadCatalogMetadata();
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} load address metadata');
    await loadAddresses();

    // clean up obsolete entries
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} remove obsolete entries');
    await metadataDb.removeIds(obsoleteContentIds, metadataOnly: false);

    // verify paths because some apps move files without updating their `last modified date`
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} check obsolete paths');
    final knownPathById = Map.fromEntries(allEntries.map((entry) => MapEntry(entry.contentId!, entry.path)));
    final movedContentIds = (await mediaStoreService.checkObsoletePaths(knownPathById)).toSet();
    movedContentIds.forEach((contentId) {
      // make obsolete by resetting its modified date
      knownDateById[contentId] = 0;
    });

    // fetch new entries
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} fetch new entries');
    // refresh after the first 10 entries, then after 100 more, then every 1000 entries
    var refreshCount = 10;
    const refreshCountMax = 1000;
    final allNewEntries = <AvesEntry>{}, pendingNewEntries = <AvesEntry>{};
    void addPendingEntries() {
      allNewEntries.addAll(pendingNewEntries);
      addEntries(pendingNewEntries);
      pendingNewEntries.clear();
    }

    mediaStoreService.getEntries(knownDateById).listen(
      (entry) {
        pendingNewEntries.add(entry);
        if (pendingNewEntries.length >= refreshCount) {
          refreshCount = min(refreshCount * 10, refreshCountMax);
          addPendingEntries();
        }
      },
      onDone: () async {
        addPendingEntries();

        if (allNewEntries.isNotEmpty) {
          debugPrint('$runtimeType refresh ${stopwatch.elapsed} save new entries');
          await metadataDb.saveEntries(allNewEntries);

          // new entries include existing entries with obsolete paths
          // so directories may be added, but also removed or simply have their content summary changed
          invalidateAlbumFilterSummary();
          updateDirectories();
        }

        debugPrint('$runtimeType refresh ${stopwatch.elapsed} catalog entries');
        await catalogEntries();
        debugPrint('$runtimeType refresh ${stopwatch.elapsed} locate entries');
        await locateEntries();
        stateNotifier.value = SourceState.ready;

        debugPrint('$runtimeType refresh ${stopwatch.elapsed} done for ${oldEntries.length} known, ${allNewEntries.length} new, ${obsoleteContentIds.length} obsolete');
      },
      onError: (error) => debugPrint('$runtimeType stream error=$error'),
    );
  }

  // returns URIs to retry later. They could be URIs that are:
  // 1) currently being processed during bulk move/deletion
  // 2) registered in the Media Store but still being processed by their owner in a temporary location
  // For example, when taking a picture with a Galaxy S10e default camera app, querying the Media Store
  // sometimes yields an entry with its temporary path: `/data/sec/camera/!@#$%^..._temp.jpg`
  @override
  Future<Set<String>> refreshUris(Set<String> changedUris) async {
    if (!_initialized || !isMonitoring) return changedUris;

    debugPrint('$runtimeType refreshUris ${changedUris.length} uris');
    final uriByContentId = Map.fromEntries(changedUris.map((uri) {
      final pathSegments = Uri.parse(uri).pathSegments;
      // e.g. URI `content://media/` has no path segment
      if (pathSegments.isEmpty) return null;
      final idString = pathSegments.last;
      final contentId = int.tryParse(idString);
      if (contentId == null) return null;
      return MapEntry(contentId, uri);
    }).whereNotNull());

    // clean up obsolete entries
    final obsoleteContentIds = (await mediaStoreService.checkObsoleteContentIds(uriByContentId.keys.toList())).toSet();
    final obsoleteUris = obsoleteContentIds.map((contentId) => uriByContentId[contentId]).whereNotNull().toSet();
    await removeEntries(obsoleteUris);
    obsoleteContentIds.forEach(uriByContentId.remove);

    // fetch new entries
    final tempUris = <String>{};
    final newEntries = <AvesEntry>{};
    final existingDirectories = <String>{};
    for (final kv in uriByContentId.entries) {
      final contentId = kv.key;
      final uri = kv.value;
      final sourceEntry = await mediaFileService.getEntry(uri, null);
      if (sourceEntry != null) {
        final existingEntry = allEntries.firstWhereOrNull((entry) => entry.contentId == contentId);
        // compare paths because some apps move files without updating their `last modified date`
        if (existingEntry == null || (sourceEntry.dateModifiedSecs ?? 0) > (existingEntry.dateModifiedSecs ?? 0) || sourceEntry.path != existingEntry.path) {
          final newPath = sourceEntry.path;
          final volume = newPath != null ? androidFileUtils.getStorageVolume(newPath) : null;
          if (volume != null) {
            newEntries.add(sourceEntry);
            final existingDirectory = existingEntry?.directory;
            if (existingDirectory != null) {
              existingDirectories.add(existingDirectory);
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
      await catalogEntries();
      await locateEntries();
      stateNotifier.value = SourceState.ready;
    }

    return tempUris;
  }

  @override
  Future<void> rescan(Set<AvesEntry> entries) async {
    final contentIds = entries.map((entry) => entry.contentId).whereNotNull().toSet();
    await metadataDb.removeIds(contentIds, metadataOnly: true);
    return refresh();
  }
}
