import 'package:aves/model/geotiff.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoTiffTileProvider extends TileProvider {
  MappedGeoTiff overlayEntry;

  GeoTiffTileProvider(this.overlayEntry);

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final tile = await overlayEntry.getTile(x, y, zoom);
    if (tile != null) {
      return Tile(tile.width, tile.height, tile.data);
    }
    return TileProvider.noTile;
  }
}
