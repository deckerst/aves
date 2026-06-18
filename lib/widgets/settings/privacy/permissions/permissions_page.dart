import 'package:aves/app_flavor.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:aves/widgets/settings/privacy/permissions/manage_media.dart';
import 'package:aves/widgets/settings/privacy/permissions/notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PermissionsPage extends StatelessWidget {
  static const routeName = '/settings/privacy/permissions';

  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canEnableErrorReporting = context.select<AppFlavor, bool>((v) => v.canEnableErrorReporting);
    return AvesScaffold(
      appBar: AppBar(
        title: Text(l10n.settingsPermissionsPageTitle),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SettingsSwitchListTile(
              selector: (context, s) => s.isInstalledAppAccessAllowed,
              onChanged: (v) => settings.isInstalledAppAccessAllowed = v,
              leading: const Icon(AIcons.app),
              title: (context) => context.l10n.settingsAllowInstalledAppAccess,
              subtitle: (context) => context.l10n.settingsAllowInstalledAppAccessSubtitle,
            ),
            if (canEnableErrorReporting)
              SettingsSwitchListTile(
                selector: (context, s) => s.isErrorReportingAllowed,
                onChanged: (v) => settings.isErrorReportingAllowed = v,
                leading: const Icon(AIcons.bugReport),
                title: (context) => context.l10n.settingsAllowErrorReporting,
              ),
            const NotificationPermissionTile(),
            if (!settings.useTvLayout && device.canRequestMediaManagementPermission) const ManageMediaTile(),
          ],
        ),
      ),
    );
  }
}
