import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

abstract class ConfirmationDialogDelegate {
  List<Widget> build(BuildContext context);

  void apply() {}
}

class MessageConfirmationDialogDelegate extends ConfirmationDialogDelegate {
  final String message;

  MessageConfirmationDialogDelegate(this.message);

  @override
  List<Widget> build(BuildContext context) => [
        Padding(
          padding: const EdgeInsets.all(16) + const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
      ];
}

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required ConfirmationDialog type,
  String? message,
  ConfirmationDialogDelegate? delegate,
  required String confirmationButtonLabel,
}) async {
  if (!_shouldConfirm(type)) return true;

  assert((message != null) ^ (delegate != null));
  final effectiveDelegate = delegate ?? MessageConfirmationDialogDelegate(message!);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => _AvesConfirmationDialog(
      type: type,
      delegate: effectiveDelegate,
      confirmationButtonLabel: confirmationButtonLabel,
    ),
  );
  if (confirmed == null) return false;

  if (confirmed) {
    effectiveDelegate.apply();
  }
  return confirmed;
}

bool _shouldConfirm(ConfirmationDialog type) {
  switch (type) {
    case ConfirmationDialog.deleteForever:
      return settings.confirmDeleteForever;
    case ConfirmationDialog.moveToBin:
      return settings.confirmMoveToBin;
    case ConfirmationDialog.moveUndatedItems:
      return settings.confirmMoveUndatedItems;
  }
}

void _skipConfirmation(ConfirmationDialog type) {
  switch (type) {
    case ConfirmationDialog.deleteForever:
      settings.confirmDeleteForever = false;
      break;
    case ConfirmationDialog.moveToBin:
      settings.confirmMoveToBin = false;
      break;
    case ConfirmationDialog.moveUndatedItems:
      settings.confirmMoveUndatedItems = false;
      break;
  }
}

class _AvesConfirmationDialog extends StatefulWidget {
  final ConfirmationDialog type;
  final ConfirmationDialogDelegate delegate;
  final String confirmationButtonLabel;

  const _AvesConfirmationDialog({
    super.key,
    required this.type,
    required this.delegate,
    required this.confirmationButtonLabel,
  });

  @override
  State<_AvesConfirmationDialog> createState() => _AvesConfirmationDialogState();
}

class _AvesConfirmationDialogState extends State<_AvesConfirmationDialog> {
  final ValueNotifier<bool> _skip = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      scrollableContent: [
        ...widget.delegate.build(context),
        ValueListenableBuilder<bool>(
          valueListenable: _skip,
          builder: (context, flag, child) => SwitchListTile(
            value: flag,
            onChanged: (v) => _skip.value = v,
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
            if (_skip.value) {
              _skipConfirmation(widget.type);
            }
            Navigator.pop(context, true);
          },
          child: Text(widget.confirmationButtonLabel),
        ),
      ],
    );
  }
}
