import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/filters/container/tag_group.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/source/analysis_controller.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/filter_summary.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin TagMixin on SourceBase {
  static const commitCountThreshold = 400;
  static const _stopCheckCountThreshold = 100;

  List<String> sortedTags = List.unmodifiable([]);

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
  final Map<String, FilterSummary> _filterSummary = {};

  void invalidateTagFilterSummary({
    Set<AvesEntry>? entries,
    Set<String>? tags,
    bool notify = true,
  }) {
    if (_filterSummary.isEmpty) return;

    if (entries == null && tags == null) {
      _filterSummary.clear();
    } else {
      tags ??= {};
      if (entries != null) {
        tags.addAll(entries.where((entry) => entry.isCatalogued).expand((entry) => entry.tags));
      }
      tags.map((v) => TagFilter(v).key).forEach(_filterSummary.remove);

      // clear entries for all groups
      invalidateTagGroupFilterSummary(notify: false);
    }
    if (notify) {
      eventBus.fire(TagSummaryInvalidatedEvent(tags));
      eventBus.fire(const TagGroupSummaryInvalidatedEvent());
    }
  }

  void invalidateTagGroupFilterSummary({bool notify = true}) {
    _filterSummary.removeWhere(_isTagGroupKey);

    if (notify) {
      eventBus.fire(const TagGroupSummaryInvalidatedEvent());
    }
  }

  bool _isTagGroupKey(String key, _) => key.startsWith('${TagGroupFilter.type}-');

  FilterSummary _getSummary(TagBaseFilter filter) {
    return _filterSummary.putIfAbsent(filter.key, () => computeFilterSummary(filter));
  }

  int tagEntryCount(TagBaseFilter filter) => _getSummary(filter).entryCount;

  int tagSize(TagBaseFilter filter) => _getSummary(filter).size;

  AvesEntry? tagRecentEntry(TagBaseFilter filter) => _getSummary(filter).recentEntry;
}

class CatalogMetadataChangedEvent;

class TagsChangedEvent;

class const TagGroupSummaryInvalidatedEvent();

class const TagSummaryInvalidatedEvent(final Set<String>? tags);
