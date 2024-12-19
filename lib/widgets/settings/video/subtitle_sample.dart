import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/widgets/common/basic/text/background_painter.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/viewer/visual/video/subtitle/subtitle.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubtitleSample extends StatelessWidget {
  const SubtitleSample({super.key});

  @override
  Widget build(BuildContext context) {
    final textSpans = [
      TextSpan(text: context.l10n.settingsSubtitleThemeSample),
    ];

    return Consumer<Settings>(
      builder: (context, settings, child) {
        final textAlign = settings.subtitleTextAlignment;
        final textPosition = settings.subtitleTextPosition;
        final outlineColor = Colors.black.withValues(alpha: settings.subtitleTextColor.a);
        final shadows = [
          Shadow(
            color: outlineColor,
            offset: VideoSubtitles.baseShadowOffset,
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: AlignmentDirectional.bottomStart,
              end: AlignmentDirectional.topEnd,
              colors: AColors.boraBoraGradient,
            ),
            border: AvesBorder.border(context),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          height: 128,
          child: AnimatedAlign(
            alignment: _getAlignment(textAlign, textPosition),
            curve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 400),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedDefaultTextStyle(
                style: TextStyle(
                  color: settings.subtitleTextColor,
                  fontSize: settings.subtitleFontSize,
                  shadows: settings.subtitleShowOutline ? shadows : null,
                ),
                textAlign: textAlign,
                duration: const Duration(milliseconds: 200),
                child: Builder(
                  builder: (context) => TextBackgroundPainter(
                    spans: textSpans,
                    style: DefaultTextStyle.of(context).style.copyWith(
                          backgroundColor: settings.subtitleBackgroundColor,
                        ),
                    textAlign: textAlign,
                    child: OutlinedText(
                      textSpans: textSpans,
                      outlineWidth: settings.subtitleShowOutline ? 1 : 0,
                      outlineColor: outlineColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Alignment _getAlignment(TextAlign textAlign, SubtitlePosition textPosition) {
    switch (textPosition) {
      case SubtitlePosition.top:
        switch (textAlign) {
          case TextAlign.left:
            return Alignment.topLeft;
          case TextAlign.right:
            return Alignment.topRight;
          case TextAlign.center:
          default:
            return Alignment.topCenter;
        }
      case SubtitlePosition.bottom:
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
}
