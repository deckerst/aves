import 'package:aves/flutter_version.dart';
import 'package:aves/widgets/about/licenses.dart';
import 'package:aves/widgets/common/aves_logo.dart';
import 'package:aves/widgets/common/link_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        child: AnimationLimiter(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      AppReference(),
                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                  ),
                ),
              ),
              Licenses(),
            ],
          ),
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
              padding: const EdgeInsetsDirectional.only(end: 4),
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
