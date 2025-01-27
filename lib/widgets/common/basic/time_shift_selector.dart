import 'package:aves/ref/locales.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/basic/wheel.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeShiftSelector extends StatefulWidget {
  final TimeShiftController controller;

  const TimeShiftSelector({
    super.key,
    required this.controller,
  });

  @override
  State<TimeShiftSelector> createState() => _TimeShiftSelectorState();
}

class _TimeShiftSelectorState extends State<TimeShiftSelector> {
  late ValueNotifier<int> _shiftHour, _shiftMinute, _shiftSecond;
  late ValueNotifier<String> _shiftSign;

  static const _positiveSign = '+';
  static const _negativeSign = '-';

  @override
  void initState() {
    super.initState();

    var initialValue = widget.controller.initialValue;
    final sign = initialValue.isNegative ? _negativeSign : _positiveSign;
    initialValue = initialValue.abs();
    final hours = initialValue.inHours;
    initialValue -= Duration(hours: hours);
    final minutes = initialValue.inMinutes;
    initialValue -= Duration(minutes: minutes);
    final seconds = initialValue.inSeconds;

    _shiftSign = ValueNotifier(sign);
    _shiftHour = ValueNotifier(hours);
    _shiftMinute = ValueNotifier(minutes);
    _shiftSecond = ValueNotifier(seconds);

    _shiftSign.addListener(_updateValue);
    _shiftHour.addListener(_updateValue);
    _shiftMinute.addListener(_updateValue);
    _shiftSecond.addListener(_updateValue);
  }

  @override
  void dispose() {
    _shiftSign.dispose();
    _shiftHour.dispose();
    _shiftMinute.dispose();
    _shiftSecond.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeComponentFormatter = NumberFormat('0', context.locale);

    const textStyle = TextStyle(fontSize: 34);
    const digitsAlign = TextAlign.right;

    return Center(
      child: Table(
        textDirection: timeComponentsDirection,
        children: [
          TableRow(
            children: [
              const SizedBox(),
              Center(child: Text(l10n.durationDialogHours)),
              const SizedBox(width: 16),
              Center(child: Text(l10n.durationDialogMinutes)),
              const SizedBox(width: 16),
              Center(child: Text(l10n.durationDialogSeconds)),
            ],
          ),
          TableRow(
            children: [
              WheelSelector(
                valueNotifier: _shiftSign,
                values: const [_positiveSign, _negativeSign],
                textStyle: textStyle,
                textAlign: TextAlign.center,
                format: (v) => v,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: WheelSelector(
                  valueNotifier: _shiftHour,
                  values: List.generate(hoursInDay, (i) => i),
                  textStyle: textStyle,
                  textAlign: digitsAlign,
                  format: timeComponentFormatter.format,
                ),
              ),
              const Text(
                ':',
                style: textStyle,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: WheelSelector(
                  valueNotifier: _shiftMinute,
                  values: List.generate(minutesInHour, (i) => i),
                  textStyle: textStyle,
                  textAlign: digitsAlign,
                  format: timeComponentFormatter.format,
                ),
              ),
              const Text(
                ':',
                style: textStyle,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: WheelSelector(
                  valueNotifier: _shiftSecond,
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
    );
  }

  void _updateValue() {
    final sign = _shiftSign.value == _positiveSign ? 1 : -1;
    final hours = _shiftHour.value;
    final minutes = _shiftMinute.value;
    final seconds = _shiftSecond.value;
    widget.controller.value = Duration(hours: hours, minutes: minutes, seconds: seconds) * sign;
  }
}

class TimeShiftController {
  final Duration initialValue;
  Duration value;

  TimeShiftController({required this.initialValue}) : value = initialValue;
}
