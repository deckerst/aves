import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class FavouriteFilter extends CollectionFilter {
  static const type = 'favourite';

  @override
  bool filter(ImageEntry entry) => entry.isFavourite;

  @override
  String get label => 'Favourite';

  @override
  Widget iconBuilder(context, size) => Icon(OMIcons.favoriteBorder, size: size);

  @override
  String get typeKey => type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FavouriteFilter;
  }

  @override
  int get hashCode => 'FavouriteFilter'.hashCode;
}
