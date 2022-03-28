import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/about/bug_report.dart';
import 'package:aves/widgets/about/credits.dart';
import 'package:aves/widgets/about/licenses.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  static const routeName = '/about';

  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.aboutPageTitle),
        ),
        body: GestureAreaProtectorStack(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      const [
                        AppReference(),
                        Divider(),
                        BugReport(),
                        Divider(),
                        AboutCredits(),
                        Divider(),
                      ],
                    ),
                  ),
                ),
                const Licenses(),
                const BottomPaddingSliver(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
