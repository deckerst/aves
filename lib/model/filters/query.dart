import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class QueryFilter extends CollectionFilter {
  static const type = 'query';

  static final RegExp exactRegex = RegExp('^"(.*)"\$');

  final String query;
  final bool colorful, live;
  late final EntryFilter _test;

  @override
  List<Object?> get props => [query, live];

  static final _fieldPattern = RegExp(r'(.+)([=<>])(.+)');
  static const keyContentId = 'ID';
  static const opEqual = '=';

  QueryFilter(this.query, {this.colorful = true, this.live = false}) {
    var upQuery = query.toUpperCase();

    final match = _fieldPattern.firstMatch(upQuery);
    if (match != null) {
      final key = match.group(1)?.trim();
      final op = match.group(2)?.trim();
      final value = match.group(3)?.trim();
      if (key != null && op != null && value != null) {
        switch (key) {
          case keyContentId:
            if (op == opEqual) {
              final contentId = int.tryParse(value);
              if (contentId != null) {
                _test = (entry) => entry.contentId == contentId;
                return;
              }
            }
            break;
        }
      }
    }

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

    // default to title search
    bool testTitle(AvesEntry entry) => entry.bestTitle?.toUpperCase().contains(upQuery) == true;
    _test = not ? (entry) => !testTitle(entry) : testTitle;
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
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(AIcons.text, size: size);

  @override
  Future<Color> color(BuildContext context) {
    if (colorful) {
      return super.color(context);
    }

    final colors = context.read<AvesColorsData>();
    return SynchronousFuture(colors.neutral);
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$query';
}
