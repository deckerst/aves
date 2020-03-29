import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class QueryFilter extends CollectionFilter {
  static const type = 'query';

  final String query;

  const QueryFilter(this.query);

  @override
  bool filter(ImageEntry entry) => entry.search(query);

  @override
  bool get isUnique => false;

  @override
  String get label => '${query}';

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.formatQuote, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is QueryFilter && other.query == query;
  }

  @override
  int get hashCode => hashValues('MetadataFilter', query);
}
