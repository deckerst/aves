import 'package:aves/model/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

const _tileLayerBackgroundColor = Colors.transparent;

class OSMHotLayer extends StatelessWidget {
  const OSMHotLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c'],
        backgroundColor: _tileLayerBackgroundColor,
        retinaMode: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio) > 1,
        userAgentPackageName: device.userAgent,
      ),
    );
  }
}

class StamenTonerLayer extends StatelessWidget {
  const StamenTonerLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}{r}.png',
        subdomains: ['a', 'b', 'c', 'd'],
        backgroundColor: _tileLayerBackgroundColor,
        retinaMode: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio) > 1,
        userAgentPackageName: device.userAgent,
      ),
    );
  }
}

class StamenWatercolorLayer extends StatelessWidget {
  const StamenWatercolorLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg',
        subdomains: ['a', 'b', 'c', 'd'],
        backgroundColor: _tileLayerBackgroundColor,
        retinaMode: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio) > 1,
        userAgentPackageName: device.userAgent,
      ),
    );
  }
}
