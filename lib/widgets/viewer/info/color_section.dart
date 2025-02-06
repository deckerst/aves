import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/color_indicator.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flex_color_picker/flex_color_picker.dart' as flex;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class ColorSectionSliver extends StatefulWidget {
  final AvesEntry entry;

  const ColorSectionSliver({super.key, required this.entry});

  @override
  State<ColorSectionSliver> createState() => _ColorSectionSliverState();
}

class _ColorSectionSliverState extends State<ColorSectionSliver> {
  late final Future<List<Color>> _paletteLoader;

  @override
  void initState() {
    super.initState();
    final provider = widget.entry.getThumbnail(extent: min(200, widget.entry.displaySize.longestSide));
    _paletteLoader = _loadPalette(provider);
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder<List<Color>>(
        future: _paletteLoader,
        builder: (context, snapshot) {
          final colors = snapshot.data;
          if (colors == null || colors.isEmpty) return const SizedBox();

          final durations = context.watch<DurationsData>();
          return Wrap(
            alignment: WrapAlignment.center,
            children: AnimationConfiguration.toStaggeredList(
              duration: durations.staggeredAnimation,
              delay: durations.staggeredAnimationDelay * timeDilation,
              childAnimationBuilder: (child) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: child,
                ),
              ),
              children: [
                const SectionRow(icon: AIcons.palette),
                ...colors.map(
                  (v) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorIndicator(value: v),
                        const SizedBox(width: 8),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: SelectableText(
                            '#${v.hex}',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // `PaletteGenerator.fromImage()` directly blocks the main isolate,
  // so we use another isolate to compute the palette
  Future<List<Color>> _loadPalette(ImageProvider provider) async {
    final stream = provider.resolve(ImageConfiguration.empty);
    final imageCompleter = Completer<ui.Image>();
    late ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      stream.removeListener(listener);
      imageCompleter.complete(info.image);
    });
    stream.addListener(listener);
    final image = await imageCompleter.future;
    final imageData = await image.toByteData();
    if (imageData == null) {
      throw StateError('Failed to encode the image.');
    }

    final encodedImage = EncodedImage(
      imageData,
      width: image.width,
      height: image.height,
    );
    final generator = await _getPaletteGenerator(encodedImage);
    return generator.paletteColors.map((v) => v.color).toList();
  }

  // the isolate does not start unless called from a static method
  static Future<PaletteGenerator> _getPaletteGenerator(EncodedImage encodedImage) {
    // `Isolate.run()` closure supports passing `EncodedImage` but not `ui.Image`
    return Isolate.run(() => PaletteGenerator.fromByteData(
          encodedImage,
          maximumColorCount: 10,
          // do not use the default palette filter
          filters: [],
        ));
  }
}
