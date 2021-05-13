import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QueryFilter extends CollectionFilter {
  static const type = 'query';

  static final RegExp exactRegex = RegExp('^"(.*)"\$');

  final String query;
  final bool colorful;
  late EntryFilter _test;

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
      upQuery = matches.first.group(1)!;
    }

    _test = not ? (entry) => !entry.search(upQuery) : (entry) => entry.search(upQuery);
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
  EntryFilter get test => _test;

  @override
  bool get isUnique => false;

  @override
  String get universalLabel => query;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => Icon(AIcons.text, size: size);

  @override
  Future<Color> color(BuildContext context) => colorful ? super.color(context) : SynchronousFuture(AvesFilterChip.defaultOutlineColor);

  @override
  String get category => type;

  @override
  String get key => '$type-$query';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is QueryFilter && other.query == query;
  }

  @override
  int get hashCode => hashValues(type, query);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{query=$query}';
}
