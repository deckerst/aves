import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/common/fx/highlight_decoration.dart';
import 'package:aves/widgets/settings/language/locales.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const HighlightTitle({
  super.key,
  required final String title,
  required final KnownLocale? locale,
  final Color? color,
  final double fontSize = 18,
  final bool enabled = true,
  final bool showHighlight = true,
}) extends StatelessWidget {
  static const disabledColor = Colors.grey;

  static List<Shadow> shadows(BuildContext context) => [
    Shadow(
      color: Theme.of(context).isDark ? Colors.black : Colors.white,
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final style = AStyles.sectionTitleStyle(locale).copyWith(
      fontSize: fontSize,
      shadows: shadows(context),
    );

    final colors = context.watch<AvesColorsData>();
    return Align(
      alignment: .centerStart,
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
          outlineColor: Themes.firstLayerColor(context),
          softWrap: false,
          overflow: .fade,
          maxLines: 1,
        ),
      ),
    );
  }
}
