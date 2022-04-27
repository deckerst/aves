import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/settings/common/tiles.dart';
import 'package:flutter/material.dart';

class ConfirmationDialogPage extends StatelessWidget {
  static const routeName = '/settings/navigation_confirmation';

  const ConfirmationDialogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsConfirmationDialogTitle),
      ),
      body: SafeArea(
        child: ListView(children: [
          SettingsSwitchListTile(
            selector: (context, s) => s.confirmMoveUndatedItems,
            onChanged: (v) => settings.confirmMoveUndatedItems = v,
            title: context.l10n.settingsConfirmationDialogMoveUndatedItems,
          ),
          SettingsSwitchListTile(
            selector: (context, s) => s.confirmMoveToBin,
            onChanged: (v) => settings.confirmMoveToBin = v,
            title: context.l10n.settingsConfirmationDialogMoveToBinItems,
          ),
          SettingsSwitchListTile(
            selector: (context, s) => s.confirmDeleteForever,
            onChanged: (v) => settings.confirmDeleteForever = v,
            title: context.l10n.settingsConfirmationDialogDeleteItems,
          ),
        ]),
      ),
    );
  }
}
