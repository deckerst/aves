import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';

class AboutCredits extends StatelessWidget {
  const AboutCredits({Key? key}) : super(key: key);

  static const translators = {
    'Bahasa Indonesia': 'MeFinity',
    'Deutsch': 'JanWaldhorn',
    'Español (México)': 'n-berenice',
    'Italiano': 'glemco',
    'Português (Brasil)': 'Jonatas De Almeida Barros',
    'Русский': 'D3ZOXY',
    '日本語': 'Maki',
    '简体中文': '小默, Aerowolf',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.aboutCredits, style: Constants.titleTextStyle),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l10n.aboutCreditsWorldAtlas1),
                const WidgetSpan(
                  child: LinkChip(
                    text: 'World Atlas',
                    url: 'https://github.com/topojson/world-atlas',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
                TextSpan(text: l10n.aboutCreditsWorldAtlas2),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.aboutCreditsTranslators, style: Constants.titleTextStyle),
            ),
          ),
          const InfoRowGroup(info: translators),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
