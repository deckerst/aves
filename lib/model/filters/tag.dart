import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class TagFilter extends CollectionFilter {
  static const type = 'tag';
  static const emptyLabel = 'untagged';

  final String tag;

  const TagFilter(this.tag);

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
  bool filter(AvesEntry entry) => tag.isEmpty ? entry.xmpSubjects.isEmpty : entry.xmpSubjects.contains(tag);

  @override
  bool get isUnique => false;

  @override
  String get label => tag.isEmpty ? emptyLabel : tag;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => showGenericIcon ? Icon(tag.isEmpty ? AIcons.tagOff : AIcons.tag, size: size) : null;

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is TagFilter && other.tag == tag;
  }

  @override
  int get hashCode => hashValues(type, tag);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{tag=$tag}';
}
