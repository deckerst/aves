import 'package:aves/widgets/about/title.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class AboutCredits extends StatelessWidget {
  const AboutCredits({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AboutSectionTitle(text: context.l10n.aboutCreditsSectionTitle),
          const SizedBox(height: 8),
          buildBody(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static Widget buildBody(BuildContext context) {
    final l10n = context.l10n;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: l10n.aboutCreditsWorldAtlas1),
          const WidgetSpan(
            child: LinkChip(
              text: 'World Atlas',
              urlString: 'https://github.com/topojson/world-atlas',
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            alignment: PlaceholderAlignment.middle,
          ),
          TextSpan(text: l10n.aboutCreditsWorldAtlas2),
        ],
      ),
    );
  }
}
