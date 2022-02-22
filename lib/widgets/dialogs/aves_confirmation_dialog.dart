import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required ConfirmationDialog type,
  required String message,
  required String confirmationButtonLabel,
}) async {
  if (!settings.confirmationDialogs.contains(type)) return true;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AvesConfirmationDialog(
      type: type,
      message: message,
      confirmationButtonLabel: confirmationButtonLabel,
    ),
  );
  return confirmed == true;
}

class AvesConfirmationDialog extends StatefulWidget {
  final ConfirmationDialog type;
  final String message, confirmationButtonLabel;

  const AvesConfirmationDialog({
    Key? key,
    required this.type,
    required this.message,
    required this.confirmationButtonLabel,
  }) : super(key: key);

  @override
  _AvesConfirmationDialogState createState() => _AvesConfirmationDialogState();
}

class _AvesConfirmationDialogState extends State<AvesConfirmationDialog> {
  final ValueNotifier<bool> _skipConfirmation = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      scrollableContent: [
        Padding(
          padding: const EdgeInsets.all(16) + const EdgeInsets.only(top: 8),
          child: Text(widget.message),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _skipConfirmation,
          builder: (context, ask, child) => SwitchListTile(
            value: ask,
            onChanged: (v) => _skipConfirmation.value = v,
            title: Text(context.l10n.doNotAskAgain),
          ),
        ),
      ],
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            if (_skipConfirmation.value) {
              settings.confirmationDialogs = settings.confirmationDialogs.toList()..remove(widget.type);
            }
            Navigator.pop(context, true);
          },
          child: Text(widget.confirmationButtonLabel),
        ),
      ],
    );
  }
}
