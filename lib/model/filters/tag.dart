import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/widgets.dart';

class TagFilter extends CollectionFilter {
  static const type = 'tag';

  final String tag;

  const TagFilter(this.tag);

  TagFilter.fromJson(Map<String, dynamic> json)
      : this(
          json['tag'],
        );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'tag': tag,
      };

  @override
  bool filter(ImageEntry entry) => entry.xmpSubjects.contains(tag);

  @override
  bool get isUnique => false;

  @override
  String get label => tag;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => showGenericIcon ? Icon(AIcons.tag, size: size) : null;

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is TagFilter && other.tag == tag;
  }

  @override
  int get hashCode => hashValues('TagFilter', tag);

  @override
  String toString() {
    return 'TagFilter{tag=$tag}';
  }
}
