import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'aves_dialog.dart';

class EditEntryDateDialog extends StatefulWidget {
  final AvesEntry entry;

  const EditEntryDateDialog({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  _EditEntryDateDialogState createState() => _EditEntryDateDialogState();
}

class _EditEntryDateDialogState extends State<EditEntryDateDialog> {
  DateEditAction _action = DateEditAction.set;
  late Set<MetadataField> _fields;
  late DateTime _dateTime;
  int _shiftMinutes = 60;
  bool _showOptions = false;

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _fields = {
      MetadataField.exifDate,
      MetadataField.exifDateDigitized,
      MetadataField.exifDateOriginal,
    };
    _dateTime = entry.bestDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Builder(
        builder: (context) {
          final l10n = context.l10n;
          final locale = l10n.localeName;
          final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);

          void _updateAction(DateEditAction? action) {
            if (action == null) return;
            setState(() => _action = action);
          }

          Widget _tileText(String text) => Text(
                text,
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
              );

          final setTile = Row(
            children: [
              Expanded(
                child: RadioListTile<DateEditAction>(
                  value: DateEditAction.set,
                  groupValue: _action,
                  onChanged: _updateAction,
                  title: _tileText(l10n.editEntryDateDialogSet),
                  subtitle: Text(formatDateTime(_dateTime, locale, use24hour)),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: IconButton(
                  icon: const Icon(AIcons.edit),
                  onPressed: _action == DateEditAction.set ? _editDate : null,
                  tooltip: l10n.changeTooltip,
                ),
              ),
            ],
          );
          final shiftTile = Row(
            children: [
              Expanded(
                child: RadioListTile<DateEditAction>(
                  value: DateEditAction.shift,
                  groupValue: _action,
                  onChanged: _updateAction,
                  title: _tileText(l10n.editEntryDateDialogShift),
                  subtitle: Text(_formatShiftDuration()),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: IconButton(
                  icon: const Icon(AIcons.edit),
                  onPressed: _action == DateEditAction.shift ? _editShift : null,
                  tooltip: l10n.changeTooltip,
                ),
              ),
            ],
          );
          final clearTile = RadioListTile<DateEditAction>(
            value: DateEditAction.clear,
            groupValue: _action,
            onChanged: _updateAction,
            title: _tileText(l10n.editEntryDateDialogClear),
          );

          final animationDuration = context.select<DurationsData, Duration>((v) => v.expansionTileAnimation);
          final theme = Theme.of(context);
          return Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.copyWith(
                // dense style font for tile subtitles, without modifying title font
                bodyText2: const TextStyle(fontSize: 12),
              ),
            ),
            child: AvesDialog(
              context: context,
              title: l10n.editEntryDateDialogTitle,
              scrollableContent: [
                setTile,
                shiftTile,
                clearTile,
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: ExpansionPanelList(
                    expansionCallback: (index, isExpanded) {
                      setState(() => _showOptions = !isExpanded);
                    },
                    animationDuration: animationDuration,
                    expandedHeaderPadding: EdgeInsets.zero,
                    elevation: 0,
                    children: [
                      ExpansionPanel(
                        headerBuilder: (context, isExpanded) => ListTile(
                          title: Text(l10n.editEntryDateDialogFieldSelection),
                        ),
                        body: Column(
                          children: DateModifier.allDateFields
                              .map((field) => SwitchListTile(
                                    value: _fields.contains(field),
                                    onChanged: (selected) => setState(() => selected ? _fields.add(field) : _fields.remove(field)),
                                    title: Text(_fieldTitle(field)),
                                  ))
                              .toList(),
                        ),
                        isExpanded: _showOptions,
                        canTapOnHeader: true,
                        backgroundColor: Theme.of(context).dialogBackgroundColor,
                      ),
                    ],
                  ),
                ),
              ],
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                TextButton(
                  onPressed: () => _submit(context),
                  child: Text(l10n.applyButtonLabel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatShiftDuration() {
    final abs = _shiftMinutes.abs();
    final h = abs ~/ 60;
    final m = abs % 60;
    return '${_shiftMinutes.isNegative ? '-' : '+'}$h:${m.toString().padLeft(2, '0')}';
  }

  String _fieldTitle(MetadataField field) {
    switch (field) {
      case MetadataField.exifDate:
        return 'Exif date';
      case MetadataField.exifDateOriginal:
        return 'Exif original date';
      case MetadataField.exifDateDigitized:
        return 'Exif digitized date';
      case MetadataField.exifGpsDate:
        return 'Exif GPS date';
    }
  }

  Future<void> _editDate() async {
    final _date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(0),
      lastDate: DateTime.now(),
      confirmText: context.l10n.nextButtonLabel,
    );
    if (_date == null) return;

    final _time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (_time == null) return;

    setState(() => _dateTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ));
  }

  void _editShift() async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => TimeShiftDialog(
        initialShiftMinutes: _shiftMinutes,
      ),
    );
    if (picked == null) return;

    setState(() => _shiftMinutes = picked);
  }

  void _submit(BuildContext context) {
    late DateModifier modifier;
    switch (_action) {
      case DateEditAction.set:
        modifier = DateModifier(_action, _fields, dateTime: _dateTime);
        break;
      case DateEditAction.shift:
        modifier = DateModifier(_action, _fields, shiftMinutes: _shiftMinutes);
        break;
      case DateEditAction.clear:
        modifier = DateModifier(_action, _fields);
        break;
    }
    Navigator.pop(context, modifier);
  }
}

class TimeShiftDialog extends StatefulWidget {
  final int initialShiftMinutes;

  const TimeShiftDialog({
    Key? key,
    required this.initialShiftMinutes,
  }) : super(key: key);

  @override
  _TimeShiftDialogState createState() => _TimeShiftDialogState();
}

class _TimeShiftDialogState extends State<TimeShiftDialog> {
  late ValueNotifier<int> _hour, _minute;
  late ValueNotifier<String> _sign;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialShiftMinutes;
    final abs = initial.abs();
    _hour = ValueNotifier(abs ~/ 60);
    _minute = ValueNotifier(abs % 60);
    _sign = ValueNotifier(initial.isNegative ? '-' : '+');
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 34);
    return AvesDialog(
      context: context,
      scrollableContent: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Table(
              children: [
                TableRow(
                  children: [
                    const SizedBox(),
                    Center(child: Text(context.l10n.editEntryDateDialogHours)),
                    const SizedBox(),
                    Center(child: Text(context.l10n.editEntryDateDialogMinutes)),
                  ],
                ),
                TableRow(
                  children: [
                    _Wheel(
                      valueNotifier: _sign,
                      values: const ['+', '-'],
                      textStyle: textStyle,
                      textAlign: TextAlign.center,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _Wheel(
                        valueNotifier: _hour,
                        values: List.generate(24, (i) => i),
                        textStyle: textStyle,
                        textAlign: TextAlign.end,
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
                      child: _Wheel(
                        valueNotifier: _minute,
                        values: List.generate(60, (i) => i),
                        textStyle: textStyle,
                        textAlign: TextAlign.end,
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
      hasScrollBar: false,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, (_hour.value * 60 + _minute.value) * (_sign.value == '+' ? 1 : -1)),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

class _Wheel<T> extends StatefulWidget {
  final ValueNotifier<T> valueNotifier;
  final List<T> values;
  final TextStyle textStyle;
  final TextAlign textAlign;

  const _Wheel({
    Key? key,
    required this.valueNotifier,
    required this.values,
    required this.textStyle,
    required this.textAlign,
  }) : super(key: key);

  @override
  _WheelState createState() => _WheelState<T>();
}

class _WheelState<T> extends State<_Wheel<T>> {
  late final ScrollController _controller;

  static const itemSize = Size(40, 40);

  ValueNotifier<T> get valueNotifier => widget.valueNotifier;

  List<T> get values => widget.values;

  @override
  void initState() {
    super.initState();
    var indexOf = values.indexOf(valueNotifier.value);
    _controller = FixedExtentScrollController(
      initialItem: indexOf,
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).dialogBackgroundColor;
    final foreground = DefaultTextStyle.of(context).style.color!;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: itemSize.width,
        height: itemSize.height * 3,
        child: ShaderMask(
          shaderCallback: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              background,
              foreground,
              foreground,
              background,
            ],
          ).createShader,
          child: ListWheelScrollView(
            controller: _controller,
            physics: const FixedExtentScrollPhysics(parent: BouncingScrollPhysics()),
            diameterRatio: 1.2,
            itemExtent: itemSize.height,
            squeeze: 1.3,
            onSelectedItemChanged: (i) => valueNotifier.value = values[i],
            children: values
                .map((i) => SizedBox.fromSize(
                      size: itemSize,
                      child: Text(
                        '$i',
                        textAlign: widget.textAlign,
                        style: widget.textStyle,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
