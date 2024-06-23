import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class TrashFilter extends CollectionFilter {
  static const type = 'trash';

  static bool _test(AvesEntry entry) => entry.trashed;

  static const instance = TrashFilter._private();
  static const instanceReversed = TrashFilter._private(reversed: true);

  @override
  List<Object?> get props => [reversed];

  const TrashFilter._private({super.reversed = false});

  factory TrashFilter.fromMap(Map<String, dynamic> json) {
    final reversed = json['reversed'] ?? false;
    return reversed ? instanceReversed : instance;
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => type;

  @override
  String getLabel(BuildContext context) => context.l10n.filterBinLabel;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(AIcons.bin, size: size);

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed';
}
