import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/stats/stats.dart';
import 'package:flutter/material.dart';

abstract class ChipSetActionDelegate {
  CollectionSource get source;

  ChipSortFactor get sortFactor;

  set sortFactor(ChipSortFactor factor);

  void onActionSelected(BuildContext context, ChipSetAction action) {
    switch (action) {
      case ChipSetAction.sort:
        _showSortDialog(context);
        break;
      case ChipSetAction.refresh:
        source.refresh();
        break;
      case ChipSetAction.stats:
        _goToStats(context);
        break;
    }
  }

  Future<void> _showSortDialog(BuildContext context) async {
    final factor = await showDialog<ChipSortFactor>(
      context: context,
      builder: (context) => AvesSelectionDialog<ChipSortFactor>(
        initialValue: sortFactor,
        options: {
          ChipSortFactor.date: 'By date',
          ChipSortFactor.name: 'By name',
          ChipSortFactor.count: 'By item count',
        },
        title: 'Sort',
      ),
    );
    if (factor != null) {
      sortFactor = factor;
    }
  }

  void _goToStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: StatsPage.routeName),
        builder: (context) => StatsPage(
          source: source,
        ),
      ),
    );
  }
}

class AlbumChipSetActionDelegate extends ChipSetActionDelegate {
  @override
  final CollectionSource source;

  AlbumChipSetActionDelegate({
    @required this.source,
  });

  @override
  ChipSortFactor get sortFactor => settings.albumSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.albumSortFactor = factor;
}

class CountryChipSetActionDelegate extends ChipSetActionDelegate {
  @override
  final CollectionSource source;

  CountryChipSetActionDelegate({
    @required this.source,
  });

  @override
  ChipSortFactor get sortFactor => settings.countrySortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.countrySortFactor = factor;
}

class TagChipSetActionDelegate extends ChipSetActionDelegate {
  @override
  final CollectionSource source;

  TagChipSetActionDelegate({
    @required this.source,
  });

  @override
  ChipSortFactor get sortFactor => settings.tagSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.tagSortFactor = factor;
}
