import 'package:aves/model/device.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionTile extends StatefulWidget {
  const NotificationPermissionTile({super.key});

  @override
  State<NotificationPermissionTile> createState() => _NotificationPermissionTileState();
}

class _NotificationPermissionTileState extends State<NotificationPermissionTile> with WidgetsBindingObserver {
  late Future<PermissionStatus> _loader;

  @override
  void initState() {
    super.initState();
    _initLoader();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initLoader() => _loader = Permission.notification.status;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initLoader();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: _loader,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final status = snapshot.data ?? PermissionStatus.permanentlyDenied;

        final onChanged = loading
            ? null
            : (v) async {
                if (v && status != PermissionStatus.permanentlyDenied && device.canRequestNotificationPermission) {
                  await Permission.notification.request();
                } else {
                  await openAppSettings();
                }
                _initLoader();
                setState(() {});
              };
        final enabled = status == PermissionStatus.granted && onChanged != null;
        final leading = AnimatedOpacity(
          opacity: enabled ? 1 : SettingsSwitchListTile.disabledOpacity,
          duration: ADurations.toggleableTransitionLoose,
          child: const Icon(AIcons.notifications),
        );

        return SwitchListTile(
          value: enabled,
          onChanged: onChanged,
          title: Text(context.l10n.settingsAllowNotifications),
          secondary: leading,
        );
      },
    );
  }
}
