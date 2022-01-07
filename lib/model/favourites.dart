import 'package:aves/model/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

final Favourites favourites = Favourites._private();

class Favourites with ChangeNotifier {
  Set<FavouriteRow> _rows = {};

  Favourites._private();

  Future<void> init() async {
    _rows = await metadataDb.loadAllFavourites();
  }

  int get count => _rows.length;

  bool isFavourite(AvesEntry entry) => _rows.any((row) => row.contentId == entry.contentId);

  FavouriteRow _entryToRow(AvesEntry entry) => FavouriteRow(contentId: entry.contentId!, path: entry.path!);

  Future<void> add(Set<AvesEntry> entries) async {
    final newRows = entries.map(_entryToRow);

    await metadataDb.addFavourites(newRows);
    _rows.addAll(newRows);

    notifyListeners();
  }

  Future<void> remove(Set<AvesEntry> entries) async {
    final contentIds = entries.map((entry) => entry.contentId).toSet();
    final removedRows = _rows.where((row) => contentIds.contains(row.contentId)).toSet();

    await metadataDb.removeFavourites(removedRows);
    removedRows.forEach(_rows.remove);

    notifyListeners();
  }

  Future<void> moveEntry(int oldContentId, AvesEntry entry) async {
    final oldRow = _rows.firstWhereOrNull((row) => row.contentId == oldContentId);
    if (oldRow == null) return;

    final newRow = _entryToRow(entry);

    await metadataDb.updateFavouriteId(oldContentId, newRow);
    _rows.remove(oldRow);
    _rows.add(newRow);

    notifyListeners();
  }

  Future<void> clear() async {
    await metadataDb.clearFavourites();
    _rows.clear();

    notifyListeners();
  }
}

@immutable
class FavouriteRow extends Equatable {
  final int contentId;
  final String path;

  @override
  List<Object?> get props => [contentId, path];

  const FavouriteRow({
    required this.contentId,
    required this.path,
  });

  factory FavouriteRow.fromMap(Map map) {
    return FavouriteRow(
      contentId: map['contentId'] ?? 0,
      path: map['path'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'path': path,
      };
}
