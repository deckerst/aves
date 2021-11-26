import 'package:aves/widgets/aves_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

class OSMHotLayer extends StatelessWidget {
  const OSMHotLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c'],
        tileProvider: _NetworkTileProvider(),
        retinaMode: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio) > 1,
      ),
    );
  }
}

class StamenTonerLayer extends StatelessWidget {
  const StamenTonerLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}{r}.png',
        subdomains: ['a', 'b', 'c', 'd'],
        tileProvider: _NetworkTileProvider(),
        retinaMode: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio) > 1,
      ),
    );
  }
}

class StamenWatercolorLayer extends StatelessWidget {
  const StamenWatercolorLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg',
        subdomains: ['a', 'b', 'c', 'd'],
        tileProvider: _NetworkTileProvider(),
        retinaMode: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio) > 1,
      ),
    );
  }
}

class _NetworkTileProvider extends NetworkTileProvider {
  final Map<String, String> headers = {
    'User-Agent': AvesApp.userAgent,
  };

  _NetworkTileProvider();

  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return NetworkImage(getTileUrl(coords, options), headers: headers);
  }
}
