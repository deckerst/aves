import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntrySortFactorView on EntrySortFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case EntrySortFactor.date:
        return l10n.sortByDate;
      case EntrySortFactor.name:
        return l10n.sortByAlbumFileName;
      case EntrySortFactor.rating:
        return l10n.sortByRating;
      case EntrySortFactor.size:
        return l10n.sortBySize;
    }
  }

  IconData get icon {
    switch (this) {
      case EntrySortFactor.date:
        return AIcons.date;
      case EntrySortFactor.name:
        return AIcons.name;
      case EntrySortFactor.rating:
        return AIcons.rating;
      case EntrySortFactor.size:
        return AIcons.size;
    }
  }

  String getOrderName(BuildContext context, bool reverse) {
    final l10n = context.l10n;
    switch (this) {
      case EntrySortFactor.date:
        return reverse ? l10n.sortOrderOldestFirst : l10n.sortOrderNewestFirst;
      case EntrySortFactor.name:
        return reverse ? l10n.sortOrderZtoA : l10n.sortOrderAtoZ;
      case EntrySortFactor.rating:
        return reverse ? l10n.sortOrderLowestFirst : l10n.sortOrderHighestFirst;
      case EntrySortFactor.size:
        return reverse ? l10n.sortOrderSmallestFirst : l10n.sortOrderLargestFirst;
    }
  }
}

extension ExtraChipSortFactorView on ChipSortFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case ChipSortFactor.date:
        return l10n.sortByDate;
      case ChipSortFactor.name:
        return l10n.sortByName;
      case ChipSortFactor.count:
        return l10n.sortByItemCount;
      case ChipSortFactor.size:
        return l10n.sortBySize;
    }
  }

  IconData get icon {
    switch (this) {
      case ChipSortFactor.date:
        return AIcons.date;
      case ChipSortFactor.name:
        return AIcons.name;
      case ChipSortFactor.count:
        return AIcons.count;
      case ChipSortFactor.size:
        return AIcons.size;
    }
  }

  String getOrderName(BuildContext context, bool reverse) {
    final l10n = context.l10n;
    switch (this) {
      case ChipSortFactor.date:
        return reverse ? l10n.sortOrderOldestFirst : l10n.sortOrderNewestFirst;
      case ChipSortFactor.name:
        return reverse ? l10n.sortOrderZtoA : l10n.sortOrderAtoZ;
      case ChipSortFactor.count:
      case ChipSortFactor.size:
        return reverse ? l10n.sortOrderSmallestFirst : l10n.sortOrderLargestFirst;
    }
  }
}
