import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/widget_shape.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/material.dart';

class HomeWidgetPainter {
  final AvesEntry? entry;
  final double devicePixelRatio;

  static const backgroundGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: Constants.boraBoraGradientColors,
  );

  HomeWidgetPainter({
    required this.entry,
    required this.devicePixelRatio,
  });

  Future<Uint8List> drawWidget({
    required int widthPx,
    required int heightPx,
    required Color? outline,
    required WidgetShape shape,
    ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba,
  }) async {
    final widgetSizePx = Size(widthPx.toDouble(), heightPx.toDouble());
    final entryImage = await _getEntryImage(entry, shape.size(widgetSizePx));

    final recorder = ui.PictureRecorder();
    final rect = Rect.fromLTWH(0, 0, widgetSizePx.width, widgetSizePx.height);
    final canvas = Canvas(recorder, rect);
    final path = shape.path(widgetSizePx, devicePixelRatio);
    canvas.clipPath(path);
    if (entryImage != null) {
      canvas.drawImage(entryImage, Offset(widgetSizePx.width - entryImage.width, widgetSizePx.height - entryImage.height) / 2, Paint());
    } else {
      canvas.drawPaint(Paint()..shader = backgroundGradient.createShader(rect));
    }
    if (outline != null) {
      drawOutline(canvas, path, devicePixelRatio, outline);
    }
    final widgetImage = await recorder.endRecording().toImage(widthPx, heightPx);
    final byteData = await widgetImage.toByteData(format: format);
    return byteData?.buffer.asUint8List() ?? Uint8List(0);
  }

  static void drawOutline(ui.Canvas canvas, ui.Path outlinePath, double devicePixelRatio, Color color) {
    canvas.drawPath(
        outlinePath,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = AvesFilterChip.outlineWidth * devicePixelRatio * 2
          ..strokeCap = StrokeCap.round);
  }

  FutureOr<ui.Image?> _getEntryImage(AvesEntry? entry, Size sizePx) async {
    if (entry == null) return null;

    final provider = entry.getThumbnail(extent: sizePx.longestSide / devicePixelRatio);

    final imageInfoCompleter = Completer<ImageInfo?>();
    final imageStream = provider.resolve(ImageConfiguration.empty);
    final imageStreamListener = ImageStreamListener((image, synchronousCall) async {
      imageInfoCompleter.complete(image);
    }, onError: imageInfoCompleter.completeError);
    imageStream.addListener(imageStreamListener);
    ImageInfo? regionImageInfo;
    try {
      regionImageInfo = await imageInfoCompleter.future;
    } catch (error) {
      debugPrint('failed to get widget image for entry=$entry with error=$error');
    }
    imageStream.removeListener(imageStreamListener);
    return regionImageInfo?.image;
  }
}
