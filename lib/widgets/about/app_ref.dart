import 'package:aves/model/device.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/about/policy_page.dart';
import 'package:aves/widgets/common/basic/link_chip.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:flutter/material.dart';

class AppReference extends StatelessWidget {
  static const avesGithub = 'https://github.com/deckerst/aves';

  const AppReference({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildAvesLine(context),
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

  Widget _buildAvesLine(BuildContext context) {
    final locale = context.locale;
    final textScaler = MediaQuery.textScalerOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvesLogo(
          size: textScaler.scale(_getAppTitleStyle(locale).fontSize!) * 1.3,
        ),
        const SizedBox(width: 8),
        Text(
          context.l10n.appName,
          style: _getAppTitleStyle(locale),
        ),
        const SizedBox(width: 8),
        Text(
          device.packageVersion,
          style: _getAppTitleStyle(locale),
        ),
      ],
    );
  }

  TextStyle _getAppTitleStyle(String locale) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        letterSpacing: canHaveLetterSpacing(locale) ? 1 : 0,
        fontFeatures: const [FontFeature.enable('smcp')],
      );

  static List<Widget> buildLinks(BuildContext context) {
    final l10n = context.l10n;
    return [
      LinkChip(
        leading: Icon(
          AIcons.github,
          size: 24,
        ),
        text: 'GitHub',
        urlString: AppReference.avesGithub,
      ),
      LinkChip(
        leading: Icon(
          AIcons.legal,
          size: 22,
        ),
        text: l10n.aboutLinkLicense,
        urlString: '${AppReference.avesGithub}/blob/main/LICENSE',
      ),
      LinkChip(
        leading: Icon(
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
