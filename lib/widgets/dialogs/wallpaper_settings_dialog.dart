import 'package:aves/model/device.dart';
import 'package:aves/model/wallpaper_target.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'aves_dialog.dart';

class WallpaperSettingsDialog extends StatefulWidget {
  const WallpaperSettingsDialog({super.key});

  @override
  State<WallpaperSettingsDialog> createState() => _WallpaperSettingsDialogState();
}

class _WallpaperSettingsDialogState extends State<WallpaperSettingsDialog> {
  WallpaperTarget _selectedTarget = WallpaperTarget.home;
  bool _useScrollEffect = true;

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      scrollableContent: [
        if (device.canSetLockScreenWallpaper)
          ...WallpaperTarget.values.map((value) {
            return SelectionRadioListTile(
              value: value,
              title: value.getName(context),
              needConfirmation: true,
              getGroupValue: () => _selectedTarget,
              setGroupValue: (v) => setState(() => _selectedTarget = v),
            );
          }),
        SwitchListTile(
          value: _useScrollEffect,
          onChanged: (v) => setState(() => _useScrollEffect = v),
          title: Text(context.l10n.wallpaperUseScrollEffect),
        )
      ],
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () => Navigator.maybeOf(context)?.pop(Tuple2<WallpaperTarget, bool>(_selectedTarget, _useScrollEffect)),
          child: Text(context.l10n.applyButtonLabel),
        ),
      ],
    );
  }
}
