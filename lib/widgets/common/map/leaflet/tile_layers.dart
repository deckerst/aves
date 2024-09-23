import 'package:aves/model/device.dart';
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

class OsmAmericanaLayer extends StatefulWidget {
  const OsmAmericanaLayer({super.key});

  @override
  State<OsmAmericanaLayer> createState() => _OsmAmericanaLayerState();
}

class _OsmAmericanaLayerState extends State<OsmAmericanaLayer> {
  late final Future<Style> _styleFuture;

  @override
  void initState() {
    super.initState();
    _styleFuture = StyleReader(
      uri: 'https://americanamap.org/style.json',
      logger: const vtr.Logger.console(),
    ).read();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Style>(
      future: _styleFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());

        final style = snapshot.data;
        if (style == null) return const SizedBox();

        return VectorTileLayer(
          tileProviders: style.providers,
          theme: style.theme,
          sprites: style.sprites,
        );
      },
    );
  }
}
