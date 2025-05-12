import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/states_page.dart';
import 'package:aves_model/aves_model.dart';

class StateChipSetActionDelegate extends ChipSetActionDelegate<LocationFilter> {
  final Iterable<FilterGridItem<LocationFilter>> _items;

  StateChipSetActionDelegate(Iterable<FilterGridItem<LocationFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<LocationFilter>> get allItems => _items;

  @override
  ChipSortFactor get sortFactor => settings.stateSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.stateSortFactor = factor;

  @override
  bool get sortReverse => settings.stateSortReverse;

  @override
  set sortReverse(bool value) => settings.stateSortReverse = value;

  @override
  TileLayout get tileLayout => settings.getTileLayout(StateListPage.routeName);

  @override
  set tileLayout(TileLayout tileLayout) => settings.setTileLayout(StateListPage.routeName, tileLayout);
}
