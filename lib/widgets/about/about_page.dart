import 'package:aves/model/device.dart';
import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/about/bug_report.dart';
import 'package:aves/widgets/about/credits.dart';
import 'package:aves/widgets/about/licenses.dart';
import 'package:aves/widgets/about/translators.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/tv_pop.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/navigation/tv_rail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatelessWidget {
  static const routeName = '/about';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appBarTitle = Text(context.l10n.aboutPageTitle);
    final body = CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                const AppReference(),
                if (!device.isTelevision) ...[
                  const Divider(),
                  const BugReport(),
                ],
                const Divider(),
                const AboutCredits(),
                const Divider(),
                const AboutTranslators(),
                const Divider(),
              ],
            ),
          ),
        ),
        const Licenses(),
        const BottomPaddingSliver(),
      ],
    );

    if (device.isTelevision) {
      return Scaffold(
        body: TvPopScope(
          child: Row(
            children: [
              TvRail(
                controller: context.read<TvRailController>(),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: appBarTitle,
        ),
        body: GestureAreaProtectorStack(
          child: SafeArea(
            bottom: false,
            child: body,
          ),
        ),
      );
    }
  }
}
