import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class TagFilter extends CoveredCollectionFilter {
  static const type = 'tag';

  final String tag;
  late final EntryFilter _test;

  @override
  List<Object?> get props => [tag, reversed];

  TagFilter(this.tag, {super.reversed = false}) {
    if (tag.isEmpty) {
      _test = (entry) => entry.tags.isEmpty;
    } else {
      _test = (entry) => entry.tags.contains(tag);
    }
  }

  factory TagFilter.fromMap(Map<String, dynamic> json) {
    return TagFilter(
      json['tag'],
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'tag': tag,
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => tag;

  @override
  String getLabel(BuildContext context) => tag.isEmpty ? context.l10n.filterNoTagLabel : tag;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return allowGenericIcon ? Icon(tag.isEmpty ? AIcons.tagUntagged : AIcons.tag, size: size) : null;
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$tag';
}
