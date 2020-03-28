import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class TagFilter extends CollectionFilter {
  static const type = 'tag';

  final String tag;

  const TagFilter(this.tag);

  @override
  bool filter(ImageEntry entry) => entry.xmpSubjects.contains(tag);

  @override
  String get label => tag;

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.localOffer, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is TagFilter && other.tag == tag;
  }

  @override
  int get hashCode => hashValues('TagFilter', tag);
}
