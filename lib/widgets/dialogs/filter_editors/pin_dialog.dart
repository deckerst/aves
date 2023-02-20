import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

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
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _confirming = false;
  String? _firstPin;

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
          Text(_confirming ? context.l10n.pinDialogConfirm : context.l10n.pinDialogEnter),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Pinput(
              onCompleted: (pin) {
                if (widget.needConfirmation) {
                  if (_confirming) {
                    Navigator.maybeOf(context)?.pop<String>(_firstPin == pin ? pin : null);
                  } else {
                    _firstPin = pin;
                    _controller.clear();
                    setState(() => _confirming = true);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
                  }
                } else {
                  Navigator.maybeOf(context)?.pop<String>(pin);
                }
              },
              controller: _controller,
              focusNode: _focusNode,
              obscureText: true,
            ),
          ),
        ],
      ),
    );
  }
}
