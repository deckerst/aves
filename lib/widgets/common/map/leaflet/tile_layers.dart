import 'package:aves/model/device.dart';
import 'package:aves/widgets/common/map/leaflet/vector_style_reader_extra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

class OpenTopoMapLayer extends StatelessWidget {
  const OpenTopoMapLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c'],
      retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
      userAgentPackageName: device.userAgent,
    );
  }
}

class OSMHotLayer extends StatelessWidget {
  const OSMHotLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c'],
      retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
      userAgentPackageName: device.userAgent,
    );
  }
}

class StamenWatercolorLayer extends StatelessWidget {
  const StamenWatercolorLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://watercolormaps.collection.cooperhewitt.org/tile/watercolor/{z}/{x}/{y}.jpg',
      retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
      userAgentPackageName: device.userAgent,
    );
  }
}

class OsmLibertyLayer extends StatefulWidget {
  const OsmLibertyLayer({super.key});

  @override
  State<OsmLibertyLayer> createState() => _OsmLibertyLayerState();
}

class _OsmLibertyLayerState extends State<OsmLibertyLayer> {
  late final Future<TileProviders> _tileProviderFuture;
  late final Future<Style> _styleFuture;

  static const _openMapTileProviderSource = 'openmaptiles';

  // `Americana` provides tiles, but it uses layer syntax that is not supported by the vector tile renderer.
  // Full style is at 'https://americanamap.org/style.json' but it is heavy (1.0 MB, mostly for the layers).
  static const _americanaTileProviderUri = 'https://tile.ourmap.us/data/v3.json';

  // `OSM Liberty` is well supported by the vector tile renderer, but it requires an API key for the tiles.
  static const _osmLibertyStyleUri = 'https://maputnik.github.io/osm-liberty/style.json';

  // as of 2024/09/25,
  // Americana provider JSON:     39.4 kB
  // OSM Liberty style JSON:      48.3 kB
  // OSM Liberty sprites JSON 1x: 16.6 kB
  // OSM Liberty sprites  PNG 1x: 30.4 kB
  // OSM Liberty sprites JSON 2x: 16.6 kB
  // OSM Liberty sprites  PNG 2x: 82.5 kB
  // -> total overhead:          233.8 kB

  @override
  void initState() {
    super.initState();

    _tileProviderFuture = StyleReaderExtra.readProviderByName(
      {
        _openMapTileProviderSource: {
          'url': _americanaTileProviderUri,
          'type': 'vector',
        }
      },
    ).then(TileProviders.new);

    _styleFuture = StyleReader(
      uri: _osmLibertyStyleUri,
      logger: const vtr.Logger.console(),
    ).readExtra(skipSources: true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TileProviders>(
      future: _tileProviderFuture,
      builder: (context, tileProviderSnapshot) {
        return FutureBuilder<Style>(
          future: _styleFuture,
          builder: (context, styleSnapshot) {
            if (tileProviderSnapshot.hasError) return Text(tileProviderSnapshot.error.toString());
            if (styleSnapshot.hasError) return Text(styleSnapshot.error.toString());

            final tileProviders = tileProviderSnapshot.data;
            final style = styleSnapshot.data;
            if (tileProviders == null || style == null) return const SizedBox();

            return VectorTileLayer(
              tileProviders: tileProviders,
              theme: style.theme,
              sprites: style.sprites,
              // `vector` is higher quality and follows map orientation, but it is slower
              layerMode: VectorTileLayerMode.raster,
            );
          },
        );
      },
    );
  }
}
