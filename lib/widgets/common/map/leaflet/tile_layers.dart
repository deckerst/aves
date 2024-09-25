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
  late final Future<Style> _americanaStyleFuture;
  late final Future<Style> _osmLibertyStyleFuture;

  static const _openMapTileProviderSource = 'openmaptiles';

  // `Americana` provides tiles, but it uses layer syntax that is not supported by the vector tile renderer
  static const _americanaStyle = 'https://americanamap.org/style.json';

  // `OSM Liberty` is well supported by the vector tile renderer, but it requires an API key for the tiles
  static const _osmLiberty = 'https://maputnik.github.io/osm-liberty/style.json';

  @override
  void initState() {
    super.initState();

    _americanaStyleFuture = StyleReader(
      uri: _americanaStyle,
    ).readExtra(skippedSources: {});

    _osmLibertyStyleFuture = StyleReader(
      uri: _osmLiberty,
      logger: const vtr.Logger.console(),
    ).readExtra(skippedSources: {_openMapTileProviderSource});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Style>(
      future: _americanaStyleFuture,
      builder: (context, americanaStyleSnapshot) {
        return FutureBuilder<Style>(
          future: _osmLibertyStyleFuture,
          builder: (context, osmLibertyStyleSnapshot) {
            if (americanaStyleSnapshot.hasError) return Text(americanaStyleSnapshot.error.toString());
            if (osmLibertyStyleSnapshot.hasError) return Text(osmLibertyStyleSnapshot.error.toString());

            final americanaStyle = americanaStyleSnapshot.data;
            final osmLibertyStyle = osmLibertyStyleSnapshot.data;
            if (americanaStyle == null || osmLibertyStyle == null) return const SizedBox();

            return VectorTileLayer(
              tileProviders: americanaStyle.providers,
              theme: osmLibertyStyle.theme,
              sprites: osmLibertyStyle.sprites,
              layerMode: VectorTileLayerMode.raster,
            );
          },
        );
      },
    );
  }
}
