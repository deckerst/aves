import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class DateFilter extends CollectionFilter {
  static const type = 'date';

  final DateLevel level;
  late final DateTime? date;
  late final DateTime _effectiveDate;
  late final EntryFilter _test;

  static final onThisDay = DateFilter(DateLevel.md, null);

  @override
  List<Object?> get props => [level, date, reversed];

  DateFilter(this.level, this.date, {super.reversed = false}) {
    _effectiveDate = date ?? DateTime.now();
    switch (level) {
      case DateLevel.y:
        _test = (entry) => entry.bestDate?.isAtSameYearAs(_effectiveDate) ?? false;
      case DateLevel.ym:
        _test = (entry) => entry.bestDate?.isAtSameMonthAs(_effectiveDate) ?? false;
      case DateLevel.ymd:
        _test = (entry) => entry.bestDate?.isAtSameDayAs(_effectiveDate) ?? false;
      case DateLevel.md:
        final month = _effectiveDate.month;
        final day = _effectiveDate.day;
        _test = (entry) {
          final bestDate = entry.bestDate;
          return bestDate != null && bestDate.month == month && bestDate.day == day;
        };
      case DateLevel.m:
        final month = _effectiveDate.month;
        _test = (entry) => entry.bestDate?.month == month;
      case DateLevel.d:
        final day = _effectiveDate.day;
        _test = (entry) => entry.bestDate?.day == day;
    }
  }

  factory DateFilter.fromMap(Map<String, dynamic> json) {
    final dateString = json['date'] as String?;
    return DateFilter(
      DateLevel.values.firstWhereOrNull((v) => v.toString() == json['level']) ?? DateLevel.ymd,
      dateString != null ? DateTime.tryParse(dateString) : null,
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'level': level.toString(),
        'date': date?.toIso8601String(),
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

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
      case DateLevel.y:
        return {DateLevel.md, DateLevel.m, DateLevel.d}.contains(b);
      case DateLevel.ym:
        return DateLevel.d == b;
      case DateLevel.ymd:
        return false;
      case DateLevel.md:
        return DateLevel.y == b;
      case DateLevel.m:
        return {DateLevel.y, DateLevel.d}.contains(b);
      case DateLevel.d:
        return {DateLevel.y, DateLevel.ym, DateLevel.m}.contains(b);
    }
  }

  @override
  String get universalLabel => _effectiveDate.toIso8601String();

  @override
  String getLabel(BuildContext context) {
    final locale = context.locale;
    switch (level) {
      case DateLevel.y:
        return DateFormat.y(locale).format(_effectiveDate);
      case DateLevel.ym:
        return DateFormat.yMMM(locale).format(_effectiveDate);
      case DateLevel.ymd:
        return formatDay(_effectiveDate, locale);
      case DateLevel.md:
        if (date != null) {
          return DateFormat.MMMd(locale).format(_effectiveDate);
        } else {
          return context.l10n.filterOnThisDayLabel;
        }
      case DateLevel.m:
        return DateFormat.MMMM(locale).format(_effectiveDate);
      case DateLevel.d:
        return DateFormat.d(locale).format(_effectiveDate);
    }
  }

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(AIcons.date, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$level-$date';
}

enum DateLevel { y, ym, ymd, md, m, d }
