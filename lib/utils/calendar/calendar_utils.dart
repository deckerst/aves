import 'package:aves/utils/calendar/comparators.dart';
import 'package:aves/utils/calendar/persian_delegate.dart';
import 'package:flutter/material.dart';
import 'package:intl4x/datetime_format.dart' as intl4x;

extension ExtraIntl4xCalendar on intl4x.Calendar {
  int get maxDaysInYear => 366;

  int get maxDaysInMonth => 31;

  int get maxMonthsInYear => 12;

  CalendarComparator getComparator() {
    switch (this) {
      case .gregorian:
        return const GregorianCalendarComparator();
      case .persian:
        return const PersianCalendarComparator();
      default:
        throw UnimplementedError();
    }
  }

  CalendarDelegate getPickerDelegate(intl4x.Locale locale) {
    switch (this) {
      case .gregorian:
        return const GregorianCalendarDelegate();
      case .persian:
        return PersianCalendarDelegate(locale);
      default:
        throw UnimplementedError();
    }
  }
}
