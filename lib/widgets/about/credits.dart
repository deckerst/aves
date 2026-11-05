import 'package:aves/theme/text.dart';
import 'package:aves/widgets/about/title.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';

class AboutCredits extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: .start,
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

    final topojson = l10n.aboutCreditsWorldAtlas('https://github.com/topojson/world-atlas');

    final stateFlags =
        '${l10n.aboutCreditsStateFlags}\n'
        '- ${[
          'Maine',
          '© [Enzwell](https://commons.wikimedia.org/wiki/File:Flag_of_the_State_of_Maine.svg#Licensing)',
          '[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.en)',
        ].join(AText.separator)}';

    final mdTextStyle = DefaultTextStyle.of(context).style;
    return Column(
      crossAxisAlignment: .start,
      spacing: 16,
      children: [topojson, stateFlags]
          .map(
            (credit) => MarkdownBody(
              data: credit,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                a: TextStyle(color: Theme.of(context).colorScheme.primary),
                p: mdTextStyle,
                listBullet: mdTextStyle,
              ),
              onTapLink: (text, href, title) => AvesApp.launchUrl(href),
            ),
          )
          .toList(),
    );
  }
}
