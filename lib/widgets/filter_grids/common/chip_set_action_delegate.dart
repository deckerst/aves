import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/aves_selection_dialog.dart';
import 'package:aves/widgets/common/data_providers/media_store_collection_provider.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:aves/widgets/stats/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pedantic/pedantic.dart';

abstract class ChipSetActionDelegate {
  CollectionSource get source;

  ChipSortFactor get sortFactor;

  set sortFactor(ChipSortFactor factor);

  Future<void> onActionSelected(BuildContext context, ChipSetAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(Durations.popupMenuAnimation * timeDilation);

    switch (action) {
      case ChipSetAction.sort:
        await _showSortDialog(context);
        break;
      case ChipSetAction.refresh:
        if (source is MediaStoreSource) {
          source.clearEntries();
          unawaited((source as MediaStoreSource).refresh());
        }
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
          ChipSortFactor.count: 'By entry count',
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
          collection: CollectionLens(
            source: source,
            groupFactor: settings.collectionGroupFactor,
            sortFactor: settings.collectionSortFactor,
          ),
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
