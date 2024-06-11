import 'package:aves/ref/locales.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/basic/wheel.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DurationDialog extends StatefulWidget {
  final int initialSeconds;

  const DurationDialog({
    super.key,
    required this.initialSeconds,
  });

  @override
  State<DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<DurationDialog> {
  late ValueNotifier<int> _minutes, _seconds;

  @override
  void initState() {
    super.initState();
    final seconds = widget.initialSeconds;
    _minutes = ValueNotifier(seconds ~/ secondsInMinute);
    _seconds = ValueNotifier(seconds % secondsInMinute);
  }

  @override
  void dispose() {
    _minutes.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Builder(builder: (context) {
        final l10n = context.l10n;
        final timeComponentFormatter = NumberFormat('0', context.locale);

        const textStyle = TextStyle(fontSize: 34);
        const digitsAlign = TextAlign.right;

        return AvesDialog(
          scrollableContent: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Table(
                  textDirection: timeComponentsDirection,
                  children: [
                    TableRow(
                      children: [
                        Center(child: Text(l10n.durationDialogMinutes)),
                        const SizedBox(width: 16),
                        Center(child: Text(l10n.durationDialogSeconds)),
                      ],
                    ),
                    TableRow(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: WheelSelector(
                            valueNotifier: _minutes,
                            values: List.generate(minutesInHour, (i) => i),
                            textStyle: textStyle,
                            textAlign: digitsAlign,
                            format: timeComponentFormatter.format,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            ':',
                            style: textStyle,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: WheelSelector(
                            valueNotifier: _seconds,
                            values: List.generate(secondsInMinute, (i) => i),
                            textStyle: textStyle,
                            textAlign: digitsAlign,
                            format: timeComponentFormatter.format,
                          ),
                        ),
                      ],
                    )
                  ],
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                ),
              ),
            ),
          ],
          actions: [
            const CancelButton(),
            AnimatedBuilder(
              animation: Listenable.merge([_minutes, _seconds]),
              builder: (context, child) {
                final isValid = _minutes.value > 0 || _seconds.value > 0;
                return TextButton(
                  onPressed: isValid ? () => _submit(context) : null,
                  child: child!,
                );
              },
              child: Text(l10n.applyButtonLabel),
            ),
          ],
        );
      }),
    );
  }

  void _submit(BuildContext context) => Navigator.maybeOf(context)?.pop(_minutes.value * secondsInMinute + _seconds.value);
}
