import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LinearPercentIndicatorText extends StatelessWidget {
  final double percent;

  const LinearPercentIndicatorText({
    super.key,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final percentFormat = NumberFormat.percentPattern(locale);

    return OutlinedText(
      textSpans: [
        TextSpan(
          text: percentFormat.format(percent),
          style: TextStyle(
            shadows: Theme.of(context).isDark ? AStyles.embossShadows : null,
          ),
        )
      ],
      outlineColor: Themes.firstLayerColor(context),
    );
  }
}
