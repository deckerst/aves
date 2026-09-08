import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEntrySortFactorView on EntrySortFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .date => l10n.sortByDate,
      .name => l10n.sortByAlbumFileName,
      .rating => l10n.sortByRating,
      .size => l10n.sortBySize,
      .duration => l10n.sortByDuration,
      .path => l10n.sortByPath,
    };
  }

  IconData get icon {
    return switch (this) {
      .date => AIcons.date,
      .name => AIcons.name,
      .rating => AIcons.rating,
      .size => AIcons.size,
      .duration => AIcons.duration,
      .path => AIcons.path,
    };
  }

  String getOrderName(BuildContext context, bool reverse) {
    final l10n = context.l10n;
    return switch (this) {
      .date => reverse ? l10n.sortOrderOldestFirst : l10n.sortOrderNewestFirst,
      .name => reverse ? l10n.sortOrderZtoA : l10n.sortOrderAtoZ,
      .rating => reverse ? l10n.sortOrderLowestFirst : l10n.sortOrderHighestFirst,
      .size => reverse ? l10n.sortOrderSmallestFirst : l10n.sortOrderLargestFirst,
      .duration => reverse ? l10n.sortOrderShortestFirst : l10n.sortOrderLongestFirst,
      .path => reverse ? l10n.sortOrderZtoA : l10n.sortOrderAtoZ,
    };
  }
}

extension ExtraChipSortFactorView on ChipSortFactor {
  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .date => l10n.sortByDate,
      .name => l10n.sortByName,
      .count => l10n.sortByItemCount,
      .size => l10n.sortBySize,
      .path => l10n.sortByPath,
    };
  }

  IconData get icon {
    return switch (this) {
      .date => AIcons.date,
      .name => AIcons.name,
      .count => AIcons.count,
      .size => AIcons.size,
      .path => AIcons.path,
    };
  }

  String getOrderName(BuildContext context, bool reverse) {
    final l10n = context.l10n;
    return switch (this) {
      .date => reverse ? l10n.sortOrderOldestFirst : l10n.sortOrderNewestFirst,
      .name || .path => reverse ? l10n.sortOrderZtoA : l10n.sortOrderAtoZ,
      .count || .size => reverse ? l10n.sortOrderSmallestFirst : l10n.sortOrderLargestFirst,
    };
  }
}
