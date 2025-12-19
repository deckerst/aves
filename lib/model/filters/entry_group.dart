import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/services/common/entry_group_service.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/widgets.dart';

class EntryGroupFilter extends CollectionFilter {
  static const type = 'entry_group';

  final int groupId;
  final String groupName;

  @override
  List<Object?> get props => [groupId, reversed];

  const EntryGroupFilter(this.groupId, this.groupName, {super.reversed = false});

  factory EntryGroupFilter.fromMap(Map<String, dynamic> jsonMap) {
    return EntryGroupFilter(
      jsonMap['groupId'] as int,
      jsonMap['groupName'] as String,
      reversed: jsonMap['reversed'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'groupId': groupId,
        'groupName': groupName,
        'reversed': reversed,
      };

  @override
  EntryPredicate get positiveTest {
    return (AvesEntry entry) => EntryGroupService().getGroupMemberIds(groupId).contains(entry.id);
  }

  @override
  bool get exclusiveProp => true;

  @override
  String get universalLabel => groupName;

  @override
  String get key => '$type-$groupId';

  @override
  String get category => type;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(AIcons.group, size: size);
}
