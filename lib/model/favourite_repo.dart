import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/utils/change_notifier.dart';

final FavouriteRepo favourites = FavouriteRepo._private();

class FavouriteRepo {
  List<FavouriteRow> _rows = [];

  final AChangeNotifier changeNotifier = AChangeNotifier();

  FavouriteRepo._private();

  Future<void> init() async {
    _rows = await metadataDb.loadFavourites();
  }

  int get count => _rows.length;

  bool isFavourite(ImageEntry entry) => _rows.any((row) => row.contentId == entry.contentId);

  FavouriteRow _entryToRow(ImageEntry entry) => FavouriteRow(contentId: entry.contentId, path: entry.path);

  Future<void> add(Iterable<ImageEntry> entries) async {
    final newRows = entries.map(_entryToRow);
    await metadataDb.addFavourites(newRows);
    _rows.addAll(newRows);
    changeNotifier.notifyListeners();
  }

  Future<void> remove(Iterable<ImageEntry> entries) async {
    final removedRows = entries.map(_entryToRow);
    await metadataDb.removeFavourites(removedRows);
    removedRows.forEach(_rows.remove);
    changeNotifier.notifyListeners();
  }

  Future<void> move(int oldContentId, ImageEntry entry) async {
    final oldRow = _rows.firstWhere((row) => row.contentId == oldContentId, orElse: () => null);
    if (oldRow != null) {
      _rows.remove(oldRow);

      final newRow = _entryToRow(entry);
      await metadataDb.updateFavouriteId(oldContentId, newRow);
      _rows.add(newRow);
      changeNotifier.notifyListeners();
    }
  }

  Future<void> clear() async {
    await metadataDb.clearFavourites();
    _rows.clear();
    changeNotifier.notifyListeners();
  }
}
