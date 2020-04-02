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

  Future<void> add(ImageEntry entry) async {
    final newRows = [FavouriteRow(contentId: entry.contentId, path: entry.path)];
    await metadataDb.addFavourites(newRows);
    _rows.addAll(newRows);
  }

  Future<void> remove(ImageEntry entry) async {
    final removedRows = [FavouriteRow(contentId: entry.contentId, path: entry.path)];
    await metadataDb.removeFavourites(removedRows);
    removedRows.forEach(_rows.remove);
  }

  Future<void> clear() async {
    await metadataDb.clearFavourites();
    _rows.clear();
  }
}
