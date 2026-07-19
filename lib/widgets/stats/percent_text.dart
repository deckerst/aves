import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:flutter/material.dart';

class LinearPercentIndicatorText extends StatelessWidget {
  final double percent;

  const LinearPercentIndicatorText({
    super.key,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final percentFormatter = settings.avesLocale.percentNumberFormat();

    return OutlinedText(
      textSpans: [
        TextSpan(
          text: percentFormatter.format(percent),
          style: TextStyle(
            shadows: Theme.of(context).isDark ? AStyles.embossShadows : null,
          ),
        ),
      ],
      outlineColor: Themes.firstLayerColor(context),
    );
  }
}
