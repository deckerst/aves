import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/metadata/enums/date_edit_action.dart';
import 'package:aves/model/metadata/enums/date_field_source.dart';
import 'package:aves/model/metadata/enums/enums.dart';
import 'package:aves/model/metadata/fields.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/basic/wheel.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/item_pick_dialog.dart';
import 'package:aves/widgets/dialogs/item_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditEntryDateDialog extends StatefulWidget {
  final AvesEntry entry;
  final CollectionLens? collection;

  const EditEntryDateDialog({
    super.key,
    required this.entry,
    this.collection,
  });

  @override
  State<EditEntryDateDialog> createState() => _EditEntryDateDialogState();
}

class _EditEntryDateDialogState extends State<EditEntryDateDialog> {
  DateEditAction _action = DateEditAction.setCustom;
  DateFieldSource _copyFieldSource = DateFieldSource.fileModifiedDate;
  late AvesEntry _copyItemSource;
  late DateTime _customDateTime;
  late ValueNotifier<int> _shiftHour, _shiftMinute;
  late ValueNotifier<String> _shiftSign;
  bool _showOptions = false;
  final Set<MetadataField> _fields = {...DateModifier.writableFields};

  DateTime get copyItemDate => _copyItemSource.bestDate ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _initCustom();
    _initCopyItem();
    _initShift(minutesInHour);
  }

  void _initCustom() {
    _customDateTime = widget.entry.bestDate ?? DateTime.now();
  }

  void _initCopyItem() {
    _copyItemSource = widget.entry;
  }

  void _initShift(int initialMinutes) {
    final abs = initialMinutes.abs();
    _shiftHour = ValueNotifier(abs ~/ minutesInHour);
    _shiftMinute = ValueNotifier(abs % minutesInHour);
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
                child: TextDropdownButton<DateEditAction>(
                  values: DateEditAction.values,
                  valueText: (v) => v.getText(context),
                  value: _action,
                  onChanged: (v) => setState(() => _action = v!),
                  isExpanded: true,
                  dropdownColor: Themes.thirdLayerColor(context),
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
                    if (_action == DateEditAction.copyItem) _buildCopyItemContent(context),
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
          Expanded(child: Text(formatDateTime(_customDateTime, locale, use24hour))),
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
      child: TextDropdownButton<DateFieldSource>(
        values: DateFieldSource.values,
        valueText: (v) => v.getText(context),
        value: _copyFieldSource,
        onChanged: (v) => setState(() => _copyFieldSource = v!),
        isExpanded: true,
        dropdownColor: Themes.thirdLayerColor(context),
      ),
    );
  }

  Widget _buildCopyItemContent(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      child: Row(
        children: [
          Expanded(child: Text(formatDateTime(copyItemDate, locale, use24hour))),
          const SizedBox(width: 8),
          ItemPicker(
            extent: 48,
            entry: _copyItemSource,
            onTap: _pickCopyItemSource,
          ),
        ],
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
              Center(child: Text(context.l10n.durationDialogHours)),
              const SizedBox(width: 16),
              Center(child: Text(context.l10n.durationDialogMinutes)),
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
                  values: List.generate(hoursInDay, (i) => i),
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
                  values: List.generate(minutesInHour, (i) => i),
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
              title: Text(context.l10n.editEntryDialogTargetFieldsHeader),
            ),
            body: Column(
              children: DateModifier.writableFields
                  .map((field) => SwitchListTile(
                        value: _fields.contains(field),
                        onChanged: (selected) => setState(() => selected ? _fields.add(field) : _fields.remove(field)),
                        title: Text(field.title),
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

  Future<void> _editDate() async {
    final _date = await showDatePicker(
      context: context,
      initialDate: _customDateTime,
      firstDate: DateTime(0),
      lastDate: DateTime(2100),
      confirmText: context.l10n.nextButtonLabel,
    );
    if (_date == null) return;

    final _time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_customDateTime),
    );
    if (_time == null) return;

    setState(() => _customDateTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ));
  }

  Future<void> _pickCopyItemSource() async {
    final _collection = widget.collection;
    if (_collection == null) return;

    final entry = await Navigator.push<AvesEntry>(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: ItemPickDialog.routeName),
        builder: (context) => ItemPickDialog(
          collection: CollectionLens(
            source: _collection.source,
          ),
        ),
        fullscreenDialog: true,
      ),
    );
    if (entry != null) {
      setState(() => _copyItemSource = entry);
    }
  }

  DateModifier _getModifier() {
    // fields to modify are only set for the `shift` and `remove` actions,
    // as the effective fields for the other actions will depend on
    // whether each item supports Exif edition
    switch (_action) {
      case DateEditAction.setCustom:
        return DateModifier.setCustom(const {}, _customDateTime);
      case DateEditAction.copyField:
        return DateModifier.copyField(_copyFieldSource);
      case DateEditAction.copyItem:
        return DateModifier.setCustom(const {}, copyItemDate);
      case DateEditAction.extractFromTitle:
        return DateModifier.extractFromTitle();
      case DateEditAction.shift:
        final shiftTotalMinutes = (_shiftHour.value * minutesInHour + _shiftMinute.value) * (_shiftSign.value == '+' ? 1 : -1);
        return DateModifier.shift(_fields, shiftTotalMinutes);
      case DateEditAction.remove:
        return DateModifier.remove(_fields);
    }
  }

  void _submit(BuildContext context) => Navigator.pop(context, _getModifier());
}
