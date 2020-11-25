import 'package:aves/flutter_version.dart';
import 'package:aves/widgets/about/licenses.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

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
                    SizedBox(height: 16),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 48),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                'Credits',
                                style: Theme.of(context).textTheme.headline6.copyWith(fontFamily: 'Concourse Caps'),
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: 'This app uses the font '),
                                WidgetSpan(
                                  child: LinkChip(
                                    text: 'Concourse',
                                    url: 'https://mbtype.com/fonts/concourse/',
                                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                                TextSpan(text: ' for titles and the media information page.'),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
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

class AppReference extends StatefulWidget {
  @override
  _AppReferenceState createState() => _AppReferenceState();
}

class _AppReferenceState extends State<AppReference> {
  Future<PackageInfo> packageInfoLoader;

  @override
  void initState() {
    super.initState();
    packageInfoLoader = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildAvesLine(),
          _buildFlutterLine(),
        ],
      ),
    );
  }

  Widget _buildAvesLine() {
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.headline6.copyWith(fontWeight: FontWeight.bold);

    return FutureBuilder<PackageInfo>(
      future: packageInfoLoader,
      builder: (context, snapshot) {
        return LinkChip(
          leading: AvesLogo(
            size: style.fontSize * 1.25,
          ),
          text: 'Aves ${snapshot.data?.version}',
          url: 'https://github.com/deckerst/aves',
          textStyle: style,
        );
      },
    );
  }

  Widget _buildFlutterLine() {
    final style = DefaultTextStyle.of(context).style;
    final subColor = style.color.withOpacity(.6);

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 4),
              child: FlutterLogo(
                size: style.fontSize * 1.25,
              ),
            ),
          ),
          TextSpan(text: 'Flutter ${version['frameworkVersion']}'),
        ],
      ),
      style: TextStyle(color: subColor),
    );
  }
}
