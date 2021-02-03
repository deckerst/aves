import 'package:aves/flutter_version.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AppReference extends StatefulWidget {
  @override
  _AppReferenceState createState() => _AppReferenceState();
}

class _AppReferenceState extends State<AppReference> {
  Future<PackageInfo> _packageInfoLoader;

  @override
  void initState() {
    super.initState();
    _packageInfoLoader = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildAvesLine(),
          _buildFlutterLine(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAvesLine() {
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.headline6.copyWith(fontWeight: FontWeight.bold);

    return FutureBuilder<PackageInfo>(
      future: _packageInfoLoader,
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
