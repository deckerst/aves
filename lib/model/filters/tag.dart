import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class TagFilter extends CollectionFilter {
  static const type = 'tag';

  final String tag;
  late EntryFilter _test;

  TagFilter(this.tag) {
    if (tag.isEmpty) {
      _test = (entry) => entry.xmpSubjects.isEmpty;
    } else {
      _test = (entry) => entry.xmpSubjects.contains(tag);
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
  Widget? iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => showGenericIcon ? Icon(tag.isEmpty ? AIcons.tagOff : AIcons.tag, size: size) : null;

  @override
  String get category => type;

  @override
  String get key => '$type-$tag';

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
