import 'dart:async';
import 'dart:ui';

import 'package:aves/model/settings/settings.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum HistogramChannel { red, green, blue, luminance }

typedef HistogramLevels = Map<HistogramChannel, List<double>>;

mixin HistogramMixin {
  HistogramLevels _levels = {};
  Completer? _completer;

  static const int bins = 256;

  Future<HistogramLevels> getHistogramLevels(ImageInfo info, bool forceUpdate) async {
    if (_levels.isEmpty || forceUpdate) {
      if (_completer == null) {
        _completer = Completer();
        final data = (await info.image.toByteData(format: ImageByteFormat.rawStraightRgba))!;
        _levels = switch (settings.overlayHistogramStyle) {
          OverlayHistogramStyle.rgb => await compute<ByteData, HistogramLevels>(_computeRgbLevels, data),
          OverlayHistogramStyle.luminance => await compute<ByteData, HistogramLevels>(_computeLuminanceLevels, data),
          _ => <HistogramChannel, List<double>>{},
        };
        _completer?.complete();
      } else {
        await _completer?.future;
        _completer = null;
      }
    }
    return _levels;
  }

  static HistogramLevels _computeRgbLevels(ByteData data) {
    final redLevels = List.filled(bins, 0);
    final greenLevels = List.filled(bins, 0);
    final blueLevels = List.filled(bins, 0);

    final view = Uint8List.view(data.buffer);
    final pixelCount = view.length / 4;
    for (var i = 0; i < pixelCount; i += 4) {
      final a = view[i + 3];
      if (a > 0) {
        final r = view[i + 0];
        final g = view[i + 1];
        final b = view[i + 2];
        redLevels[r]++;
        greenLevels[g]++;
        blueLevels[b]++;
      }
    }

    final max = [
      redLevels.max,
      greenLevels.max,
      blueLevels.max,
    ].max;
    if (max == 0) return {};

    final f = 1.0 / max;
    return {
      HistogramChannel.red: redLevels.map((v) => v * f).toList(),
      HistogramChannel.green: greenLevels.map((v) => v * f).toList(),
      HistogramChannel.blue: blueLevels.map((v) => v * f).toList(),
    };
  }

  static HistogramLevels _computeLuminanceLevels(ByteData data) {
    final lumLevels = List.filled(bins, 0);
    const normMax = bins - 1;

    final view = Uint8List.view(data.buffer);
    final pixelCount = view.length / 4;
    for (var i = 0; i < pixelCount; i += 4) {
      final a = view[i + 3];
      if (a > 0) {
        final r = view[i + 0];
        final g = view[i + 1];
        final b = view[i + 2];
        lumLevels[(Color.fromARGB(a, r, g, b).computeLuminance() * normMax).round()]++;
      }
    }

    final max = lumLevels.max;
    if (max == 0) return {};

    final f = 1.0 / max;
    return {
      HistogramChannel.luminance: lumLevels.map((v) => v * f).toList(),
    };
  }
}
