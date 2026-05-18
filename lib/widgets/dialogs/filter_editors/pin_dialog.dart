import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinDialog extends StatefulWidget {
  static const routeName = '/dialog/pin';

  final bool needConfirmation;

  const PinDialog({
    super.key,
    required this.needConfirmation,
  });

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _controller = PinInputController();
  bool _confirming = false;
  String? _firstPin;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      content: Column(
        mainAxisSize: .min,
        children: [
          Text(_confirming ? context.l10n.pinDialogConfirm : context.l10n.pinDialogEnter),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: MaterialPinField(
              length: 4,
              pinController: _controller,
              keyboardType: TextInputType.number,
              autoFocus: true,
              autoDismissKeyboard: !widget.needConfirmation || _confirming,
              obscureText: true,
              onChanged: (v) {},
              onCompleted: _submit,
            ),
          ),
        ],
      ),
    );
  }

  void _submit(String pin) {
    if (widget.needConfirmation) {
      if (_confirming) {
        final match = _firstPin == pin;
        Navigator.maybeOf(context)?.pop<String>(match ? pin : null);
        if (!match) {
          showWarningDialog(
            context: context,
            message: context.l10n.genericFailureFeedback,
          );
        }
      } else {
        _firstPin = pin;
        _controller.clear();
        setState(() => _confirming = true);
      }
    } else {
      Navigator.maybeOf(context)?.pop<String>(pin);
    }
  }
}
