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
  final _controller = TextEditingController();
  bool _confirming = false;
  String? _firstPin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AvesDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_confirming ? context.l10n.pinDialogConfirm : context.l10n.pinDialogEnter),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: PinCodeTextField(
              appContext: context,
              length: 4,
              controller: _controller,
              obscureText: true,
              onChanged: (v) {},
              onCompleted: _submit,
              animationType: AnimationType.scale,
              keyboardType: TextInputType.number,
              autoFocus: true,
              autoDismissKeyboard: !widget.needConfirmation || _confirming,
              pinTheme: PinTheme(
                activeColor: colorScheme.onBackground,
                inactiveColor: colorScheme.onBackground,
                selectedColor: colorScheme.secondary,
                selectedFillColor: colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
                shape: PinCodeFieldShape.box,
              ),
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
        _firstPin = pin;
        _controller.clear();
        setState(() => _confirming = true);
      }
    } else {
      Navigator.maybeOf(context)?.pop<String>(pin);
    }
  }
}
