import 'package:aves/model/entry.dart';
import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final Favourites favourites = Favourites._private();

class Favourites with ChangeNotifier {
  Set<FavouriteRow> _rows = {};

  Favourites._private();

  Future<void> init() async {
    _rows = await metadataDb.loadFavourites();
  }

  int get count => _rows.length;

  bool isFavourite(AvesEntry entry) => _rows.any((row) => row.contentId == entry.contentId);

  FavouriteRow _entryToRow(AvesEntry entry) => FavouriteRow(contentId: entry.contentId, path: entry.path);

  Future<void> add(Iterable<AvesEntry> entries) async {
    final newRows = entries.map(_entryToRow);

    await metadataDb.addFavourites(newRows);
    _rows.addAll(newRows);

    notifyListeners();
  }

  Future<void> remove(Iterable<AvesEntry> entries) async {
    final contentIds = entries.map((entry) => entry.contentId).toSet();
    final removedRows = _rows.where((row) => contentIds.contains(row.contentId)).toSet();

    await metadataDb.removeFavourites(removedRows);
    removedRows.forEach(_rows.remove);

    notifyListeners();
  }

  Future<void> moveEntry(int oldContentId, AvesEntry entry) async {
    final oldRow = _rows.firstWhere((row) => row.contentId == oldContentId, orElse: () => null);
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
class FavouriteRow {
  final int contentId;
  final String path;

  const FavouriteRow({
    this.contentId,
    this.path,
  });

  factory FavouriteRow.fromMap(Map map) {
    return FavouriteRow(
      contentId: map['contentId'],
      path: map['path'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'contentId': contentId,
        'path': path,
      };

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FavouriteRow && other.contentId == contentId && other.path == path;
  }

  @override
  int get hashCode => hashValues(contentId, path);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{contentId=$contentId, path=$path}';
}
