import 'package:aves/widgets/about/app_ref.dart';
import 'package:aves/widgets/about/credits.dart';
import 'package:aves/widgets/about/licenses.dart';
import 'package:aves/widgets/about/new_version.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  static const routeName = '/about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(top: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    AppReference(),
                    Divider(),
                    AboutNewVersion(),
                    AboutCredits(),
                    Divider(),
                  ],
                ),
              ),
            ),
            Licenses(),
          ],
        ),
      ),
    );
  }
}
