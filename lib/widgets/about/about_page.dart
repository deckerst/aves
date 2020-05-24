import 'package:aves/widgets/about/licenses.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Made with ❤️ and '),
                            WidgetSpan(
                              child: FlutterLogo(
                                size: Theme.of(context).textTheme.bodyText2.fontSize * 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
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
