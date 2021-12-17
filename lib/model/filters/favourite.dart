import 'package:aves/model/filters/filters.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FavouriteFilter extends CollectionFilter {
  static const type = 'favourite';

  static const instance = FavouriteFilter._private();

  @override
  List<Object?> get props => [];

  const FavouriteFilter._private();

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
  Widget iconBuilder(BuildContext context, double size, {bool showGenericIcon = true}) => Icon(AIcons.favourite, size: size);

  @override
  Future<Color> color(BuildContext context) => SynchronousFuture(Colors.red);

  @override
  String get category => type;

  @override
  String get key => type;
}
