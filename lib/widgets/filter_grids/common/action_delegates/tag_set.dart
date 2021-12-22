import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip_set.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';

class TagChipSetActionDelegate extends ChipSetActionDelegate<TagFilter> {
  final Iterable<FilterGridItem<TagFilter>> _items;

  TagChipSetActionDelegate(Iterable<FilterGridItem<TagFilter>> items) : _items = items;

  @override
  Iterable<FilterGridItem<TagFilter>> get allItems => _items;

  @override
  ChipSortFactor get sortFactor => settings.tagSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.tagSortFactor = factor;

  @override
  TileLayout get tileLayout => settings.getTileLayout(TagListPage.routeName);

  @override
  set tileLayout(TileLayout tileLayout) => settings.setTileLayout(TagListPage.routeName, tileLayout);
}
