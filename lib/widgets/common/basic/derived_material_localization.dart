import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// allow apply custom regional preferences on an existing localization
// until this is fixed: https://github.com/flutter/flutter/issues/122274

class DerivedMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  final Locale locale;
  final MaterialLocalizations localizations;

  const DerivedMaterialLocalizationsDelegate(this.locale, this.localizations);

  @override
  bool isSupported(Locale locale) => locale == this.locale;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return SynchronousFuture<MaterialLocalizations>(localizations);
  }

  @override
  bool shouldReload(DerivedMaterialLocalizationsDelegate old) => true;
}

class DerivedMaterialLocalizations extends MaterialLocalizations {
  final MaterialLocalizations parent;
  final int? _firstDayOfWeekIndex;

  DerivedMaterialLocalizations({
    required this.parent,
    int? firstDayOfWeekIndex,
  }) : _firstDayOfWeekIndex = firstDayOfWeekIndex;

  @override
  String aboutListTileTitle(String applicationName) => parent.aboutListTileTitle(applicationName);

  @override
  String get alertDialogLabel => parent.alertDialogLabel;

  @override
  String get anteMeridiemAbbreviation => parent.anteMeridiemAbbreviation;

  @override
  String get backButtonTooltip => parent.backButtonTooltip;

  @override
  String get bottomSheetLabel => parent.bottomSheetLabel;

  @override
  String get calendarModeButtonLabel => parent.calendarModeButtonLabel;

  @override
  String get cancelButtonLabel => parent.cancelButtonLabel;

  @override
  String get clearButtonTooltip => parent.clearButtonTooltip;

  @override
  String get closeButtonLabel => parent.closeButtonLabel;

  @override
  String get closeButtonTooltip => parent.closeButtonTooltip;

  @override
  String get continueButtonLabel => parent.continueButtonLabel;

  @override
  String get copyButtonLabel => parent.copyButtonLabel;

  @override
  String get currentDateLabel => parent.currentDateLabel;

  @override
  String get cutButtonLabel => parent.cutButtonLabel;

  @override
  String get dateHelpText => parent.dateHelpText;

  @override
  String get dateInputLabel => parent.dateInputLabel;

  @override
  String get dateOutOfRangeLabel => parent.dateOutOfRangeLabel;

  @override
  String get datePickerHelpText => parent.datePickerHelpText;

  @override
  String dateRangeEndDateSemanticLabel(String formattedDate) => parent.dateRangeEndDateSemanticLabel(formattedDate);

  @override
  String get dateRangeEndLabel => parent.dateRangeEndLabel;

