import 'dart:async';
import 'dart:math';

import 'package:aves/model/covers.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class MediaStoreSource extends CollectionSource {
  SourceInitializationState _initState = SourceInitializationState.none;

  @override
  SourceInitializationState get initState => _initState;

  @override
  Future<void> init({
    AnalysisController? analysisController,
    String? directory,
    bool loadTopEntriesFirst = false,
    bool canAnalyze = true,
  }) async {
    if (_initState == SourceInitializationState.none) {
      await _loadEssentials();
    }
    if (_initState != SourceInitializationState.full) {
      _initState = directory != null ? SourceInitializationState.directory : SourceInitializationState.full;
    }
    unawaited(_loadEntries(
      analysisController: analysisController,
      directory: directory,
      loadTopEntriesFirst: loadTopEntriesFirst,
      canAnalyze: canAnalyze,
    ));
  }

  Future<void> _loadEssentials() async {
    final stopwatch = Stopwatch()..start();
    state = SourceState.loading;
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
        await metadataDb.clearCatalogMetadata();
        settings.catalogTimeZone = currentTimeZone;
      }
    }
    await loadDates();
    debugPrint('$runtimeType load essentials complete in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  Future<void> _loadEntries({
    AnalysisController? analysisController,
    String? directory,
    required bool loadTopEntriesFirst,
    required bool canAnalyze,
  }) async {
    debugPrint('$runtimeType refresh start');
    final stopwatch = Stopwatch()..start();
    state = SourceState.loading;
    clearEntries();

    final Set<AvesEntry> topEntries = {};
    if (loadTopEntriesFirst) {
      final topIds = settings.topEntryIds;
      if (topIds != null) {
        debugPrint('$runtimeType refresh ${stopwatch.elapsed} load ${topIds.length} top entries');
        topEntries.addAll(await metadataDb.loadEntriesById(topIds));
        addEntries(topEntries);
      }
    }

    debugPrint('$runtimeType refresh ${stopwatch.elapsed} fetch known entries');
    final knownEntries = await metadataDb.loadEntries(directory: directory);
    final knownLiveEntries = knownEntries.where((entry) => !entry.trashed).toSet();

    debugPrint('$runtimeType refresh ${stopwatch.elapsed} check obsolete entries');
    final knownDateByContentId = Map.fromEntries(knownLiveEntries.map((entry) => MapEntry(entry.contentId, entry.dateModifiedSecs)));
    final knownContentIds = knownDateByContentId.keys.toList();
    final removedContentIds = (await mediaStoreService.checkObsoleteContentIds(knownContentIds)).toSet();
    if (topEntries.isNotEmpty) {
      final removedTopEntries = topEntries.where((entry) => removedContentIds.contains(entry.contentId));
      await removeEntries(removedTopEntries.map((entry) => entry.uri).toSet(), includeTrash: false);
    }
    final removedEntries = knownEntries.where((entry) => removedContentIds.contains(entry.contentId)).toSet();
    knownEntries.removeAll(removedEntries);

    // show known entries
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} add known entries');
    // add entries without notifying, so that the collection is not refreshed
    // with items that may be hidden right away because of their metadata
    addEntries(knownEntries, notify: false);

    debugPrint('$runtimeType refresh ${stopwatch.elapsed} load metadata');
    if (directory != null) {
      final ids = knownLiveEntries.map((entry) => entry.id).toSet();
      await loadCatalogMetadata(ids: ids);
      await loadAddresses(ids: ids);
    } else {
      await loadCatalogMetadata();
      await loadAddresses();
      updateDerivedFilters();

      // trash
      await loadTrashDetails();
      unawaited(deleteExpiredTrash().then(
        (deletedUris) {
          if (deletedUris.isNotEmpty) {
            debugPrint('evicted ${deletedUris.length} expired items from the trash');
            removeEntries(deletedUris, includeTrash: true);
          }
        },
        onError: (error) => debugPrint('failed to evict expired trash error=$error'),
      ));
    }

    // clean up obsolete entries
    if (removedEntries.isNotEmpty) {
      debugPrint('$runtimeType refresh ${stopwatch.elapsed} remove obsolete entries');
      await metadataDb.removeIds(removedEntries.map((entry) => entry.id));
    }

    // verify paths because some apps move files without updating their `last modified date`
    debugPrint('$runtimeType refresh ${stopwatch.elapsed} check obsolete paths');
    final knownPathByContentId = Map.fromEntries(knownLiveEntries.map((entry) => MapEntry(entry.contentId, entry.path)));
    final movedContentIds = (await mediaStoreService.checkObsoletePaths(knownPathByContentId)).toSet();
    movedContentIds.forEach((contentId) {
      // make obsolete by resetting its modified date
      knownDateByContentId[contentId] = 0;
    });

    // fetch new & modified entries
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

    mediaStoreService.getEntries(knownDateByContentId, directory: directory).listen(
      (entry) {
        // when discovering modified entry with known content ID,
        // reuse known entry ID to overwrite it while preserving favourites, etc.
        final contentId = entry.contentId;
        final existingEntry = knownContentIds.contains(contentId) ? knownLiveEntries.firstWhereOrNull((entry) => entry.contentId == contentId) : null;
        if (existingEntry != null) {
          entry.id = existingEntry.id;
          entry.dateAddedSecs = existingEntry.dateAddedSecs;
        } else {
          entry.id = metadataDb.nextId;
          entry.dateAddedSecs = metadataDb.timestampSecs;
        }

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

        debugPrint('$runtimeType refresh ${stopwatch.elapsed} analyze');
        Set<AvesEntry>? analysisEntries;
        final analysisIds = analysisController?.entryIds;
        if (analysisIds != null) {
          analysisEntries = visibleEntries.where((entry) => analysisIds.contains(entry.id)).toSet();
        }
        if (canAnalyze) {
          await analyze(analysisController, entries: analysisEntries);
        } else {
          state = SourceState.ready;
        }

        // the home page may not reflect the current derived filters
        // as the initial addition of entries is silent,
        // so we manually notify change for potential home screen filters
        notifyAlbumsChanged();

        debugPrint('$runtimeType refresh ${stopwatch.elapsed} done for ${knownEntries.length} known, ${allNewEntries.length} new, ${removedEntries.length} removed');
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
  Future<Set<String>> refreshUris(Set<String> changedUris, {AnalysisController? analysisController}) async {
    if (_initState == SourceInitializationState.none || !isMonitoring || !isReady) return changedUris;

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
    await removeEntries(obsoleteUris, includeTrash: false);
    obsoleteContentIds.forEach(uriByContentId.remove);

    // fetch new entries
    final tempUris = <String>{};
    final newEntries = <AvesEntry>{};
    final existingDirectories = <String>{};
    for (final kv in uriByContentId.entries) {
      final contentId = kv.key;
      final uri = kv.value;
      final sourceEntry = await mediaFetchService.getEntry(uri, null);
      if (sourceEntry != null) {
        final existingEntry = allEntries.firstWhereOrNull((entry) => entry.contentId == contentId);
        // compare paths because some apps move files without updating their `last modified date`
        if (existingEntry == null || (sourceEntry.dateModifiedSecs ?? 0) > (existingEntry.dateModifiedSecs ?? 0) || sourceEntry.path != existingEntry.path) {
          final newPath = sourceEntry.path;
          final volume = newPath != null ? androidFileUtils.getStorageVolume(newPath) : null;
          if (volume != null) {
            if (existingEntry != null) {
              sourceEntry.id = existingEntry.id;
              sourceEntry.dateAddedSecs = existingEntry.dateAddedSecs;
            } else {
              sourceEntry.id = metadataDb.nextId;
              sourceEntry.dateAddedSecs = metadataDb.timestampSecs;
            }
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

      await analyze(analysisController, entries: newEntries);
    }

    return tempUris;
  }
}
