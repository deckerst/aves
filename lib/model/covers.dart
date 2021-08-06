import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/services.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final Covers covers = Covers._private();

class Covers with ChangeNotifier {
  Set<CoverRow> _rows = {};

  Covers._private();

  Future<void> init() async {
    _rows = await metadataDb.loadCovers();
  }

  int get count => _rows.length;

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
