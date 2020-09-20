import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QueryFilter extends CollectionFilter {
  static const type = 'query';

  static final RegExp exactRegex = RegExp('^"(.*)"\$');

  final String query;
  final bool colorful;
  bool Function(ImageEntry) _filter;

  QueryFilter(this.query, {this.colorful = true}) {
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

  QueryFilter.fromMap(Map<String, dynamic> json)
      : this(
          json['query'],
        );

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'query': query,
      };

  @override
  bool filter(ImageEntry entry) => _filter(entry);

  @override
  bool get isUnique => false;

  @override
  String get label => '$query';

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(AIcons.text, size: size);

  @override
  Future<Color> color(BuildContext context) => colorful ? super.color(context) : SynchronousFuture(Colors.white);

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
