import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class AboutCredits extends StatelessWidget {
  const AboutCredits({Key? key}) : super(key: key);

  static const translators = {
    'Deutsch': 'JanWaldhorn',
    'Español': 'n-berenice',
    'Русский': 'D3ZOXY',
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
          const SizedBox(height: 16),
          Text(l10n.aboutCreditsTranslators),
          ...translators.entries.map(
            (kv) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, top: 8),
                child: Text(l10n.aboutCreditsTranslatorLine(kv.key, kv.value)),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
