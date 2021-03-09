import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin TagMixin on SourceBase {
  static const _commitCountThreshold = 300;

  List<String> sortedTags = List.unmodifiable([]);

  Future<void> loadCatalogMetadata() async {
    final stopwatch = Stopwatch()..start();
    final saved = await metadataDb.loadMetadataEntries();
    visibleEntries.forEach((entry) {
      final contentId = entry.contentId;
      entry.catalogMetadata = saved.firstWhere((metadata) => metadata.contentId == contentId, orElse: () => null);
    });
    debugPrint('$runtimeType loadCatalogMetadata complete in ${stopwatch.elapsed.inMilliseconds}ms for ${saved.length} entries');
    onCatalogMetadataChanged();
  }

  Future<void> catalogEntries() async {
//    final stopwatch = Stopwatch()..start();
    final todo = visibleEntries.where((entry) => !entry.isCatalogued).toList();
    if (todo.isEmpty) return;

    stateNotifier.value = SourceState.cataloguing;
    var progressDone = 0;
    final progressTotal = todo.length;
    setProgress(done: progressDone, total: progressTotal);

    final newMetadata = <CatalogMetadata>[];
    await Future.forEach<AvesEntry>(todo, (entry) async {
      await entry.catalog(background: true);
      if (entry.isCatalogued) {
        newMetadata.add(entry.catalogMetadata);
        if (newMetadata.length >= _commitCountThreshold) {
          await metadataDb.saveMetadata(List.unmodifiable(newMetadata));
          onCatalogMetadataChanged();
          newMetadata.clear();
        }
      }
      setProgress(done: ++progressDone, total: progressTotal);
    });
    await metadataDb.saveMetadata(List.unmodifiable(newMetadata));
    onCatalogMetadataChanged();
//    debugPrint('$runtimeType catalogEntries complete in ${stopwatch.elapsed.inSeconds}s');
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
  final Map<String, AvesEntry> _filterRecentEntryMap = {};

  void invalidateTagFilterSummary([Set<AvesEntry> entries]) {
    Set<String> tags;
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

  AvesEntry tagRecentEntry(TagFilter filter) {
    return _filterRecentEntryMap.putIfAbsent(filter.tag, () => sortedEntriesByDate.firstWhere(filter.test, orElse: () => null));
  }
}

class CatalogMetadataChangedEvent {}

class TagsChangedEvent {}

class TagSummaryInvalidatedEvent {
  final Set<String> tags;

  const TagSummaryInvalidatedEvent(this.tags);
}
