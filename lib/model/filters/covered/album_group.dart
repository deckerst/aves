import 'package:aves/model/filters/covered/album_base.dart';
import 'package:aves/model/filters/covered/covered.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/set_or.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:flutter/widgets.dart';

class AlbumGroupFilter extends AlbumBaseFilter with CoveredFilter {
  static const type = 'album_group';

  final Uri? uri;
  final SetOrFilter filter;
  late final String _name;

  @override
  List<Object?> get props => [uri, filter, reversed];

  AlbumGroupFilter(this.uri, this.filter, {super.reversed = false}) {
    final path = FilterGrouping.getGroupPath(uri) ?? '';
    _name = pContext.split(path).lastOrNull ?? '';
  }

  static AlbumGroupFilter? fromMap(Map<String, dynamic> json) {
    final filter = CollectionFilter.fromJson(json['filter']);
    if (filter == null || filter is! SetOrFilter) return null;

    final uriString = json['uri'];
    final uri = uriString is String ? Uri.tryParse(uriString) : null;
    if (uri == null) return null;

    return AlbumGroupFilter(
      uri,
      filter,
      reversed: json['reversed'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'uri': uri.toString(),
        'filter': filter.toJson(),
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => filter.test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => _name;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) {
    return allowGenericIcon ? Icon(AIcons.group, size: size) : null;
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed-$uri';

  @override
  bool match(String query) => _name.toUpperCase().contains(query);

  @override
  bool get canRename => true;

  @override
  bool get isVault => false;
}
