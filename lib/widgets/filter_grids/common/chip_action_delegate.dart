import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/filter_grids/common/chip_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ChipActionDelegate {
  Future<void> onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) async {
    // wait for the popup menu to hide before proceeding with the action
    await Future.delayed(Durations.popupMenuAnimation * timeDilation);

    switch (action) {
      case ChipAction.pin:
        final pinnedFilters = settings.pinnedFilters..add(filter);
        settings.pinnedFilters = pinnedFilters;
        break;
      case ChipAction.unpin:
        final pinnedFilters = settings.pinnedFilters..remove(filter);
        settings.pinnedFilters = pinnedFilters;
        break;
      default:
        break;
    }
  }
}

class AlbumChipActionDelegate extends ChipActionDelegate {
  @override
  Future<void> onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) async {
    await super.onActionSelected(context, filter, action);
    switch (action) {
      case ChipAction.rename:
        // TODO TLAD rename album
        break;
      default:
        break;
    }
  }
}
