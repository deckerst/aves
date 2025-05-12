import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntrySortFactorView on EntrySortFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      EntrySortFactor.date => l10n.sortByDate,
      EntrySortFactor.name => l10n.sortByAlbumFileName,
      EntrySortFactor.rating => l10n.sortByRating,
      EntrySortFactor.size => l10n.sortBySize,
      EntrySortFactor.duration => l10n.sortByDuration,
      EntrySortFactor.path => l10n.sortByPath,
    };
  }

  IconData get icon {
    return switch (this) {
      EntrySortFactor.date => AIcons.date,
      EntrySortFactor.name => AIcons.name,
      EntrySortFactor.rating => AIcons.rating,
      EntrySortFactor.size => AIcons.size,
      EntrySortFactor.duration => AIcons.duration,
      EntrySortFactor.path => AIcons.path,
    };
  }

  String getOrderName(BuildContext context, bool reverse) {
    final l10n = context.l10n;
    return switch (this) {
      EntrySortFactor.date => reverse ? l10n.sortOrderOldestFirst : l10n.sortOrderNewestFirst,
      EntrySortFactor.name => reverse ? l10n.sortOrderZtoA : l10n.sortOrderAtoZ,
      EntrySortFactor.rating => reverse ? l10n.sortOrderLowestFirst : l10n.sortOrderHighestFirst,
      EntrySortFactor.size => reverse ? l10n.sortOrderSmallestFirst : l10n.sortOrderLargestFirst,
      EntrySortFactor.duration => reverse ? l10n.sortOrderShortestFirst : l10n.sortOrderLongestFirst,
      EntrySortFactor.path => reverse ? l10n.sortOrderZtoA : l10n.sortOrderAtoZ,
    };
  }
}

extension ExtraChipSortFactorView on ChipSortFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ChipSortFactor.date => l10n.sortByDate,
      ChipSortFactor.name => l10n.sortByName,
      ChipSortFactor.count => l10n.sortByItemCount,
      ChipSortFactor.size => l10n.sortBySize,
      ChipSortFactor.path => l10n.sortByPath,
    };
  }

  IconData get icon {
    return switch (this) {
      ChipSortFactor.date => AIcons.date,
      ChipSortFactor.name => AIcons.name,
      ChipSortFactor.count => AIcons.count,
      ChipSortFactor.size => AIcons.size,
      ChipSortFactor.path => AIcons.path,
    };
  }

  String getOrderName(BuildContext context, bool reverse) {
    final l10n = context.l10n;
    return switch (this) {
      ChipSortFactor.date => reverse ? l10n.sortOrderOldestFirst : l10n.sortOrderNewestFirst,
      ChipSortFactor.name || ChipSortFactor.path => reverse ? l10n.sortOrderZtoA : l10n.sortOrderAtoZ,
      ChipSortFactor.count || ChipSortFactor.size => reverse ? l10n.sortOrderSmallestFirst : l10n.sortOrderLargestFirst,
    };
  }
}
