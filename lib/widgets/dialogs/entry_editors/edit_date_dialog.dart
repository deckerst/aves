import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/metadata/date_modifier.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/basic/wheel.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/item_picker.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/item_pick_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditEntryDateDialog extends StatefulWidget {
  static const routeName = '/dialog/edit_entry_date';

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
  late ValueNotifier<int> _shiftHour, _shiftMinute, _shiftSecond;
  late ValueNotifier<String> _shiftSign;
  bool _showOptions = false;
  final Set<MetadataField> _fields = {...DateModifier.writableFields};
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  DateTime get copyItemDate => _copyItemSource.bestDate ?? DateTime.now();

  static const _positiveSign = '+';
  static const _negativeSign = '-';

  @override
  void initState() {
    super.initState();
    _initCustom();
    _initCopyItem();
    _initShift();
    _validate();
  }

  @override
  void dispose() {
    _isValidNotifier.dispose();
    _shiftHour.dispose();
    _shiftMinute.dispose();
    _shiftSecond.dispose();
    _shiftSign.dispose();
    super.dispose();
  }

  void _initCustom() {
    _customDateTime = widget.entry.bestDate ?? DateTime.now();
  }

  void _initCopyItem() {
    _copyItemSource = widget.entry;
  }

  void _initShift() {
    _shiftHour = ValueNotifier(1);
    _shiftMinute = ValueNotifier(0);
    _shiftSecond = ValueNotifier(0);
    _shiftSign = ValueNotifier(_positiveSign);
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
                  onChanged: (v) {
                    _action = v!;
                    _validate();
                    setState(() {});
                  },
                  isExpanded: true,
                  dropdownColor: Themes.thirdLayerColor(context),
                ),
              ),
              AnimatedSwitcher(
                duration: context.read<DurationsData>().formTransition,
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: AvesTransitions.formTransitionBuilder,
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
              const CancelButton(),
              ValueListenableBuilder<bool>(
                valueListenable: _isValidNotifier,
                builder: (context, isValid, child) {
                  return TextButton(
                    onPressed: isValid ? () => _submit(context) : null,
                    child: Text(l10n.applyButtonLabel),
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSetCustomContent(BuildContext context) {
    final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      child: Row(
        children: [
          Expanded(child: Text(formatDateTime(_customDateTime, context.locale, use24hour))),
          IconButton(
            icon: const Icon(AIcons.edit),
            onPressed: _editDate,
            tooltip: context.l10n.changeTooltip,
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
    final use24hour = MediaQuery.alwaysUse24HourFormatOf(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      child: Row(
        children: [
          Expanded(child: Text(formatDateTime(copyItemDate, context.locale, use24hour))),
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

  Widget _buildDestinationFields(BuildContext context) {
    return Padding(
      // small padding as a workaround to show dialog action divider
      padding: const EdgeInsets.only(bottom: 1),
      child: ExpansionPanelList(
        expansionCallback: (index, isExpanded) {
          setState(() => _showOptions = isExpanded);
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
                        onChanged: (selected) {
                          selected ? _fields.add(field) : _fields.remove(field);
                          _validate();
                          setState(() {});
                        },
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
      cancelText: Themes.asButtonLabel(context.l10n.cancelTooltip),
      confirmText: context.l10n.nextButtonLabel,
    );
    if (_date == null) return;

    final _time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_customDateTime),
      cancelText: Themes.asButtonLabel(context.l10n.cancelTooltip),
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

  CollectionLens? _createPickCollection() {
    final baseCollection = widget.collection;
    return baseCollection != null
        ? CollectionLens(
            source: baseCollection.source,
            filters: baseCollection.filters,
          )
        : null;
  }

  Future<void> _pickCopyItemSource() async {
    final pickCollection = _createPickCollection();
    if (pickCollection == null) return;

    final entry = await Navigator.maybeOf(context)?.push<AvesEntry>(
      MaterialPageRoute(
        settings: const RouteSettings(name: ItemPickPage.routeName),
        builder: (context) => ItemPickPage(
          collection: pickCollection,
          canRemoveFilters: true,
        ),
        fullscreenDialog: true,
      ),
    );
    pickCollection.dispose();
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
        final shiftTotalSeconds = ((_shiftHour.value * minutesInHour + _shiftMinute.value) * secondsInMinute + _shiftSecond.value) * (_shiftSign.value == _positiveSign ? 1 : -1);
        return DateModifier.shift(_fields, shiftTotalSeconds);
      case DateEditAction.remove:
        return DateModifier.remove(_fields);
    }
  }

  void _validate() {
    switch (_action) {
      case DateEditAction.setCustom:
      case DateEditAction.copyField:
      case DateEditAction.copyItem:
      case DateEditAction.extractFromTitle:
        _isValidNotifier.value = true;
      case DateEditAction.shift:
      case DateEditAction.remove:
        _isValidNotifier.value = _fields.isNotEmpty;
    }
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop(_getModifier());
    }
  }
}
