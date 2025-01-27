import 'package:aves/widgets/common/basic/time_shift_selector.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

import 'aves_dialog.dart';

class TimeShiftDialog extends StatefulWidget {
  static const routeName = '/dialog/time_shift';

  final Duration initialValue;

  const TimeShiftDialog({
    super.key,
    required this.initialValue,
  });

  @override
  State<TimeShiftDialog> createState() => _TimeShiftDialogState();
}

class _TimeShiftDialogState extends State<TimeShiftDialog> {
  late TimeShiftController _timeShiftController;

  @override
  void initState() {
    super.initState();
    _timeShiftController = TimeShiftController(
      initialValue: widget.initialValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      scrollableContent: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: TimeShiftSelector(controller: _timeShiftController),
        ),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () => _submit(context),
          child: Text(context.l10n.applyButtonLabel),
        ),
      ],
    );
  }

  void _submit(BuildContext context) => Navigator.maybeOf(context)?.pop(_timeShiftController.value);
}
