import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/calendar/calendar_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:intl4x/datetime_format.dart' as intl4x;

class DateFilter extends CollectionFilter {
  static const type = 'date';

  final DateLevel level;
  late final intl4x.Calendar calendar;
  late final DateTime? date;
  late final DateTime _effectiveDate;
  late final EntryPredicate _test;

  // TODO TLAD [calendar]
  static final onThisDay = DateFilter(intl4x.Calendar.gregorian, DateLevel.md, null);

  @override
  List<Object?> get props => [level, date, reversed];

  DateFilter(this.calendar, this.level, this.date, {super.reversed = false}) {
    _effectiveDate = date ?? DateTime.now();
    final comparator = calendar.getComparator();
    switch (level) {
      case .y:
        _test = (entry) => comparator.isSameYear(entry.bestDate, _effectiveDate);
      case .ym:
        _test = (entry) => comparator.isSameYearMonth(entry.bestDate, _effectiveDate);
      case .ymd:
        _test = (entry) => comparator.isSameYearMonthDay(entry.bestDate, _effectiveDate);
      case .md:
        final month = _effectiveDate.month;
        final day = _effectiveDate.day;
        // TODO TLAD [calendar] isSameMonthDay
        _test = (entry) {
          final bestDate = entry.bestDate;
          return bestDate != null && bestDate.month == month && bestDate.day == day;
        };
      case .m:
        // TODO TLAD [calendar] isSameMonth
        final month = _effectiveDate.month;
        _test = (entry) => entry.bestDate?.month == month;
      case .d:
        // TODO TLAD [calendar] isSameDay
        final day = _effectiveDate.day;
        _test = (entry) => entry.bestDate?.day == day;
    }
  }

  factory DateFilter.fromMap(Map<String, Object?> json) {
    final dateString = json['date'] as String?;
    return DateFilter(
      intl4x.Calendar.values.safeByName(json['calendar'] as String?) ?? .gregorian,
      DateLevel.values.safeByName(json['level'] as String?) ?? .ymd,
      dateString != null ? DateTime.tryParse(dateString) : null,
      reversed: json['reversed'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJsonMap() => {
    'type': type,
    if (calendar != .gregorian) 'calendar': calendar.name,
    'level': level.name,
    'date': date?.toIso8601String(),
    if (reversed) 'reversed': reversed,
  };

  @override
  EntryPredicate get positiveTest => _test;

  @override
  bool get exclusiveProp => true;

  @override
  bool isCompatible(CollectionFilter other) {
    if (other is DateFilter) {
      if (reversed != other.reversed && this == other.reverse()) return false;
      return reversed || other.reversed || isCompatibleLevel(level, other.level);
    } else {
      return true;
    }
  }

  static bool isCompatibleLevel(DateLevel a, DateLevel b) {
    switch (a) {
      case .y:
        return {DateLevel.md, DateLevel.m, DateLevel.d}.contains(b);
      case .ym:
        return DateLevel.d == b;
      case .ymd:
        return false;
      case .md:
        return DateLevel.y == b;
      case .m:
        return {DateLevel.y, DateLevel.d}.contains(b);
      case .d:
        return {DateLevel.y, DateLevel.ym, DateLevel.m}.contains(b);
    }
  }

  @override
  String get universalLabel => _effectiveDate.toIso8601String();

  @override
  String getLabel(BuildContext context) {
    final locale = settings.avesLocale.copyWith(calendar: calendar);
    switch (level) {
      case .y:
        return locale.y(_effectiveDate);
      case .ym:
        return locale.yMMM(_effectiveDate);
      case .ymd:
        return locale.yMMMd(_effectiveDate);
      case .md:
        if (date != null) {
          return locale.MMMd(_effectiveDate);
        } else {
          return context.l10n.filterOnThisDayLabel;
        }
      case .m:
        return locale.MMMM(_effectiveDate);
      case .d:
        return locale.d(_effectiveDate);
    }
  }

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(AIcons.date, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$calendar-$level-$date';
}

enum DateLevel { y, ym, ymd, md, m, d }
