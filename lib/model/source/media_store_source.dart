import 'dart:async';

import 'package:aves/model/covers.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/origins.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class MediaStoreSource extends CollectionSource {
  final Debouncer _changeDebouncer = Debouncer(delay: ADurations.mediaContentChangeDebounceDelay);
  final Set<String> _changedUris = {};
  int? _lastGeneration;
  SourceScope _scope = SourceScope.none;
  bool _canAnalyze = true;

  @override
  set canAnalyze(bool enabled) => _canAnalyze = enabled;

  @override
  SourceScope get scope => _scope;

  @override
  Future<void> init({
    AnalysisController? analysisController,
    AlbumFilter? albumFilter,
    bool loadTopEntriesFirst = false,
  }) async {
    await reportService.log('$runtimeType init album=${albumFilter?.album}');
    if (_scope == SourceScope.none) {
      await _loadEssentials();
    }
    if (_scope != SourceScope.full) {
      _scope = albumFilter != null ? SourceScope.album : SourceScope.full;
    }
    addDirectories(albums: settings.pinnedFilters.whereType<AlbumFilter>().map((v) => v.album).toSet());
    await updateGeneration();
    unawaited(_loadEntries(
      analysisController: analysisController,
      directory: albumFilter?.album,
      loadTopEntriesFirst: loadTopEntriesFirst,
    ));
  }

  Future<void> _loadEssentials() async {
    final stopwatch = Stopwatch()..start();
    state = SourceState.loading;
    await localMediaDb.init();
    await vaults.init();
    await favourites.init();
    await covers.init();
    final currentTimeZoneOffset = await deviceService.getDefaultTimeZoneRawOffsetMillis();
    if (currentTimeZoneOffset != null) {
      final catalogTimeZoneOffset = settings.catalogTimeZoneRawOffsetMillis;
      if (currentTimeZoneOffset != catalogTimeZoneOffset) {
        // clear catalog metadata to get correct date/times when moving to a different time zone
        debugPrint('$runtimeType clear catalog metadata to get correct date/times');
        await localMediaDb.clearDates();
        await localMediaDb.clearCatalogMetadata();
        settings.catalogTimeZoneRawOffsetMillis = currentTimeZoneOffset;
      }
    }
    await loadDates();
    debugPrint('$runtimeType load essentials complete in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  Future<void> _loadEntries({
    AnalysisController? analysisController,
    String? directory,
    required bool loadTopEntriesFirst,
  }) async {
    unawaited(reportService.log('$runtimeType load (known) start'));
    final stopwatch = Stopwatch()..start();
    state = SourceState.loading;
    clearEntries();

    final Set<AvesEntry> topEntries = {};
    if (loadTopEntriesFirst) {
      final topIds = settings.topEntryIds?.toSet();
      if (topIds != null) {
        debugPrint('$runtimeType load ${stopwatch.elapsed} load ${topIds.length} top entries');
        topEntries.addAll(await localMediaDb.loadEntriesById(topIds));
        addEntries(topEntries);
      }
    }

    debugPrint('$runtimeType load ${stopwatch.elapsed} fetch known entries');
    final knownEntries = await localMediaDb.loadEntries(origin: EntryOrigins.mediaStoreContent, directory: directory);
    final knownLiveEntries = knownEntries.where((entry) => !entry.trashed).toSet();

    debugPrint('$runtimeType load ${stopwatch.elapsed} check obsolete entries');
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
    debugPrint('$runtimeType load ${stopwatch.elapsed} add known entries');
    // add entries without notifying, so that the collection is not refreshed
    // with items that may be hidden right away because of their metadata
    addEntries(knownEntries, notify: false);

    await _loadVaultEntries(directory);

    debugPrint('$runtimeType load ${stopwatch.elapsed} load metadata');
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
      debugPrint('$runtimeType load ${stopwatch.elapsed} remove obsolete entries');
      await localMediaDb.removeIds(removedEntries.map((entry) => entry.id).toSet());
    }

    unawaited(reportService.log('$runtimeType load (known) done in ${stopwatch.elapsed.inSeconds}s for ${knownEntries.length} known, ${removedEntries.length} removed'));

    if (_canAnalyze) {
      // it can discover new entries only if it can analyze them
      await _loadNewEntries(
        analysisController: analysisController,
        directory: directory,
        knownLiveEntries: knownLiveEntries,
        knownDateByContentId: knownDateByContentId,
      );
    } else {
      state = SourceState.ready;
    }
  }

  Future<void> _loadNewEntries({
    required AnalysisController? analysisController,
    required String? directory,
    required Set<AvesEntry> knownLiveEntries,
    required Map<int?, int?> knownDateByContentId,
  }) async {
    unawaited(reportService.log('$runtimeType load (new) start'));
    final stopwatch = Stopwatch()..start();

    // items to add to the collection
    final newEntries = <AvesEntry>{};

    // recover untracked trash items
    debugPrint('$runtimeType load ${stopwatch.elapsed} recover untracked entries');
    if (directory == null) {
      newEntries.addAll(await recoverUntrackedTrashItems());
    }

    // verify paths because some apps move files without updating their `last modified date`
    debugPrint('$runtimeType load ${stopwatch.elapsed} check obsolete paths');
    final knownPathByContentId = Map.fromEntries(knownLiveEntries.map((entry) => MapEntry(entry.contentId, entry.path)));
    final movedContentIds = (await mediaStoreService.checkObsoletePaths(knownPathByContentId)).toSet();
    movedContentIds.forEach((contentId) {
      // make obsolete by resetting its modified date
      knownDateByContentId[contentId] = 0;
    });

    // fetch new & modified entries
    debugPrint('$runtimeType load ${stopwatch.elapsed} fetch new entries');
    final knownContentIds = knownDateByContentId.keys.toSet();
    mediaStoreService.getEntries(knownDateByContentId, directory: directory).listen(
      (entry) {
        // when discovering modified entry with known content ID,
        // reuse known entry ID to overwrite it while preserving favourites, etc.
        final contentId = entry.contentId;
        final existingEntry = knownContentIds.contains(contentId) ? knownLiveEntries.firstWhereOrNull((entry) => entry.contentId == contentId) : null;
        entry.id = existingEntry?.id ?? localMediaDb.nextId;

        newEntries.add(entry);
      },
      onDone: () async {
        if (newEntries.isNotEmpty) {
          debugPrint('$runtimeType load ${stopwatch.elapsed} save new entries');
          await localMediaDb.insertEntries(newEntries);

          // TODO TLAD find duplication cause
          final duplicates = await localMediaDb.searchLiveDuplicates(EntryOrigins.mediaStoreContent, newEntries);
          if (duplicates.isNotEmpty) {
            unawaited(reportService.recordError(Exception('Loading entries yielded duplicates=${duplicates.join(', ')}'), StackTrace.current));
            // post-error cleanup
            await localMediaDb.removeIds(duplicates.map((v) => v.id).toSet());
            for (final duplicate in duplicates) {
              final duplicateId = duplicate.id;
              newEntries.removeWhere((v) => duplicateId == v.id);
            }
          }

          addEntries(newEntries);

          // new entries include existing entries with obsolete paths
          // so directories may be added, but also removed or simply have their content summary changed
          invalidateAlbumFilterSummary();
          updateDirectories();
        }

        debugPrint('$runtimeType load ${stopwatch.elapsed} analyze');
        Set<AvesEntry>? analysisEntries;
        final analysisIds = analysisController?.entryIds;
        if (analysisIds != null) {
          analysisEntries = visibleEntries.where((entry) => analysisIds.contains(entry.id)).toSet();
        }
        await analyze(analysisController, entries: analysisEntries);

        // the home page may not reflect the current derived filters
        // as the initial addition of entries is silent,
        // so we manually notify change for potential home screen filters
        notifyAlbumsChanged();

        unawaited(reportService.log('$runtimeType load (new) done in ${stopwatch.elapsed.inSeconds}s for ${newEntries.length} new entries'));
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
    if (_scope == SourceScope.none || !canRefresh || !isReady) return changedUris;

    state = SourceState.loading;

    unawaited(reportService.log('$runtimeType refresh start for ${changedUris.length} uris'));
    final changedUriByContentId = Map.fromEntries(changedUris.map((uri) {
      final pathSegments = Uri.parse(uri).pathSegments;
      // e.g. URI `content://media/` has no path segment
      if (pathSegments.isEmpty) return null;
      final idString = pathSegments.last;
      final contentId = int.tryParse(idString);
      if (contentId == null) return null;
      return MapEntry(contentId, uri);
    }).whereNotNull());

    // clean up obsolete entries
    final obsoleteContentIds = (await mediaStoreService.checkObsoleteContentIds(changedUriByContentId.keys.toList())).toSet();
    final obsoleteUris = obsoleteContentIds.map((contentId) => changedUriByContentId[contentId]).whereNotNull().toSet();
    await removeEntries(obsoleteUris, includeTrash: false);
    obsoleteContentIds.forEach(changedUriByContentId.remove);

    // fetch new entries
    final tempUris = <String>{};
    final newEntries = <AvesEntry>{}, entriesToRefresh = <AvesEntry>{};
    final existingDirectories = <String>{};
    for (final kv in changedUriByContentId.entries) {
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
              entriesToRefresh.add(existingEntry);
            } else if (_canAnalyze) {
              // it can discover new entries only if it can analyze them
              sourceEntry.id = localMediaDb.nextId;
              newEntries.add(sourceEntry);
            }
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

    await _refreshVaultEntries(
      changedUris: changedUris.where(vaults.isVaultEntryUri).toSet(),
      newEntries: newEntries,
      entriesToRefresh: entriesToRefresh,
      existingDirectories: existingDirectories,
    );

    invalidateAlbumFilterSummary(directories: existingDirectories);

    if (newEntries.isNotEmpty) {
      await localMediaDb.insertEntries(newEntries);

      // TODO TLAD find duplication cause
      final duplicates = await localMediaDb.searchLiveDuplicates(EntryOrigins.mediaStoreContent, newEntries);
      if (duplicates.isNotEmpty) {
        unawaited(reportService.recordError(Exception('Refreshing entries yielded duplicates=${duplicates.join(', ')}'), StackTrace.current));
        // post-error cleanup
        await localMediaDb.removeIds(duplicates.map((v) => v.id).toSet());
        for (final duplicate in duplicates) {
          final duplicateId = duplicate.id;
          newEntries.removeWhere((v) => duplicateId == v.id);
          tempUris.add(duplicate.uri);
        }
      }

      addEntries(newEntries);
      await analyze(analysisController, entries: newEntries);
    }

    if (entriesToRefresh.isNotEmpty) {
      await refreshEntries(entriesToRefresh, EntryDataType.values.toSet());
    }

    unawaited(reportService.log('$runtimeType refresh end for ${changedUris.length} uris'));

    state = SourceState.ready;

    return tempUris;
  }

  void onStoreChanged(String? uri) {
    if (uri != null) _changedUris.add(uri);
    if (_changedUris.isNotEmpty) {
      _changeDebouncer(() async {
        final todo = _changedUris.toSet();
        _changedUris.clear();
        final tempUris = await refreshUris(todo);
        if (tempUris.isNotEmpty) {
          _changedUris.addAll(tempUris);
          onStoreChanged(null);
        }
      });
    }
  }

  Future<void> checkForChanges() async {
    final sinceGeneration = _lastGeneration;
    if (sinceGeneration != null) {
      _changedUris.addAll(await mediaStoreService.getChangedUris(sinceGeneration));
      onStoreChanged(null);
    }
    await updateGeneration();
  }

  Future<void> updateGeneration() async {
    _lastGeneration = await mediaStoreService.getGeneration();
  }

  // vault

  Future<void> _loadVaultEntries(String? directory) async {
    addEntries(await localMediaDb.loadEntries(origin: EntryOrigins.vault, directory: directory));
  }

  Future<void> _refreshVaultEntries({
    required Set<String> changedUris,
    required Set<AvesEntry> newEntries,
    required Set<AvesEntry> entriesToRefresh,
    required Set<String> existingDirectories,
  }) async {
    for (final uri in changedUris) {
      final existingEntry = allEntries.firstWhereOrNull((entry) => entry.uri == uri);
      if (existingEntry != null) {
        entriesToRefresh.add(existingEntry);
        final existingDirectory = existingEntry.directory;
        if (existingDirectory != null) {
          existingDirectories.add(existingDirectory);
        }
      } else {
        final sourceEntry = await mediaFetchService.getEntry(uri, null, allowUnsized: true);
        if (sourceEntry != null) {
          newEntries.add(sourceEntry.copyWith(
            id: localMediaDb.nextId,
            origin: EntryOrigins.vault,
          ));
        }
      }
    }
  }
}
