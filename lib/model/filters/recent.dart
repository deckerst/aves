import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';

class RecentlyAddedFilter extends CollectionFilter {
  static const type = 'recently_added';

  static final instance = RecentlyAddedFilter._private();

  static late int nowSecs;

  static void updateNow() {
    nowSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  static const _dayInSecs = 24 * 60 * 60;

  @override
  List<Object?> get props => [];

  RecentlyAddedFilter._private() {
    updateNow();
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
      };

  @override
  EntryFilter get test => (entry) => (nowSecs - (entry.dateAddedSecs ?? 0)) < _dayInSecs;

  @override
  String get universalLabel => type;

  @override
  String getLabel(BuildContext context) => context.l10n.filterRecentlyAddedLabel;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(AIcons.dateRecent, size: size);

  @override
  String get category => type;

  @override
  String get key => type;
}
