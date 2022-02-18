import 'package:aves/model/settings/enums/confirmation_dialogs.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmationDialogTile extends StatelessWidget {
  const ConfirmationDialogTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(context.l10n.settingsConfirmationDialogTile),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: ConfirmationDialogPage.routeName),
            builder: (context) => const ConfirmationDialogPage(),
          ),
        );
      },
    );
  }
}

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
        child: Selector<Settings, List<ConfirmationDialog>>(
          selector: (context, s) => s.confirmationDialogs,
          builder: (context, current, child) => ListView(
            children: [
              ConfirmationDialog.moveToBin,
              ConfirmationDialog.delete,
            ]
                .map((dialog) => SwitchListTile(
                      value: current.contains(dialog),
                      onChanged: (v) {
                        final dialogs = current.toList();
                        if (v) {
                          dialogs.add(dialog);
                        } else {
                          dialogs.remove(dialog);
                        }
                        settings.confirmationDialogs = dialogs;
                      },
                      title: Text(dialog.getName(context)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
