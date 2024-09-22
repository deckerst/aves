import 'package:aves/model/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

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
