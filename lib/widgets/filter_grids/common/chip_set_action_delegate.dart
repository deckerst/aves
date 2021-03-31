import 'package:aves/model/actions/chip_actions.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves/widgets/stats/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

abstract class ChipSetActionDelegate {
  ChipSortFactor get sortFactor;

  set sortFactor(ChipSortFactor factor);

  void onActionSelected(BuildContext context, ChipSetAction action) {
    switch (action) {
      case ChipSetAction.sort:
        _showSortDialog(context);
        break;
      case ChipSetAction.stats:
        _goToStats(context);
        break;
      default:
        break;
    }
  }

  Future<void> _showSortDialog(BuildContext context) async {
    final factor = await showDialog<ChipSortFactor>(
      context: context,
      builder: (context) => AvesSelectionDialog<ChipSortFactor>(
        initialValue: sortFactor,
        options: {
          ChipSortFactor.date: context.l10n.chipSortDate,
          ChipSortFactor.name: context.l10n.chipSortName,
          ChipSortFactor.count: context.l10n.chipSortCount,
        },
        title: context.l10n.chipSortTitle,
      ),
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    if (factor != null) {
      sortFactor = factor;
    }
  }

  void _goToStats(BuildContext context) {
    final source = context.read<CollectionSource>();
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
  ChipSortFactor get sortFactor => settings.albumSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.albumSortFactor = factor;

  @override
  void onActionSelected(BuildContext context, ChipSetAction action) {
    switch (action) {
      case ChipSetAction.group:
        _showGroupDialog(context);
        break;
      default:
        break;
    }
    super.onActionSelected(context, action);
  }

  Future<void> _showGroupDialog(BuildContext context) async {
    final factor = await showDialog<AlbumChipGroupFactor>(
      context: context,
      builder: (context) => AvesSelectionDialog<AlbumChipGroupFactor>(
        initialValue: settings.albumGroupFactor,
        options: {
          AlbumChipGroupFactor.importance: context.l10n.albumGroupTier,
          AlbumChipGroupFactor.volume: context.l10n.albumGroupVolume,
          AlbumChipGroupFactor.none: context.l10n.albumGroupNone,
        },
        title: context.l10n.albumGroupTitle,
      ),
    );
    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    if (factor != null) {
      settings.albumGroupFactor = factor;
    }
  }
}

class CountryChipSetActionDelegate extends ChipSetActionDelegate {
  @override
  ChipSortFactor get sortFactor => settings.countrySortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.countrySortFactor = factor;
}

class TagChipSetActionDelegate extends ChipSetActionDelegate {
  @override
  ChipSortFactor get sortFactor => settings.tagSortFactor;

  @override
  set sortFactor(ChipSortFactor factor) => settings.tagSortFactor = factor;
}
