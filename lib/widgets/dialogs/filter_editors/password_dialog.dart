import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class PasswordDialog extends StatefulWidget {
  static const routeName = '/dialog/password';

  final bool needConfirmation;

  const PasswordDialog({
    super.key,
    required this.needConfirmation,
  });

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _confirming = false;
  String? _firstPassword;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_confirming ? context.l10n.passwordDialogConfirm : context.l10n.passwordDialogEnter),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              obscureText: true,
              onSubmitted: (password) {
                if (widget.needConfirmation) {
                  if (_confirming) {
                    final match = _firstPassword == password;
                    Navigator.maybeOf(context)?.pop<String>(match ? password : null);
                    if (!match) {
                      showDialog(
                        context: context,
                        builder: (context) => AvesDialog(
                          content: Text(context.l10n.genericFailureFeedback),
                          actions: const [OkButton()],
                        ),
                        routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
                      );
                    }
                  } else {
                    _firstPassword = password;
                    _controller.clear();
                    setState(() => _confirming = true);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
                  }
                } else {
                  Navigator.maybeOf(context)?.pop<String>(password);
                }
              },
              autofillHints: const [AutofillHints.password],
            ),
          ),
        ],
      ),
    );
  }
}
