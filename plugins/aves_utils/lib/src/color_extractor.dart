import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

// adapted from Flutter `ColorScheme.fromImageProvider()` utilities
class ColorExtractor {
  static Future<List<Color>> extract({
    required ByteData imageBytes,
    int maximumColorCount = 10,
  }) async {
    final quantizerResult = await extractColorsFromImageBytes(imageBytes);
    final colorToCount = quantizerResult.colorToCount.map(
      (key, value) => MapEntry<int, int>(_getArgbFromAbgr(key), value),
    );

    final scoredResults = Score.score(colorToCount, desired: maximumColorCount, filter: false);
    return scoredResults.map(Color.new).toList();
  }

  static Future<DynamicScheme> getDynamicScheme({
    required ImageProvider provider,
    Brightness brightness = Brightness.light,
    DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot,
    double contrastLevel = 0.0,
    double? maxDimension,
  }) async {
    final ui.Image scaledImage = await _imageProviderToScaled(provider, maxDimension ?? 112.0);
    final ByteData? imageBytes = await scaledImage.toByteData();
    scaledImage.dispose();
    final quantizerResult = await extractColorsFromImageBytes(imageBytes!);
    final colorToCount = quantizerResult.colorToCount.map(
      (key, value) => MapEntry<int, int>(_getArgbFromAbgr(key), value),
    );

    // Score colors for color scheme suitability.
    final scoredResults = Score.score(colorToCount, desired: 1);
    final baseColor = Color(scoredResults.first);

    return _buildDynamicScheme(
      brightness,
      baseColor,
      dynamicSchemeVariant,
      contrastLevel,
    );
  }

  static Future<QuantizerResult> extractColorsFromImageBytes(ByteData imageBytes) async {
    const maxColors = 128;
    return await QuantizerCelebi().quantize(
      imageBytes.buffer.asUint32List(),
      maxColors,
      returnInputPixelToClusterPixel: true,
    );
  }

  // Scale image size down to reduce computation time of color extraction.
  static Future<ui.Image> _imageProviderToScaled(ImageProvider imageProvider, double maxDimension) async {
    final stream = imageProvider.resolve(
      ImageConfiguration(size: Size(maxDimension, maxDimension)),
    );
    final imageInfoCompleter = Completer<ImageInfo>();
    late ImageStreamListener listener;
    late ui.Image scaledImage;
    Timer? loadFailureTimeout;

    listener = ImageStreamListener(
      (info, sync) async {
        loadFailureTimeout?.cancel();
        stream.removeListener(listener);
        final image = info.image;
        final width = image.width;
        final height = image.height;
        var paintWidth = width.toDouble();
        var paintHeight = height.toDouble();
        assert(width > 0 && height > 0);

        final rescale = width > maxDimension || height > maxDimension;
        if (rescale) {
          paintWidth = (width > height) ? maxDimension : (maxDimension / height) * width;
          paintHeight = (height > width) ? maxDimension : (maxDimension / width) * height;
        }
        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTRB(0, 0, paintWidth, paintHeight),
          image: image,
          filterQuality: FilterQuality.none,
        );

        final picture = pictureRecorder.endRecording();
        scaledImage = await picture.toImage(paintWidth.toInt(), paintHeight.toInt());
        picture.dispose();

        imageInfoCompleter.complete(info);
      },
      onError: (exception, stackTrace) {
        loadFailureTimeout?.cancel();
        stream.removeListener(listener);
        imageInfoCompleter.completeError(Exception('Failed to render image: $exception'), stackTrace);
      },
    );

    loadFailureTimeout = Timer(const Duration(seconds: 5), () {
      stream.removeListener(listener);
      imageInfoCompleter.completeError(TimeoutException('Timeout occurred trying to load image'));
    });

    stream.addListener(listener);
    final imageInfo = await imageInfoCompleter.future;
    imageInfo.dispose();

    return scaledImage;
  }

  // Converts AABBGGRR color int to AARRGGBB format.
  static int _getArgbFromAbgr(int abgr) {
    const exceptRMask = 0xFF00FFFF;
    const int onlyRMask = ~exceptRMask;
    const exceptBMask = 0xFFFFFF00;
    const int onlyBMask = ~exceptBMask;
    final int r = (abgr & onlyRMask) >> 16;
    final int b = abgr & onlyBMask;
    return (abgr & exceptRMask & exceptBMask) | (b << 16) | r;
  }

  static DynamicScheme _buildDynamicScheme(
    Brightness brightness,
    Color seedColor,
    DynamicSchemeVariant schemeVariant,
    double contrastLevel,
  ) {
    assert(
      contrastLevel >= -1.0 && contrastLevel <= 1.0,
      'contrastLevel must be between -1.0 and 1.0 inclusive.',
    );
    final isDark = brightness == Brightness.dark;
    final Hct sourceColor = Hct.fromInt(seedColor.toARGB32());
    return switch (schemeVariant) {
      DynamicSchemeVariant.tonalSpot => SchemeTonalSpot(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
      DynamicSchemeVariant.fidelity => SchemeFidelity(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
      DynamicSchemeVariant.content => SchemeContent(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
      DynamicSchemeVariant.monochrome => SchemeMonochrome(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
      DynamicSchemeVariant.neutral => SchemeNeutral(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
      DynamicSchemeVariant.vibrant => SchemeVibrant(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
      DynamicSchemeVariant.expressive => SchemeExpressive(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
      DynamicSchemeVariant.rainbow => SchemeRainbow(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
      DynamicSchemeVariant.fruitSalad => SchemeFruitSalad(
        sourceColorHct: sourceColor,
        isDark: isDark,
        contrastLevel: contrastLevel,
      ),
    };
  }
}
