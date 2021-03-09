import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FavouriteFilter extends CollectionFilter {
  static const type = 'favourite';

  const FavouriteFilter();

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
      };

  @override
  EntryFilter get test => (entry) => entry.isFavourite;

  @override
  String get universalLabel => type;

  @override
  String getLabel(BuildContext context) => context.l10n.filterFavouriteLabel;

  @override
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true, bool embossed = false}) => Icon(AIcons.favourite, size: size);

  @override
  Future<Color> color(BuildContext context) => SynchronousFuture(Colors.red);

  @override
  String get category => type;

  @override
  String get key => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FavouriteFilter;
  }

  @override
  int get hashCode => type.hashCode;
}
