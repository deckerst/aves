import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/widgets/collection/empty.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/filter_grids/filter_grid_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagListPage extends StatelessWidget {
  static const routeName = '/tags';

  final CollectionSource source;

  const TagListPage({@required this.source});

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, ChipSortFactor>(
      selector: (context, s) => s.tagSortFactor,
      builder: (context, sortFactor, child) {
        return StreamBuilder(
          stream: source.eventBus.on<TagsChangedEvent>(),
          builder: (context, snapshot) => FilterNavigationPage(
            source: source,
            title: 'Tags',
            onChipActionSelected: _onChipActionSelected,
            filterEntries: _getTagEntries(),
            filterBuilder: (s) => TagFilter(s),
            emptyBuilder: () => EmptyContent(
              icon: AIcons.tag,
              text: 'No tags',
            ),
          ),
        );
      },
    );
  }

  void _onChipActionSelected(BuildContext context, ChipAction action) async {
    switch (action) {
      case ChipAction.sort:
        final factor = await showDialog<ChipSortFactor>(
          context: context,
          builder: (context) => AvesSelectionDialog<ChipSortFactor>(
            initialValue: settings.tagSortFactor,
            options: {
              ChipSortFactor.date: 'By date',
              ChipSortFactor.name: 'By name',
            },
            title: 'Sort',
          ),
        );
        if (factor != null) {
          settings.tagSortFactor = factor;
        }
        break;
    }
  }

  Map<String, ImageEntry> _getTagEntries() {
    final entriesByDate = source.sortedEntriesForFilterList;
    final tags = source.sortedTags
        .map((tag) => MapEntry(
              tag,
              entriesByDate.firstWhere((entry) => entry.xmpSubjects.contains(tag), orElse: () => null),
            ))
        .toList();

    switch (settings.tagSortFactor) {
      case ChipSortFactor.date:
        tags.sort(FilterNavigationPage.compareChipByDate);
        break;
      case ChipSortFactor.name:
    }
    return Map.fromEntries(tags);
  }
}