  @override
  String get dateRangePickerHelpText => parent.dateRangePickerHelpText;

  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) => parent.dateRangeStartDateSemanticLabel(formattedDate);

  @override
  String get dateRangeStartLabel => parent.dateRangeStartLabel;

  @override
  String get dateSeparator => parent.dateSeparator;

  @override
  String get deleteButtonTooltip => parent.deleteButtonTooltip;

  @override
  String get dialModeButtonLabel => parent.dialModeButtonLabel;

  @override
  String get dialogLabel => parent.dialogLabel;

  @override
  String get drawerLabel => parent.drawerLabel;

  @override
  int get firstDayOfWeekIndex {
    var i = _firstDayOfWeekIndex ?? parent.firstDayOfWeekIndex;
    debugPrint('TLAD $runtimeType firstDayOfWeekIndex=$i _firstDayOfWeekIndex=$_firstDayOfWeekIndex parent.firstDayOfWeekIndex=${parent.firstDayOfWeekIndex}');
    return i;
  }

  @override
  String get firstPageTooltip => parent.firstPageTooltip;

  @override
  String formatCompactDate(DateTime date) => parent.formatCompactDate(date);

  @override
  String formatDecimal(int number) => parent.formatDecimal(number);

  @override
  String formatFullDate(DateTime date) => parent.formatFullDate(date);

  @override
  String formatHour(TimeOfDay timeOfDay, {bool alwaysUse24HourFormat = false}) => parent.formatHour(timeOfDay, alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  String formatMediumDate(DateTime date) => parent.formatMediumDate(date);

  @override
  String formatMinute(TimeOfDay timeOfDay) => parent.formatMinute(timeOfDay);

  @override
  String formatMonthYear(DateTime date) => parent.formatMonthYear(date);

  @override
  String formatShortDate(DateTime date) => parent.formatShortDate(date);

  @override
  String formatShortMonthDay(DateTime date) => parent.formatShortMonthDay(date);

  @override
  String formatTimeOfDay(TimeOfDay timeOfDay, {bool alwaysUse24HourFormat = false}) => parent.formatTimeOfDay(timeOfDay);

  @override
  String formatYear(DateTime date) => parent.formatYear(date);

  @override
  String get hideAccountsLabel => parent.hideAccountsLabel;

  @override
  String get inputDateModeButtonLabel => parent.inputDateModeButtonLabel;

  @override
  String get inputTimeModeButtonLabel => parent.inputTimeModeButtonLabel;

  @override
  String get invalidDateFormatLabel => parent.invalidDateFormatLabel;

  @override
  String get invalidDateRangeLabel => parent.invalidDateRangeLabel;

  @override
  String get invalidTimeLabel => parent.invalidTimeLabel;

  @override
  String get keyboardKeyAlt => parent.keyboardKeyAlt;

  @override
  String get keyboardKeyAltGraph => parent.keyboardKeyAltGraph;

  @override
  String get keyboardKeyBackspace => parent.keyboardKeyBackspace;

  @override
  String get keyboardKeyCapsLock => parent.keyboardKeyCapsLock;

  @override
  String get keyboardKeyChannelDown => parent.keyboardKeyChannelDown;

  @override
  String get keyboardKeyChannelUp => parent.keyboardKeyChannelUp;

  @override
  String get keyboardKeyControl => parent.keyboardKeyControl;

  @override
  String get keyboardKeyDelete => parent.keyboardKeyDelete;

  @override
  String get keyboardKeyEject => parent.keyboardKeyEject;

  @override
  String get keyboardKeyEnd => parent.keyboardKeyEnd;

  @override
  String get keyboardKeyEscape => parent.keyboardKeyEscape;

  @override
  String get keyboardKeyFn => parent.keyboardKeyFn;

  @override
  String get keyboardKeyHome => parent.keyboardKeyHome;

  @override
  String get keyboardKeyInsert => parent.keyboardKeyInsert;

  @override
  String get keyboardKeyMeta => parent.keyboardKeyMeta;

  @override
  String get keyboardKeyMetaMacOs => parent.keyboardKeyMetaMacOs;

  @override
  String get keyboardKeyMetaWindows => parent.keyboardKeyMetaWindows;

  @override
  String get keyboardKeyNumLock => parent.keyboardKeyNumLock;

  @override
  String get keyboardKeyNumpad0 => parent.keyboardKeyNumpad0;

  @override
  String get keyboardKeyNumpad1 => parent.keyboardKeyNumpad1;

  @override
  String get keyboardKeyNumpad2 => parent.keyboardKeyNumpad2;

  @override
  String get keyboardKeyNumpad3 => parent.keyboardKeyNumpad3;

  @override
  String get keyboardKeyNumpad4 => parent.keyboardKeyNumpad4;

  @override
  String get keyboardKeyNumpad5 => parent.keyboardKeyNumpad5;

  @override
  String get keyboardKeyNumpad6 => parent.keyboardKeyNumpad6;

  @override
  String get keyboardKeyNumpad7 => parent.keyboardKeyNumpad7;

  @override
  String get keyboardKeyNumpad8 => parent.keyboardKeyNumpad8;

  @override
  String get keyboardKeyNumpad9 => parent.keyboardKeyNumpad9;

  @override
  String get keyboardKeyNumpadAdd => parent.keyboardKeyNumpadAdd;

  @override
  String get keyboardKeyNumpadComma => parent.keyboardKeyNumpadComma;

  @override
  String get keyboardKeyNumpadDecimal => parent.keyboardKeyNumpadDecimal;

  @override
  String get keyboardKeyNumpadDivide => parent.keyboardKeyNumpadDivide;

  @override
  String get keyboardKeyNumpadEnter => parent.keyboardKeyNumpadEnter;

  @override
  String get keyboardKeyNumpadEqual => parent.keyboardKeyNumpadEqual;

  @override
  String get keyboardKeyNumpadMultiply => parent.keyboardKeyNumpadMultiply;

  @override
  String get keyboardKeyNumpadParenLeft => parent.keyboardKeyNumpadParenLeft;

  @override
  String get keyboardKeyNumpadParenRight => parent.keyboardKeyNumpadParenRight;

  @override
  String get keyboardKeyNumpadSubtract => parent.keyboardKeyNumpadSubtract;

  @override
  String get keyboardKeyPageDown => parent.keyboardKeyPageDown;

  @override
  String get keyboardKeyPageUp => parent.keyboardKeyPageUp;

  @override
  String get keyboardKeyPower => parent.keyboardKeyPower;

  @override
  String get keyboardKeyPowerOff => parent.keyboardKeyPowerOff;

  @override
  String get keyboardKeyPrintScreen => parent.keyboardKeyPrintScreen;

  @override
  String get keyboardKeyScrollLock => parent.keyboardKeyScrollLock;

  @override
  String get keyboardKeySelect => parent.keyboardKeySelect;

  @override
  String get keyboardKeyShift => parent.keyboardKeyShift;

  @override
  String get keyboardKeySpace => parent.keyboardKeySpace;

  @override
  String get lastPageTooltip => parent.lastPageTooltip;

  @override
  String licensesPackageDetailText(int licenseCount) => parent.licensesPackageDetailText(licenseCount);

  @override
  String get licensesPageTitle => parent.licensesPageTitle;

  @override
  String get lookUpButtonLabel => parent.lookUpButtonLabel;

  @override
  String get menuBarMenuLabel => parent.menuBarMenuLabel;

  @override
  String get menuDismissLabel => parent.menuDismissLabel;

  @override
  String get modalBarrierDismissLabel => parent.modalBarrierDismissLabel;

  @override
  String get moreButtonTooltip => parent.moreButtonTooltip;

  @override
  List<String> get narrowWeekdays => parent.narrowWeekdays;

  @override
  String get nextMonthTooltip => parent.nextMonthTooltip;

  @override
  String get nextPageTooltip => parent.nextPageTooltip;

  @override
  String get okButtonLabel => parent.okButtonLabel;

  @override
  String get openAppDrawerTooltip => parent.openAppDrawerTooltip;

  @override
  String pageRowsInfoTitle(int firstRow, int lastRow, int rowCount, bool rowCountIsApproximate) => parent.pageRowsInfoTitle(firstRow, lastRow, rowCount, rowCountIsApproximate);

  @override
  DateTime? parseCompactDate(String? inputString) => parent.parseCompactDate(inputString);

  @override
  String get pasteButtonLabel => parent.pasteButtonLabel;

  @override
  String get popupMenuLabel => parent.popupMenuLabel;

  @override
  String get postMeridiemAbbreviation => parent.postMeridiemAbbreviation;

  @override
  String get previousMonthTooltip => parent.previousMonthTooltip;

  @override
  String get previousPageTooltip => parent.previousPageTooltip;

  @override
  String get refreshIndicatorSemanticLabel => parent.refreshIndicatorSemanticLabel;

  @override
  String remainingTextFieldCharacterCount(int remaining) => parent.remainingTextFieldCharacterCount(remaining);

  @override
  String get reorderItemDown => throw UnimplementedError();

  @override
  String get reorderItemLeft => throw UnimplementedError();

  @override
  String get reorderItemRight => throw UnimplementedError();

  @override
  String get reorderItemToEnd => throw UnimplementedError();

  @override
  String get reorderItemToStart => throw UnimplementedError();

  @override
  String get reorderItemUp => throw UnimplementedError();

  @override
  String get rowsPerPageTitle => parent.rowsPerPageTitle;

  @override
  String get saveButtonLabel => parent.saveButtonLabel;

  @override
  String get scanTextButtonLabel => parent.scanTextButtonLabel;

  @override
  String get scrimLabel => parent.scrimLabel;

  @override
  String scrimOnTapHint(String modalRouteContentName) => parent.scrimOnTapHint(modalRouteContentName);

  @override
  ScriptCategory get scriptCategory => parent.scriptCategory;

  @override
  String get searchFieldLabel => parent.searchFieldLabel;

  @override
  String get searchWebButtonLabel => parent.searchWebButtonLabel;

  @override
  String get selectAllButtonLabel => parent.selectAllButtonLabel;

  @override
  String get selectYearSemanticsLabel => parent.selectYearSemanticsLabel;

  @override
  String get selectedDateLabel => parent.selectedDateLabel;

  @override
  String selectedRowCountTitle(int selectedRowCount) => parent.selectedRowCountTitle(selectedRowCount);

  @override
  String get shareButtonLabel => parent.shareButtonLabel;

  @override
  String get showAccountsLabel => parent.showAccountsLabel;

  @override
  String get showMenuTooltip => parent.showMenuTooltip;

  @override
  String get signedInLabel => parent.signedInLabel;

  @override
  String tabLabel({required int tabIndex, required int tabCount}) => parent.tabLabel(tabIndex: tabIndex, tabCount: tabCount);

  @override
  TimeOfDayFormat timeOfDayFormat({bool alwaysUse24HourFormat = false}) => parent.timeOfDayFormat(alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  String get timePickerDialHelpText => parent.timePickerDialHelpText;

  @override
  String get timePickerHourLabel => parent.timePickerHourLabel;

  @override
  String get timePickerHourModeAnnouncement => parent.timePickerHourModeAnnouncement;

  @override
  String get timePickerInputHelpText => parent.timePickerInputHelpText;

  @override
  String get timePickerMinuteLabel => parent.timePickerMinuteLabel;

  @override
  String get timePickerMinuteModeAnnouncement => parent.timePickerMinuteModeAnnouncement;

  @override
  String get unspecifiedDate => parent.unspecifiedDate;

  @override
  String get unspecifiedDateRange => parent.unspecifiedDateRange;

  @override
  String get viewLicensesButtonLabel => parent.viewLicensesButtonLabel;
}
