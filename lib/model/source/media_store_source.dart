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
  SourceScope _loadedScope, _targetScope;
  bool _canAnalyze = true;
  Future<void>? _essentialLoader;

  @override
  set canAnalyze(bool enabled) => _canAnalyze = enabled;

  @override
  SourceScope get loadedScope => _loadedScope;

  @override
  SourceScope get targetScope => _targetScope;

  @override
  Future<void> init({
    required SourceScope scope,
    AnalysisController? analysisController,
    bool loadTopEntriesFirst = false,
  }) async {
    _targetScope = scope;
    await reportService.log('$runtimeType init target scope=$scope');
    _essentialLoader ??= _loadEssentials();
    await _essentialLoader;
    addDirectories(albums: settings.pinnedFilters.whereType<AlbumFilter>().map((v) => v.album).toSet());
    await updateGeneration();
    unawaited(_loadEntries(
      analysisController: analysisController,
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

    final deviceOffset = DateTime.now().timeZoneOffset.inMilliseconds;
    final catalogOffset = settings.catalogTimeZoneOffsetMillis;
    if (deviceOffset != catalogOffset) {
      unawaited(reportService.recordError('Time zone offset change: $catalogOffset -> $deviceOffset. Clear catalog metadata to get correct date/times.'));
      await localMediaDb.clearDates();
      await localMediaDb.clearCatalogMetadata();
      settings.catalogTimeZoneOffsetMillis = deviceOffset;
    }
    await loadDates();
    debugPrint('$runtimeType load essentials complete in ${stopwatch.elapsed.inMilliseconds}ms');
  }

  Future<void> _loadEntries({
    AnalysisController? analysisController,
    required bool loadTopEntriesFirst,
  }) async {
    unawaited(reportService.log('$runtimeType load (known) start'));
    final stopwatch = Stopwatch()..start();
    state = SourceState.loading;
    clearEntries();

    final scopeAlbumFilters = _targetScope?.whereType<AlbumFilter>();
    final scopeDirectory = scopeAlbumFilters != null && scopeAlbumFilters.length == 1 ? scopeAlbumFilters.first.album : null;

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
    final knownEntries = await localMediaDb.loadEntries(origin: EntryOrigins.mediaStoreContent, directory: scopeDirectory);
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
    // but use album notification without waiting for cataloguing
    // so that it is more reactive when picking an album in view mode
    notifyAlbumsChanged();

    await _loadVaultEntries(scopeDirectory);

    debugPrint('$runtimeType load ${stopwatch.elapsed} load metadata');
    if (scopeDirectory != null) {
      final ids = knownLiveEntries.map((entry) => entry.id).toSet();
      await loadCatalogMetadata(ids: ids);
      await loadAddresses(ids: ids);
    } else {
      await loadCatalogMetadata();
      await loadAddresses();

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
    updateDerivedFilters();

    // clean up obsolete entries
    if (removedEntries.isNotEmpty) {
      debugPrint('$runtimeType load ${stopwatch.elapsed} remove obsolete entries');
      await localMediaDb.removeIds(removedEntries.map((entry) => entry.id).toSet());
    }

    _loadedScope = _targetScope;
    unawaited(reportService.log('$runtimeType load (known) done in ${stopwatch.elapsed.inSeconds}s for ${knownEntries.length} known, ${removedEntries.length} removed'));

    if (_canAnalyze) {
      // it can discover new entries only if it can analyze them
      await _loadNewEntries(
        analysisController: analysisController,
        directory: scopeDirectory,
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
            unawaited(reportService.recordError(Exception('Loading entries yielded duplicates=${duplicates.join(', ')}')));
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
    if (!canRefresh || _essentialLoader == null || !isReady) return changedUris;

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
    }).nonNulls);

    // clean up obsolete entries
    final obsoleteContentIds = (await mediaStoreService.checkObsoleteContentIds(changedUriByContentId.keys.toList())).toSet();
    final obsoleteUris = obsoleteContentIds.map((contentId) => changedUriByContentId[contentId]).nonNulls.toSet();
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
        unawaited(reportService.recordError(Exception('Refreshing entries yielded duplicates=${duplicates.join(', ')}')));
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
