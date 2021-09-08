import 'dart:ui';

import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppReference extends StatefulWidget {
  const AppReference({Key? key}) : super(key: key);

  @override
  _AppReferenceState createState() => _AppReferenceState();
}

class _AppReferenceState extends State<AppReference> {
  late Future<PackageInfo> _packageInfoLoader;

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
          const SizedBox(height: 16),
          _buildLinks(),
        ],
      ),
    );
  }

  Widget _buildAvesLine() {
    const style = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.0,
      fontFeatures: [FontFeature.enable('smcp')],
    );

    return FutureBuilder<PackageInfo>(
      future: _packageInfoLoader,
      builder: (context, snapshot) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvesLogo(
              size: style.fontSize! * MediaQuery.textScaleFactorOf(context) * 1.25,
            ),
            const SizedBox(width: 8),
            Text(
              '${context.l10n.appName} ${snapshot.data?.version}',
              style: style,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLinks() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      children: [
        LinkChip(
          leading: const Icon(
            AIcons.github,
            size: 24,
          ),
          text: context.l10n.aboutLinkSources,
          url: Constants.avesGithub,
        ),
        LinkChip(
          leading: const Icon(
            AIcons.legal,
            size: 22,
          ),
          text: context.l10n.aboutLinkLicense,
          url: '${Constants.avesGithub}/blob/main/LICENSE',
        ),
      ],
    );
  }
}
