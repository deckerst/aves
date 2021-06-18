import 'dart:math';

import 'package:aves/widgets/common/basic/outlined_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

import 'scalebar_utils.dart' as util;

class ScaleLayerOptions extends LayerOptions {
  final Widget Function(double width, String distance) builder;

  ScaleLayerOptions({
    Key? key,
    this.builder = defaultBuilder,
    rebuild,
  }) : super(key: key, rebuild: rebuild);

  static Widget defaultBuilder(double width, String distance) {
    return ScaleBar(
      distance: distance,
      width: width,
    );
  }
}

class ScaleLayerWidget extends StatelessWidget {
  final ScaleLayerOptions options;

  ScaleLayerWidget({required this.options}) : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    final mapState = MapState.maybeOf(context);
    return mapState != null ? ScaleLayer(options, mapState, mapState.onMoved) : const SizedBox();
  }
}

class ScaleLayer extends StatelessWidget {
  final ScaleLayerOptions scaleLayerOpts;
  final MapState map;
  final Stream<Null> stream;
  final scale = [
    25000000,
    15000000,
    8000000,
    4000000,
    2000000,
    1000000,
    500000,
    250000,
    100000,
    50000,
    25000,
    15000,
    8000,
    4000,
    2000,
    1000,
    500,
    250,
    100,
    50,
    25,
    10,
    5,
  ];

  ScaleLayer(this.scaleLayerOpts, this.map, this.stream) : super(key: scaleLayerOpts.key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Null>(
      stream: stream,
      builder: (context, snapshot) {
        final center = map.center;
        final latitude = center.latitude.abs();
        final level = map.zoom.round() +
            (latitude > 80
                ? 4
                : latitude > 60
                    ? 3
                    : 2);
        final distance = scale[max(0, min(20, level))].toDouble();
        final start = map.project(center);
        final targetPoint = util.calculateEndingGlobalCoordinates(center, 90, distance);
        final end = map.project(targetPoint);
        final displayDistance = distance > 999 ? '${(distance / 1000).toStringAsFixed(0)} km' : '${distance.toStringAsFixed(0)} m';
        final width = end.x - (start.x as double);

        return scaleLayerOpts.builder(width, displayDistance);
      },
    );
  }
}

class ScaleBar extends StatelessWidget {
  final String distance;
  final double width;

  static const Color fillColor = Colors.black;
  static const Color outlineColor = Colors.white;
  static const double outlineWidth = .5;
  static const double barThickness = 1;

  const ScaleBar({
    required this.distance,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.bottomStart,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedText(
            textSpans: [
              TextSpan(
                text: distance,
                style: const TextStyle(
                  color: fillColor,
                  fontSize: 11,
                ),
              )
            ],
            outlineWidth: outlineWidth * 2,
            outlineColor: outlineColor,
          ),
          Container(
            height: barThickness + outlineWidth * 2,
            width: width,
            decoration: const BoxDecoration(
              color: fillColor,
              border: Border.fromBorderSide(BorderSide(
                color: outlineColor,
                width: outlineWidth,
              )),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
