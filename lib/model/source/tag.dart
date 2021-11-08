import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin TagMixin on SourceBase {
  static const commitCountThreshold = 400;
  static const _stopCheckCountThreshold = 100;

  List<String> sortedTags = List.unmodifiable([]);

  Future<void> loadCatalogMetadata() async {
    final saved = await metadataDb.loadAllMetadataEntries();
    final idMap = entryById;
    saved.forEach((metadata) => idMap[metadata.contentId]?.catalogMetadata = metadata);
    onCatalogMetadataChanged();
  }

  static bool catalogEntriesTest(AvesEntry entry) => !entry.isCatalogued;

  Future<void> catalogEntries(AnalysisController controller, Set<AvesEntry> candidateEntries) async {
    if (controller.isStopping) return;

    final force = controller.force;
    final todo = force ? candidateEntries : candidateEntries.where(catalogEntriesTest).toSet();
    if (todo.isEmpty) return;

    stateNotifier.value = SourceState.cataloguing;
    var progressDone = 0;
    final progressTotal = todo.length;
    setProgress(done: progressDone, total: progressTotal);

    var stopCheckCount = 0;
    final newMetadata = <CatalogMetadata>{};
    for (final entry in todo) {
      await entry.catalog(background: true, persist: true, force: force);
      if (entry.isCatalogued) {
        newMetadata.add(entry.catalogMetadata!);
        if (newMetadata.length >= commitCountThreshold) {
          await metadataDb.saveMetadata(Set.unmodifiable(newMetadata));
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
    await metadataDb.saveMetadata(Set.unmodifiable(newMetadata));
    onCatalogMetadataChanged();
  }

  void onCatalogMetadataChanged() {
    updateTags();
    eventBus.fire(CatalogMetadataChangedEvent());
  }

  void updateTags() {
    final updatedTags = visibleEntries.expand((entry) => entry.xmpSubjects).toSet().toList()..sort(compareAsciiUpperCase);
    if (!listEquals(updatedTags, sortedTags)) {
      sortedTags = List.unmodifiable(updatedTags);
      invalidateTagFilterSummary();
      eventBus.fire(TagsChangedEvent());
    }
  }

  // filter summary

  // by tag
  final Map<String, int> _filterEntryCountMap = {};
  final Map<String, AvesEntry?> _filterRecentEntryMap = {};

  void invalidateTagFilterSummary([Set<AvesEntry>? entries]) {
    if (_filterEntryCountMap.isEmpty && _filterRecentEntryMap.isEmpty) return;

    Set<String>? tags;
    if (entries == null) {
      _filterEntryCountMap.clear();
      _filterRecentEntryMap.clear();
    } else {
      tags = entries.where((entry) => entry.isCatalogued).expand((entry) => entry.xmpSubjects).toSet();
      tags.forEach(_filterEntryCountMap.remove);
    }
    eventBus.fire(TagSummaryInvalidatedEvent(tags));
  }

  int tagEntryCount(TagFilter filter) {
    return _filterEntryCountMap.putIfAbsent(filter.tag, () => visibleEntries.where(filter.test).length);
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
