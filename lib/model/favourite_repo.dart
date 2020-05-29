import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_db.dart';

final FavouriteRepo favourites = FavouriteRepo._private();

class FavouriteRepo {
  List<FavouriteRow> _rows = [];

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
  }

  Future<void> remove(Iterable<ImageEntry> entries) async {
    final removedRows = entries.map(_entryToRow);
    await metadataDb.removeFavourites(removedRows);
    removedRows.forEach(_rows.remove);
  }

  Future<void> clear() async {
    await metadataDb.clearFavourites();
    _rows.clear();
  }
}
