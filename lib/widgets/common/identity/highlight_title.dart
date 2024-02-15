
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/fx/highlight_decoration.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HighlightTitle extends StatelessWidget {
  final String title;
  final Color? color;
  final double fontSize;
  final bool enabled;
  final bool showHighlight;

  const HighlightTitle({
    super.key,
    required this.title,
    this.color,
    this.fontSize = 18,
    this.enabled = true,
    this.showHighlight = true,
  });

  static const disabledColor = Colors.grey;

  static List<Shadow> shadows(BuildContext context) => [
        Shadow(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          offset: const Offset(0, 1),
          blurRadius: 2,
        )
      ];

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      shadows: shadows(context),
      fontSize: fontSize,
      letterSpacing: 1.0,
      fontFeatures: const [FontFeature.enable('smcp')],
    );

    final colors = context.watch<AvesColorsData>();
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: showHighlight && context.select<Settings, bool>((v) => v.themeColorMode == AvesThemeColorMode.polychrome)
            ? HighlightDecoration(
                color: enabled ? color ?? colors.fromString(title) : disabledColor,
              )
            : null,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: OutlinedText(
          textSpans: [
            TextSpan(
              text: title,
              style: style,
            ),
          ],
          outlineColor: Theme.of(context).colorScheme.background,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      ),
    );
  }
}
