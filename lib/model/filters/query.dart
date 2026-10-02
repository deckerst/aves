import 'package:aves/locale/aves_locale.dart';
import 'package:aves/locale/calendar/calendar_utils.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class QueryFilter extends CollectionFilter {
  static const type = 'query';

  static final _exactRegex = RegExp('^"(.*)"\$');
  static final _regexRegex = RegExp('^/(.*)/\$');

  final String query;
  final ACalendar calendar;
  final bool colorful, live;
  late final EntryPredicate _test;

  @override
  List<Object?> get props => [query, calendar, live, reversed];

  static final _fieldPattern = RegExp(r'(.+)([=<>])(.+)');
  static final _fileSizePattern = RegExp(r'(\d+)([KMG])?');
  static const keyContentExtension = 'EXT';
  static const keyContentId = 'ID';
  static const keyContentYear = 'YEAR';
  static const keyContentMonth = 'MONTH';
  static const keyContentDay = 'DAY';
  static const keyContentWidth = 'WIDTH';
  static const keyContentHeight = 'HEIGHT';
  static const keyContentSize = 'SIZE';
  static const opEqual = '=';
  static const opLower = '<';
  static const opGreater = '>';

  new(this.query, this.calendar, {this.colorful = true, this.live = false, super.reversed = false}) {
    // allow regex queries wrapped with `/.../`
    var matches = _regexRegex.allMatches(query);
    if (matches.length == 1) {
      try {
        final regex = RegExp(matches.first.group(1)!);
        _test = (entry) {
          final title = entry.bestTitle;
          return title != null && regex.hasMatch(title);
        };
      } on FormatException catch (_) {
        // invalid regex
        _test = (entry) => false;
      }
      return;
    }

    var upQuery = query.toUpperCase();

    final test = fieldTest(upQuery);
    if (test != null) {
      _test = test;
      return;
    }

    // allow NOT queries starting with `-`
    final not = upQuery.startsWith('-');
    if (not) {
      upQuery = upQuery.substring(1);
    }

    // allow untrimmed queries wrapped with `"..."`
    matches = _exactRegex.allMatches(upQuery);
    if (matches.length == 1) {
      upQuery = matches.first.group(1)!;
    }

    // default to title search
    bool testTitle(AvesEntry entry) => entry.bestTitle?.toUpperCase().contains(upQuery) == true;
    _test = not ? (entry) => !testTitle(entry) : testTitle;
  }

  factory fromMap(Map<String, Object?> json) {
    return QueryFilter(
      json['query'] as String,
      ACalendar.values.safeByName(json['calendar'] as String?) ?? .gregorian,
      reversed: json['reversed'] as bool? ?? false,
    );
  }

  @override
  Map<String, Object?> toJsonMap() => {
    'type': type,
    'query': query,
    if (calendar != .gregorian) 'calendar': calendar.name,
    if (reversed) 'reversed': reversed,
  };

  @override
  EntryPredicate get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => query;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(AIcons.text, fill: 1, size: size);

  @override
  Future<Color> color(BuildContext context) {
    if (colorful) {
      return super.color(context);
    }

    final colors = context.read<AvesColorsData>();
    return SynchronousFuture(colors.neutral);
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$calendar-$query';

  EntryPredicate? fieldTest(String upQuery) {
    var match = _fieldPattern.firstMatch(upQuery);
    if (match == null) return null;

    final key = match.group(1)?.trim();
    final op = match.group(2)?.trim();
    var valueString = match.group(3)?.trim();
    if (key == null || op == null || valueString == null) return null;

    final valueInt = int.tryParse(valueString);

    switch (key) {
      case keyContentExtension:
        if (op == opEqual) {
          final extension = '.$valueString';
          return (entry) => entry.extension?.toUpperCase() == extension;
        }
      case keyContentId:
        if (valueInt == null) return null;
        if (op == opEqual) {
          return (entry) => entry.contentId == valueInt;
        }
      case keyContentYear:
        if (valueInt == null) return null;
        final calOps = calendar.ops;
        int getYear(AvesEntry entry) {
          final date = entry.bestDate;
          return date != null ? calOps.getYearMonthDay(date).$1 : 0;
        }
        switch (op) {
          case opEqual:
            return (entry) => getYear(entry) == valueInt;
          case opLower:
            return (entry) => getYear(entry) < valueInt;
          case opGreater:
            return (entry) => getYear(entry) > valueInt;
        }
      case keyContentMonth:
        if (valueInt == null) return null;
        final calOps = calendar.ops;
        int getMonth(AvesEntry entry) {
          final date = entry.bestDate;
          return date != null ? calOps.getYearMonthDay(date).$2 : 0;
        }
        switch (op) {
          case opEqual:
            return (entry) => getMonth(entry) == valueInt;
          case opLower:
            return (entry) => getMonth(entry) < valueInt;
          case opGreater:
            return (entry) => getMonth(entry) > valueInt;
        }
      case keyContentDay:
        if (valueInt == null) return null;
        final calOps = calendar.ops;
        int getDay(AvesEntry entry) {
          final date = entry.bestDate;
          return date != null ? calOps.getYearMonthDay(date).$3 : 0;
        }
        switch (op) {
          case opEqual:
            return (entry) => getDay(entry) == valueInt;
          case opLower:
            return (entry) => getDay(entry) < valueInt;
          case opGreater:
            return (entry) => getDay(entry) > valueInt;
        }
      case keyContentWidth:
        if (valueInt == null) return null;
        switch (op) {
          case opEqual:
            return (entry) => entry.displaySize.width == valueInt;
          case opLower:
            return (entry) => entry.displaySize.width < valueInt;
          case opGreater:
            return (entry) => entry.displaySize.width > valueInt;
        }
      case keyContentHeight:
        if (valueInt == null) return null;
        switch (op) {
          case opEqual:
            return (entry) => entry.displaySize.height == valueInt;
          case opLower:
            return (entry) => entry.displaySize.height < valueInt;
          case opGreater:
            return (entry) => entry.displaySize.height > valueInt;
        }
      case keyContentSize:
        match = _fileSizePattern.firstMatch(valueString);
        if (match == null) return null;

        valueString = match.group(1)?.trim();
        if (valueString == null) return null;
        final valueInt = int.tryParse(valueString);
        if (valueInt == null) return null;

        final multiplierString = match.group(2)?.trim();
        final bytes = applyFileSizeSuffix(multiplierString, valueInt);

        switch (op) {
          case opEqual:
            return (entry) => (entry.sizeBytes ?? 0) == bytes;
          case opLower:
            return (entry) => (entry.sizeBytes ?? 0) < bytes;
          case opGreater:
            return (entry) => (entry.sizeBytes ?? 0) > bytes;
        }
    }

    return null;
  }
}
