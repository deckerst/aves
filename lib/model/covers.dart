import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

final Covers covers = Covers._private();

class Covers with ChangeNotifier {
  Set<CoverRow> _rows = {};

  Covers._private();

  Future<void> init() async {
    _rows = await metadataDb.loadAllCovers();
  }

  int get count => _rows.length;

  Set<CoverRow> get all => Set.unmodifiable(_rows);

  int? coverContentId(CollectionFilter filter) => _rows.firstWhereOrNull((row) => row.filter == filter)?.contentId;

  Future<void> set(CollectionFilter filter, int? contentId) async {
    // erase contextual properties from filters before saving them
    if (filter is AlbumFilter) {
      filter = AlbumFilter(filter.album, null);
    }

    _rows.removeWhere((row) => row.filter == filter);
    if (contentId == null) {
      await metadataDb.removeCovers({filter});
    } else {
      final row = CoverRow(filter: filter, contentId: contentId);
      _rows.add(row);
      await metadataDb.addCovers({row});
    }

    notifyListeners();
  }

  Future<void> moveEntry(int oldContentId, AvesEntry entry) async {
    final oldRows = _rows.where((row) => row.contentId == oldContentId).toSet();
    if (oldRows.isEmpty) return;

    for (final oldRow in oldRows) {
      final filter = oldRow.filter;
      _rows.remove(oldRow);
      if (filter.test(entry)) {
        final newRow = CoverRow(filter: filter, contentId: entry.contentId!);
        await metadataDb.updateCoverEntryId(oldRow.contentId, newRow);
        _rows.add(newRow);
      } else {
        await metadataDb.removeCovers({filter});
      }
    }

    notifyListeners();
  }

  Future<void> removeEntries(Set<AvesEntry> entries) async {
    final contentIds = entries.map((entry) => entry.contentId).toSet();
    final removedRows = _rows.where((row) => contentIds.contains(row.contentId)).toSet();

    await metadataDb.removeCovers(removedRows.map((row) => row.filter).toSet());
    _rows.removeAll(removedRows);

    notifyListeners();
  }

  Future<void> clear() async {
    await metadataDb.clearCovers();
    _rows.clear();

    notifyListeners();
  }

  // import/export

  List<Map<String, dynamic>>? export(CollectionSource source) {
    final visibleEntries = source.visibleEntries;
    final jsonList = covers.all
        .map((row) {
          final id = row.contentId;
          final path = visibleEntries.firstWhereOrNull((entry) => id == entry.contentId)?.path;
          if (path == null) return null;

          final volume = androidFileUtils.getStorageVolume(path)?.path;
          if (volume == null) return null;

          final relativePath = path.substring(volume.length);
          return {
            'filter': row.filter.toJson(),
            'volume': volume,
            'relativePath': relativePath,
          };
        })
        .whereNotNull()
        .toList();
    return jsonList.isNotEmpty ? jsonList : null;
  }

  void import(dynamic jsonList, CollectionSource source) {
    if (jsonList is! List) {
      debugPrint('failed to import covers for jsonMap=$jsonList');
      return;
    }

    final visibleEntries = source.visibleEntries;
    jsonList.forEach((row) {
      final filter = CollectionFilter.fromJson(row['filter']);
      if (filter == null) {
        debugPrint('failed to import cover for row=$row');
        return;
      }

      final volume = row['volume'];
      final relativePath = row['relativePath'];
      if (volume is String && relativePath is String) {
        final path = pContext.join(volume, relativePath);
        final entry = visibleEntries.firstWhereOrNull((entry) => entry.path == path && filter.test(entry));
        if (entry != null) {
          covers.set(filter, entry.contentId);
        } else {
          debugPrint('failed to import cover for path=$path, filter=$filter');
        }
      } else {
        debugPrint('failed to import cover for volume=$volume, relativePath=$relativePath, filter=$filter');
      }
    });
  }
}

@immutable
class CoverRow extends Equatable {
  final CollectionFilter filter;
  final int contentId;

  @override
  List<Object?> get props => [filter, contentId];

  const CoverRow({
    required this.filter,
    required this.contentId,
  });

  static CoverRow? fromMap(Map map) {
    final filter = CollectionFilter.fromJson(map['filter']);
    if (filter == null) return null;
    return CoverRow(
      filter: filter,
      contentId: map['contentId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'filter': filter.toJson(),
        'contentId': contentId,
      };
}
