import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FavouriteFilter extends CollectionFilter {
  static const type = 'favourite';

  static bool _test(AvesEntry entry) => entry.isFavourite;

  static const instance = FavouriteFilter._private();
  static const instanceReversed = FavouriteFilter._private(reversed: true);

  @override
  List<Object?> get props => [reversed];

  const FavouriteFilter._private({super.reversed = false});

  factory FavouriteFilter.fromMap(Map<String, dynamic> json) {
    final reversed = json['reversed'] ?? false;
    return reversed ? instanceReversed : instance;
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'reversed': reversed,
      };

  @override
  EntryFilter get positiveTest => _test;

  @override
  bool get exclusiveProp => false;

  @override
  String get universalLabel => type;

  @override
  String getLabel(BuildContext context) => context.l10n.filterFavouriteLabel;

  @override
  Widget? iconBuilder(BuildContext context, double size, {bool allowGenericIcon = true}) => Icon(AIcons.favourite, size: size);

  @override
  Future<Color> color(BuildContext context) {
    final colors = context.read<AvesColorsData>();
    return SynchronousFuture(colors.favourite);
  }

  @override
  String get category => type;

  @override
  String get key => '$type-$reversed';
}
