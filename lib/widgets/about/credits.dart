import 'dart:ui';

import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class AboutCredits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(context.l10n.aboutCredits, style: Constants.titleTextStyle),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: context.l10n.aboutCreditsWorldAtlas1),
                const WidgetSpan(
                  child: LinkChip(
                    text: 'World Atlas',
                    url: 'https://github.com/topojson/world-atlas',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
                TextSpan(text: context.l10n.aboutCreditsWorldAtlas2),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
