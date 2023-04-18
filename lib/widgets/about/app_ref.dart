import 'dart:ui';

import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/about/policy_page.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppReference extends StatefulWidget {
  static const avesGithub = 'https://github.com/deckerst/aves';

  const AppReference({super.key});

  @override
  State<AppReference> createState() => _AppReferenceState();

  static List<Widget> buildLinks(BuildContext context) {
    final l10n = context.l10n;
    return [
      const LinkChip(
        leading: Icon(
          AIcons.github,
          size: 24,
        ),
        text: 'GitHub',
        urlString: AppReference.avesGithub,
      ),
      LinkChip(
        leading: const Icon(
          AIcons.legal,
          size: 22,
        ),
        text: l10n.aboutLinkLicense,
        urlString: '${AppReference.avesGithub}/blob/main/LICENSE',
      ),
      LinkChip(
        leading: const Icon(
          AIcons.privacy,
          size: 22,
        ),
        text: l10n.aboutLinkPolicy,
        onTap: () => _goToPolicyPage(context),
      ),
    ];
  }

  static void _goToPolicyPage(BuildContext context) {
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: PolicyPage.routeName),
        builder: (context) => const PolicyPage(),
      ),
    );
  }
}

class _AppReferenceState extends State<AppReference> {
  late Future<PackageInfo> _packageInfoLoader;

  static const _appTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.0,
    fontFeatures: [FontFeature.enable('smcp')],
  );

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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: AppReference.buildLinks(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAvesLine() {
    return FutureBuilder<PackageInfo>(
      future: _packageInfoLoader,
      builder: (context, snapshot) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvesLogo(
              size: _appTitleStyle.fontSize! * MediaQuery.textScaleFactorOf(context) * 1.3,
            ),
            const SizedBox(width: 8),
            Text(
              '${context.l10n.appName} ${snapshot.data?.version}',
              style: _appTitleStyle,
            ),
          ],
        );
      },
    );
  }
}
