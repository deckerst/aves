import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';

class ManageMediaTile extends StatefulWidget {
  const ManageMediaTile({super.key});

  @override
  State<ManageMediaTile> createState() => _ManageMediaTileState();
}

class _ManageMediaTileState extends State<ManageMediaTile> with WidgetsBindingObserver {
  late Future<bool> _loader;

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

  void _initLoader() => _loader = deviceService.canManageMedia();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initLoader();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loader,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final current = snapshot.data ?? false;

        final onChanged = loading ? null : (v) => deviceService.requestMediaManagePermission();
        final leading = AnimatedOpacity(
          opacity: current && onChanged != null ? 1 : SettingsSwitchListTile.disabledOpacity,
          duration: ADurations.toggleableTransitionLoose,
          child: const Icon(AIcons.allCollection),
        );

        return SwitchListTile(
          value: current,
          onChanged: onChanged,
          title: Text(context.l10n.settingsAllowMediaManagement),
          secondary: leading,
        );
      },
    );
  }
}
