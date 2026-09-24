import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/filters/container/tag_group.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin TagMixin on SourceBase {
  static const commitCountThreshold = 400;

  bool _tagsDirty = true;
  List<String> _sortedTags = List.unmodifiable([]);

  List<String> get sortedTags {
    if (_tagsDirty) {
      _computeTags();
    }
    return _sortedTags;
  }

  set sortedTags(List<String> tags) {
    _sortedTags = tags;
    _tagsDirty = false;
  }

  Future<void> loadCatalogMetadata({Set<int>? ids}) async {
    final saved = await (ids != null ? localMediaDb.loadCatalogMetadataById(ids) : localMediaDb.loadCatalogMetadata());
    saved.forEach((metadata) => getEntryById(metadata.id)?.catalogMetadata = metadata);
    invalidateEntries();
    onCatalogMetadataChanged();
  }

  static bool catalogEntriesTest(AvesEntry entry) => !entry.isCatalogued;

  Future<void> catalogEntries(AnalysisController controller, Set<AvesEntry> candidateEntries) async {
    if (controller.isStopping) return;

    final force = controller.force;
    final todo = force ? candidateEntries : candidateEntries.where(catalogEntriesTest).toSet();
    if (todo.isEmpty) return;

    state = SourceState.cataloguing;
    var progressDone = controller.progressOffset;
    var progressTotal = controller.progressTotal;
    if (progressTotal == 0) {
      progressTotal = todo.length;
    }
    setProgress(done: progressDone, total: progressTotal);

    final newMetadata = <CatalogMetadata>{};
    final todoList = todo.toList();
    const concurrency = 8;
    var currentIndex = 0;
    var isSaving = false;

    Future<void> worker() async {
      while (!controller.isStopping) {
        final index = currentIndex++;
        if (index >= todoList.length) break;
        final entry = todoList[index];
        await entry.catalog(background: true, force: force, persist: true);
        if (entry.isCatalogued) {
          newMetadata.add(entry.catalogMetadata!);
          if (newMetadata.length >= commitCountThreshold && !isSaving) {
            isSaving = true;
            final toSave = Set<CatalogMetadata>.of(newMetadata);
            newMetadata.clear();
            await localMediaDb.saveCatalogMetadata(toSave);
            onCatalogMetadataChanged();
            isSaving = false;
          }
        }
        progressDone++;
        if (progressDone % 50 == 0 || progressDone >= progressTotal) {
          setProgress(done: progressDone, total: progressTotal);
        }
      }
    }

    final workers = List.generate(concurrency, (_) => worker());
    await Future.wait(workers);

    if (newMetadata.isNotEmpty) {
      await localMediaDb.saveCatalogMetadata(Set.unmodifiable(newMetadata));
      onCatalogMetadataChanged();
      newMetadata.clear();
    }
    setProgress(done: progressDone, total: progressTotal);
  }

  void onCatalogMetadataChanged() {
    _tagsDirty = true;
    invalidateTagFilterSummary();
    eventBus.fire(CatalogMetadataChangedEvent());
  }

  void updateTags() {
    _tagsDirty = true;
    invalidateTagFilterSummary();
  }

  void _computeTags() {
    final updatedTags = visibleEntries.expand((entry) => entry.tags).toSet().toList()..sort(compareAsciiUpperCaseNatural);
    if (!listEquals(updatedTags, _sortedTags)) {
      _sortedTags = List.unmodifiable(updatedTags);
      eventBus.fire(TagsChangedEvent());
    }
    _tagsDirty = false;
  }

  // filter summary

  // by tag
  final Map<String, int> _filterEntryCountMap = {}, _filterSizeMap = {};
  final Map<String, AvesEntry?> _filterRecentEntryMap = {};

  void invalidateTagFilterSummary({
    Set<AvesEntry>? entries,
    Set<String>? tags,
    bool notify = true,
  }) {
    if (_filterEntryCountMap.isEmpty && _filterSizeMap.isEmpty && _filterRecentEntryMap.isEmpty) return;

    if (entries == null && tags == null) {
      _filterEntryCountMap.clear();
      _filterSizeMap.clear();
      _filterRecentEntryMap.clear();
    } else {
      tags ??= {};
      if (entries != null) {
        tags.addAll(entries.where((entry) => entry.isCatalogued).expand((entry) => entry.tags));
      }
      tags.map((v) => TagFilter(v).key).forEach((key) {
        _filterEntryCountMap.remove(key);
        _filterSizeMap.remove(key);
        _filterRecentEntryMap.remove(key);
      });

      // clear entries for all groups
      invalidateTagGroupFilterSummary(notify: false);
    }
    if (notify) {
      eventBus.fire(TagSummaryInvalidatedEvent(tags));
      eventBus.fire(const TagGroupSummaryInvalidatedEvent());
    }
  }

  void invalidateTagGroupFilterSummary({bool notify = true}) {
    _filterEntryCountMap.removeWhere(_isTagGroupKey);
    _filterSizeMap.removeWhere(_isTagGroupKey);
    _filterRecentEntryMap.removeWhere(_isTagGroupKey);

    if (notify) {
      eventBus.fire(const TagGroupSummaryInvalidatedEvent());
    }
  }

  bool _isTagGroupKey(String key, _) => key.startsWith('${TagGroupFilter.type}-');

  int tagEntryCount(TagBaseFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter.key, () => visibleEntries.where(filter.test).length);
  }

  int tagSize(TagBaseFilter filter) {
    return _filterSizeMap.putIfAbsent(filter.key, () => visibleEntries.where(filter.test).map((v) => v.sizeBytes).sum);
  }

  AvesEntry? tagRecentEntry(TagBaseFilter filter) {
    return _filterRecentEntryMap.putIfAbsent(filter.key, () => sortedEntriesByDate.firstWhereOrNull(filter.test));
  }
}

class CatalogMetadataChangedEvent;

class TagsChangedEvent;

class TagGroupSummaryInvalidatedEvent {
  const new();
}

class TagSummaryInvalidatedEvent {
  final Set<String>? tags;

  const new(this.tags);
}
