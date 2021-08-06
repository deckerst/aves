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
        retinaMode: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio) > 1,
      ),
    );
  }
}
