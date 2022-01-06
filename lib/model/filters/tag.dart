import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

class TagFilter extends CollectionFilter {
  static const type = 'tag';

  final String tag;
  late final EntryFilter _test;

  @override
  List<Object?> get props => [tag];

  TagFilter(this.tag) {
    if (tag.isEmpty) {
      _test = (entry) => entry.tags.isEmpty;
    } else {
      _test = (entry) => entry.tags.contains(tag);
    }
  }

  TagFilter.fromMap(Map<String, dynamic> json)
      : this(
          json['tag'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'tag': tag,
      };

  @override
  EntryFilter get test => _test;

  @override
  bool get isUnique => false;

  @override
  String get universalLabel => tag;

  @override
  String getLabel(BuildContext context) => tag.isEmpty ? context.l10n.filterTagEmptyLabel : tag;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => showGenericIcon ? Icon(tag.isEmpty ? AIcons.tagUntagged : AIcons.tag, size: size) : null;

  @override
  String get category => type;

  @override
  String get key => '$type-$tag';
}
