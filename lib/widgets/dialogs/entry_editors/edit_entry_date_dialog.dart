import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/wheel.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  DateEditAction _action = DateEditAction.setCustom;
  DateFieldSource _copyFieldSource = DateFieldSource.fileModifiedDate;
  late DateTime _setDateTime;
  late ValueNotifier<int> _shiftHour, _shiftMinute;
  late ValueNotifier<String> _shiftSign;
  bool _showOptions = false;
  final Set<MetadataField> _fields = {...DateModifier.writableDateFields};

  // use a different shade to avoid having the same background
  // on the dialog (using the theme `dialogBackgroundColor`)
  // and on the dropdown (using the theme `canvasColor`)
  static final dropdownColor = Colors.grey.shade800;

  @override
  void initState() {
    super.initState();
    _initSet();
    _initShift(60);
  }

  void _initSet() {
    _setDateTime = widget.entry.bestDate ?? DateTime.now();
  }

  void _initShift(int initialMinutes) {
    final abs = initialMinutes.abs();
    _shiftHour = ValueNotifier(abs ~/ 60);
    _shiftMinute = ValueNotifier(abs % 60);
    _shiftSign = ValueNotifier(initialMinutes.isNegative ? '-' : '+');
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: TooltipTheme(
        data: TooltipTheme.of(context).copyWith(
          preferBelow: false,
        ),
        child: Builder(builder: (context) {
          final l10n = context.l10n;

          return AvesDialog(
            title: l10n.editEntryDateDialogTitle,
            scrollableContent: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                child: DropdownButton<DateEditAction>(
                  items: DateEditAction.values
                      .map((v) => DropdownMenuItem<DateEditAction>(
                            value: v,
                            child: Text(_actionText(context, v)),
                          ))
                      .toList(),
                  value: _action,
                  onChanged: (v) => setState(() => _action = v!),
                  isExpanded: true,
                  dropdownColor: dropdownColor,
                ),
              ),
              AnimatedSwitcher(
                duration: context.read<DurationsData>().formTransition,
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: _formTransitionBuilder,
                child: Column(
                  key: ValueKey(_action),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_action == DateEditAction.setCustom) _buildSetCustomContent(context),
                    if (_action == DateEditAction.copyField) _buildCopyFieldContent(context),
                    if (_action == DateEditAction.shift) _buildShiftContent(context),
                    (_action == DateEditAction.shift || _action == DateEditAction.remove) ? _buildDestinationFields(context) : const SizedBox(height: 8),
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
          );
        }),
      ),
    );
  }

  Widget _formTransitionBuilder(Widget child, Animation<double> animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: child,
        ),
      );

  Widget _buildSetCustomContent(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      child: Row(
        children: [
          Expanded(child: Text(formatDateTime(_setDateTime, locale, use24hour))),
          IconButton(
            icon: const Icon(AIcons.edit),
            onPressed: _editDate,
            tooltip: l10n.changeTooltip,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyFieldContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 0, right: 16),
      child: DropdownButton<DateFieldSource>(
        items: DateFieldSource.values
            .map((v) => DropdownMenuItem<DateFieldSource>(
                  value: v,
                  child: Text(_setSourceText(context, v)),
                ))
            .toList(),
        selectedItemBuilder: (context) => DateFieldSource.values
            .map((v) => DropdownMenuItem<DateFieldSource>(
                  value: v,
                  child: Text(
                    _setSourceText(context, v),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ))
            .toList(),
        value: _copyFieldSource,
        onChanged: (v) => setState(() => _copyFieldSource = v!),
        isExpanded: true,
        dropdownColor: dropdownColor,
      ),
    );
  }

  Widget _buildShiftContent(BuildContext context) {
    const textStyle = TextStyle(fontSize: 34);
    return Center(
      child: Table(
        // even when ambient direction is RTL, time is displayed in LTR
        textDirection: TextDirection.ltr,
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
              WheelSelector(
                valueNotifier: _shiftSign,
                values: const ['+', '-'],
                textStyle: textStyle,
                textAlign: TextAlign.center,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: WheelSelector(
                  valueNotifier: _shiftHour,
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
                child: WheelSelector(
                  valueNotifier: _shiftMinute,
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
    );
  }

  Widget _buildDestinationFields(BuildContext context) {
    return Padding(
      // small padding as a workaround to show dialog action divider
      padding: const EdgeInsets.only(bottom: 1),
      child: ExpansionPanelList(
        expansionCallback: (index, isExpanded) {
          setState(() => _showOptions = !isExpanded);
        },
        animationDuration: context.read<DurationsData>().expansionTileAnimation,
        expandedHeaderPadding: EdgeInsets.zero,
        elevation: 0,
        children: [
          ExpansionPanel(
            headerBuilder: (context, isExpanded) => ListTile(
              title: Text(context.l10n.editEntryDateDialogTargetFieldsHeader),
            ),
            body: Column(
              children: DateModifier.writableDateFields
                  .map((field) => SwitchListTile(
                        value: _fields.contains(field),
                        onChanged: (selected) => setState(() => selected ? _fields.add(field) : _fields.remove(field)),
                        title: Text(_fieldTitle(field)),
                      ))
                  .toList(),
            ),
            isExpanded: _showOptions,
            canTapOnHeader: true,
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  String _actionText(BuildContext context, DateEditAction action) {
    final l10n = context.l10n;
    switch (action) {
      case DateEditAction.setCustom:
        return l10n.editEntryDateDialogSetCustom;
      case DateEditAction.copyField:
        return l10n.editEntryDateDialogCopyField;
      case DateEditAction.extractFromTitle:
        return l10n.editEntryDateDialogExtractFromTitle;
      case DateEditAction.shift:
        return l10n.editEntryDateDialogShift;
      case DateEditAction.remove:
        return l10n.actionRemove;
    }
  }

  String _setSourceText(BuildContext context, DateFieldSource source) {
    final l10n = context.l10n;
    switch (source) {
      case DateFieldSource.fileModifiedDate:
        return l10n.editEntryDateDialogSourceFileModifiedDate;
      case DateFieldSource.exifDate:
        return 'Exif date';
      case DateFieldSource.exifDateOriginal:
        return 'Exif original date';
      case DateFieldSource.exifDateDigitized:
        return 'Exif digitized date';
      case DateFieldSource.exifGpsDate:
        return 'Exif GPS date';
    }
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
      case MetadataField.xmpCreateDate:
        return 'XMP xmp:CreateDate';
    }
  }

  Future<void> _editDate() async {
    final _date = await showDatePicker(
      context: context,
      initialDate: _setDateTime,
      firstDate: DateTime(0),
      lastDate: DateTime(2100),
      confirmText: context.l10n.nextButtonLabel,
    );
    if (_date == null) return;

    final _time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_setDateTime),
    );
    if (_time == null) return;

    setState(() => _setDateTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ));
  }

  DateModifier _getModifier() {
    // fields to modify are only set for the `shift` and `remove` actions,
    // as the effective fields for the other actions will depend on
    // whether each item supports Exif edition
    switch (_action) {
      case DateEditAction.setCustom:
        return DateModifier.setCustom(const {}, _setDateTime);
      case DateEditAction.copyField:
        return DateModifier.copyField(const {}, _copyFieldSource);
      case DateEditAction.extractFromTitle:
        return DateModifier.extractFromTitle(const {});
      case DateEditAction.shift:
        final shiftTotalMinutes = (_shiftHour.value * 60 + _shiftMinute.value) * (_shiftSign.value == '+' ? 1 : -1);
        return DateModifier.shift(_fields, shiftTotalMinutes);
      case DateEditAction.remove:
        return DateModifier.remove(_fields);
    }
  }

  void _submit(BuildContext context) => Navigator.pop(context, _getModifier());
}
