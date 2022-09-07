import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/enums/enums.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';

class CountryChipSetActionDelegate extends ChipSetActionDelegate<LocationFilter> {
  final Iterable<FilterGridItem<LocationFilter>> _items;

  CountryChipSetActionDelegate(Iterable<FilterGridItem<LocationFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<LocationFilter>> get allItems => _items;

  @override
  ChipSortFactor get sortFactor => settings.countrySortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.countrySortFactor = factor;

  @override
  bool get sortReverse => settings.countrySortReverse;

  @override
  set sortReverse(bool value) => settings.countrySortReverse = value;

  @override
  TileLayout get tileLayout => settings.getTileLayout(CountryListPage.routeName);

  @override
  set tileLayout(TileLayout tileLayout) => settings.setTileLayout(CountryListPage.routeName, tileLayout);
}
