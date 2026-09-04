import 'package:aves/locale/aves_locale.dart';
import 'package:material_ui/material_ui.dart';

abstract class AvesCalendarDelegate<T extends DateTime> extends CalendarDelegate<T> {
  final AvesLocale locale;

  const new(this.locale);

  DateTime toDateForIntl4xFormat(T date);

  @override
  String formatMonthYear(T date, MaterialLocalizations localizations) {
    // originally `yMMMM`
    return locale.yMMMM(toDateForIntl4xFormat(date));
  }

  @override
  String formatMediumDate(T date, MaterialLocalizations localizations) {
    // originally `MMMEd` e.g. Wed, Sep 27
    return locale.MMMEd(toDateForIntl4xFormat(date));
  }

  @override
  String formatShortMonthDay(T date, MaterialLocalizations localizations) {
    // originally `MMMd` e.g. Feb 21
    return locale.MMMd(toDateForIntl4xFormat(date));
  }

  @override
  String formatShortDate(T date, MaterialLocalizations localizations) {
    // originally `yMMMd` e.g. Feb 21, 2019
    return locale.yMMMd(toDateForIntl4xFormat(date));
  }

  @override
  String formatFullDate(T date, MaterialLocalizations localizations) {
    // originally `yMMMMEEEEd` e.g. Wednesday, September 27, 2017
    return locale.yMMMMEEEEd(toDateForIntl4xFormat(date));
  }

  @override
  String formatCompactDate(T date, MaterialLocalizations localizations) {
    // originally `yMd` e.g. 02/21/2019
    return locale.yMd(toDateForIntl4xFormat(date));
  }

  @override
  String dateHelpText(MaterialLocalizations localizations) {
    return localizations.dateHelpText;
  }
}
