import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

extension ExtraEntrySortFactor on EntrySortFactor {
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

extension ExtraChipSortFactor on ChipSortFactor {
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

extension ExtraEntryGroupFactor on EntryGroupFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case EntryGroupFactor.album:
        return l10n.collectionGroupAlbum;
      case EntryGroupFactor.month:
        return l10n.collectionGroupMonth;
      case EntryGroupFactor.day:
        return l10n.collectionGroupDay;
      case EntryGroupFactor.none:
        return l10n.collectionGroupNone;
    }
  }
}

extension ExtraAlbumChipGroupFactor on AlbumChipGroupFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case AlbumChipGroupFactor.importance:
        return l10n.albumGroupTier;
      case AlbumChipGroupFactor.volume:
        return l10n.albumGroupVolume;
      case AlbumChipGroupFactor.none:
        return l10n.albumGroupNone;
    }
  }
}

extension ExtraTileLayout on TileLayout {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case TileLayout.grid:
        return l10n.tileLayoutGrid;
      case TileLayout.list:
        return l10n.tileLayoutList;
    }
  }
}
