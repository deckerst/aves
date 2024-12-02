import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/collection_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin TagMixin on SourceBase {
  static const commitCountThreshold = 400;
  static const _stopCheckCountThreshold = 100;

  List<String> sortedTags = List.unmodifiable([]);

  Future<void> loadCatalogMetadata({Set<int>? ids}) async {
    final saved = await (ids != null ? localMediaDb.loadCatalogMetadataById(ids) : localMediaDb.loadCatalogMetadata());
    final idMap = entryById;
    saved.forEach((metadata) => idMap[metadata.id]?.catalogMetadata = metadata);
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

    var stopCheckCount = 0;
    final newMetadata = <CatalogMetadata>{};
    for (final entry in todo) {
      await entry.catalog(background: true, force: force, persist: true);
      if (entry.isCatalogued) {
        newMetadata.add(entry.catalogMetadata!);
        if (newMetadata.length >= commitCountThreshold) {
          await localMediaDb.saveCatalogMetadata(Set.unmodifiable(newMetadata));
          onCatalogMetadataChanged();
          newMetadata.clear();
        }
        if (++stopCheckCount >= _stopCheckCountThreshold) {
          stopCheckCount = 0;
          if (controller.isStopping) return;
        }
      }
      setProgress(done: ++progressDone, total: progressTotal);
    }
    await localMediaDb.saveCatalogMetadata(Set.unmodifiable(newMetadata));
    onCatalogMetadataChanged();
  }

  void onCatalogMetadataChanged() {
    updateTags();
    eventBus.fire(CatalogMetadataChangedEvent());
  }

  void updateTags() {
    final updatedTags = visibleEntries.expand((entry) => entry.tags).toSet().toList()..sort(compareAsciiUpperCaseNatural);
    if (!listEquals(updatedTags, sortedTags)) {
      sortedTags = List.unmodifiable(updatedTags);
      invalidateTagFilterSummary();
      eventBus.fire(TagsChangedEvent());
    }
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
      tags.forEach((tag) {
        _filterEntryCountMap.remove(tag);
        _filterSizeMap.remove(tag);
        _filterRecentEntryMap.remove(tag);
      });
    }
    if (notify) {
      eventBus.fire(TagSummaryInvalidatedEvent(tags));
    }
  }

  int tagEntryCount(TagFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter.tag, () => visibleEntries.where(filter.test).length);
  }

  int tagSize(TagFilter filter) {
    return _filterSizeMap.putIfAbsent(filter.tag, () => visibleEntries.where(filter.test).map((v) => v.sizeBytes).sum);
  }

  AvesEntry? tagRecentEntry(TagFilter filter) {
    return _filterRecentEntryMap.putIfAbsent(filter.tag, () => sortedEntriesByDate.firstWhereOrNull(filter.test));
  }
}

class CatalogMetadataChangedEvent {}

class TagsChangedEvent {}

class TagSummaryInvalidatedEvent {
  final Set<String>? tags;

  const TagSummaryInvalidatedEvent(this.tags);
}
