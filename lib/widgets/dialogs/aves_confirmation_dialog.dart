import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String message,
  required String confirmationButtonLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AvesDialog(
      content: Text(message),
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () => Navigator.maybeOf(context)?.pop(true),
          child: Text(confirmationButtonLabel),
        ),
      ],
    ),
    routeSettings: const RouteSettings(name: AvesDialog.confirmationRouteName),
  );
  return confirmed ?? false;
}

Future<bool> showSkippableConfirmationDialog({
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
    builder: (context) => _SkippableConfirmationDialog(
      type: type,
      delegate: effectiveDelegate,
      confirmationButtonLabel: confirmationButtonLabel,
    ),
    routeSettings: const RouteSettings(name: _SkippableConfirmationDialog.routeName),
  );
  if (confirmed == null) return false;

  if (confirmed) {
    effectiveDelegate.apply();
  }
  return confirmed;
}

bool _shouldConfirm(ConfirmationDialog type) {
  switch (type) {
    case ConfirmationDialog.createVault:
      return settings.confirmCreateVault;
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
    case ConfirmationDialog.createVault:
      settings.confirmCreateVault = false;
    case ConfirmationDialog.deleteForever:
      settings.confirmDeleteForever = false;
    case ConfirmationDialog.moveToBin:
      settings.confirmMoveToBin = false;
    case ConfirmationDialog.moveUndatedItems:
      settings.confirmMoveUndatedItems = false;
  }
}

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

class _SkippableConfirmationDialog extends StatefulWidget {
  static const routeName = '/dialog/skippable_confirmation';

  final ConfirmationDialog type;
  final ConfirmationDialogDelegate delegate;
  final String confirmationButtonLabel;

  const _SkippableConfirmationDialog({
    required this.type,
    required this.delegate,
    required this.confirmationButtonLabel,
  });

  @override
  State<_SkippableConfirmationDialog> createState() => _SkippableConfirmationDialogState();
}

class _SkippableConfirmationDialogState extends State<_SkippableConfirmationDialog> {
  final ValueNotifier<bool> _skipNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _skipNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      scrollableContent: [
        ...widget.delegate.build(context),
        ValueListenableBuilder<bool>(
          valueListenable: _skipNotifier,
          builder: (context, flag, child) => SwitchListTile(
            value: flag,
            onChanged: (v) => _skipNotifier.value = v,
            title: Text(context.l10n.doNotAskAgain),
          ),
        ),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () {
            if (_skipNotifier.value) {
              _skipConfirmation(widget.type);
            }
            Navigator.maybeOf(context)?.pop(true);
          },
          child: Text(widget.confirmationButtonLabel),
        ),
      ],
    );
  }
}
