import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class QueryFilter extends CollectionFilter {
  static const type = 'query';

  static final exactRegex = RegExp('^"(.*)"\$');

  final String query;
  bool Function(ImageEntry) _filter;

  QueryFilter(this.query) {
    var upQuery = query.toUpperCase();

    // allow NOT queries starting with `-`
    final not = upQuery.startsWith('-');
    if (not) {
      upQuery = upQuery.substring(1);
    }

    // allow untrimmed queries wrapped with `"..."`
    final matches = exactRegex.allMatches(upQuery);
    if (matches.length == 1) {
      upQuery = matches.elementAt(0).group(1);
    }

    _filter = not ? (entry) => !entry.search(upQuery) : (entry) => entry.search(upQuery);
  }

  @override
  bool filter(ImageEntry entry) => _filter(entry);

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
  int get hashCode => hashValues('QueryFilter', query);
}
