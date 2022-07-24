import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/outlined_text.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/viewer/visual/subtitle/subtitle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubtitleSample extends StatelessWidget {
  const SubtitleSample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) {
        final outlineColor = Colors.black.withOpacity(settings.subtitleTextColor.opacity);
        final shadows = [
          Shadow(
            color: outlineColor,
            offset: VideoSubtitles.baseShadowOffset,
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: Constants.boraBoraGradientColors,
            ),
            border: AvesBorder.border(context),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          height: 128,
          child: AnimatedAlign(
            alignment: _getAlignment(settings.subtitleTextAlignment),
            curve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 400),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedDefaultTextStyle(
                style: TextStyle(
                  color: settings.subtitleTextColor,
                  backgroundColor: settings.subtitleBackgroundColor,
                  fontSize: settings.subtitleFontSize,
                  shadows: settings.subtitleShowOutline ? shadows : null,
                ),
                textAlign: settings.subtitleTextAlignment,
                duration: const Duration(milliseconds: 200),
                child: OutlinedText(
                  textSpans: [
                    TextSpan(
                      text: context.l10n.settingsSubtitleThemeSample,
                    ),
                  ],
                  outlineWidth: settings.subtitleShowOutline ? 1 : 0,
                  outlineColor: outlineColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Alignment _getAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
        return Alignment.bottomLeft;
      case TextAlign.right:
        return Alignment.bottomRight;
      case TextAlign.center:
      default:
        return Alignment.bottomCenter;
    }
  }
}
