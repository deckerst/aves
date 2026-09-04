import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/locale/aves_locale.dart';
import 'package:aves/locale/calendar/calendar_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/widgets.dart';

class DateFilter extends CollectionFilter {
  static const type = 'date';

  final DateLevel level;
  late final ACalendar calendar;
  late final DateTime? date;
  late final DateTime _effectiveDate;
  late final EntryPredicate _test;

  // TODO TLAD [calendar] reflect calendar setting
  static final onThisDay = DateFilter(ACalendar.gregorian, DateLevel.md, null);

  @override
  List<Object?> get props => [calendar, level, date, reversed];

  new(this.calendar, this.level, this.date, {super.reversed = false}) {
    _effectiveDate = date ?? DateTime.now();
    final calOps = calendar.ops;
    switch (level) {
      case .y:
        _test = (entry) => calOps.isSameYear(entry.bestDate, _effectiveDate);
      case .ym:
        _test = (entry) => calOps.isSameYearMonth(entry.bestDate, _effectiveDate);
      case .ymd:
        _test = (entry) => calOps.isSameYearMonthDay(entry.bestDate, _effectiveDate);
      case .md:
        final month = _effectiveDate.month;
        final day = _effectiveDate.day;
        _test = (entry) => calOps.isOnMonthDay(entry.bestDate, month, day);
      case .m:
        final month = _effectiveDate.month;
        _test = (entry) => calOps.isOnMonth(entry.bestDate, month);
      case .d:
        final day = _effectiveDate.day;
        _test = (entry) => calOps.isOnDay(entry.bestDate, day);
    }
  }

  factory fromMap(Map<String, Object?> json) {
    final dateString = json['date'] as String?;
    return DateFilter(
      ACalendar.values.safeByName(json['calendar'] as String?) ?? .gregorian,
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
    if (other is! DateFilter) return true;
    if (other.calendar != calendar) return true;
    if (reversed != other.reversed && this == other.reverse()) return false;
    return reversed || other.reversed || isCompatibleLevel(level, other.level);
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
          return locale.MMMd(calendar.ops.asNative(_effectiveDate));
        } else {
          return context.l10n.filterOnThisDayLabel;
        }
      case .m:
        return locale.MMMM(calendar.ops.asNative(_effectiveDate));
      case .d:
        return locale.d(calendar.ops.asNative(_effectiveDate));
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
