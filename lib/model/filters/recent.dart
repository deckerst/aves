import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class RecentlyAddedFilter extends CollectionFilter {
  static const type = 'recently_added';

  static late EntryPredicate _test;

  static final instance = RecentlyAddedFilter._private();
  static final instanceReversed = RecentlyAddedFilter._private(reversed: true);

  static late int nowSecs;

  static void updateNow() {
    nowSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _test = (entry) => (nowSecs - (entry.dateAddedSecs ?? 0)) < _dayInSecs;
  }

  static const _dayInSecs = 24 * 60 * 60;

  @override
  List<Object?> get props => [reversed];

  RecentlyAddedFilter._private({super.reversed = false}) {
    updateNow();
  }

  factory RecentlyAddedFilter.fromMap(Map<String, dynamic> json) {
    final reversed = json['reversed'] ?? false;
    return reversed ? instanceReversed : instance;
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'reversed': reversed,
      };

  @override
  EntryPredicate get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => type;

  @override
  String getLabel(BuildContext context) => context.l10n.filterRecentlyAddedLabel;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(AIcons.dateRecent, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed';
}
