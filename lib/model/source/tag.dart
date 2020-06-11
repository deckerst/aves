import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

mixin TagMixin on SourceBase {
  List<String> sortedTags = List.unmodifiable([]);

  Future<void> loadCatalogMetadata() async {
    final stopwatch = Stopwatch()..start();
    final saved = await metadataDb.loadMetadataEntries();
    rawEntries.forEach((entry) {
      final contentId = entry.contentId;
      entry.catalogMetadata = saved.firstWhere((metadata) => metadata.contentId == contentId, orElse: () => null);
    });
    debugPrint('$runtimeType loadCatalogMetadata complete in ${stopwatch.elapsed.inMilliseconds}ms for ${saved.length} saved entries');
    onCatalogMetadataChanged();
  }

  Future<void> catalogEntries() async {
    final stopwatch = Stopwatch()..start();
    final uncataloguedEntries = rawEntries.where((entry) => !entry.isCatalogued).toList();
    if (uncataloguedEntries.isEmpty) return;

    final newMetadata = <CatalogMetadata>[];
    await Future.forEach<ImageEntry>(uncataloguedEntries, (entry) async {
      await entry.catalog();
      if (entry.isCatalogued) {
        newMetadata.add(entry.catalogMetadata);
        if (newMetadata.length >= 500) {
          await metadataDb.saveMetadata(List.unmodifiable(newMetadata));
          newMetadata.clear();
        }
      }
    });
    await metadataDb.saveMetadata(List.unmodifiable(newMetadata));
    onCatalogMetadataChanged();
    debugPrint('$runtimeType catalogEntries complete in ${stopwatch.elapsed.inSeconds}s with ${newMetadata.length} new entries');
  }

  void onCatalogMetadataChanged() {
    updateTags();
    eventBus.fire(CatalogMetadataChangedEvent());
  }

  void updateTags() {
    final tags = rawEntries.expand((entry) => entry.xmpSubjects).toSet().toList()..sort(compareAsciiUpperCase);
    sortedTags = List.unmodifiable(tags);
    invalidateFilterEntryCounts();
    eventBus.fire(TagsChangedEvent());
  }

  Map<String, ImageEntry> getTagEntries() {
    final entries = sortedEntriesForFilterList;
    return Map.fromEntries(sortedTags.map((tag) => MapEntry(
          tag,
          entries.firstWhere((entry) => entry.xmpSubjects.contains(tag), orElse: () => null),
        )));
  }
}

class CatalogMetadataChangedEvent {}

class TagsChangedEvent {}
