import 'dart:async';
import 'dart:math';

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
  late final Future<PaletteGenerator> _paletteLoader;

  @override
  void initState() {
    super.initState();
    final provider = widget.entry.getThumbnail(extent: min(200, widget.entry.displaySize.longestSide));
    _paletteLoader = PaletteGenerator.fromImageProvider(
      provider,
      maximumColorCount: 10,
      // do not use the default palette filter
      filters: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder<PaletteGenerator>(
        future: _paletteLoader,
        builder: (context, snapshot) {
          final colors = snapshot.data?.paletteColors;
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
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorIndicator(value: v.color),
                        const SizedBox(width: 8),
                        SelectableText(
                          '#${v.color.hex}',
                          style: const TextStyle(fontFamily: 'monospace'),
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
}
