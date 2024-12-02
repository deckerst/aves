import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves_model/aves_model.dart';

class PlaceChipSetActionDelegate extends ChipSetActionDelegate<LocationFilter> {
  final Iterable<FilterGridItem<LocationFilter>> _items;

  PlaceChipSetActionDelegate(Iterable<FilterGridItem<LocationFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<LocationFilter>> get allItems => _items;

  @override
  ChipSortFactor get sortFactor => settings.placeSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.placeSortFactor = factor;

  @override
  bool get sortReverse => settings.placeSortReverse;

  @override
  set sortReverse(bool value) => settings.placeSortReverse = value;

  @override
  TileLayout get tileLayout => settings.getTileLayout(PlaceListPage.routeName);

  @override
  set tileLayout(TileLayout tileLayout) => settings.setTileLayout(PlaceListPage.routeName, tileLayout);
}
