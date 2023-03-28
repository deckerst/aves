import 'package:aves/model/settings/enums/l10n.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/single_selection.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MapActionDelegate {
  final AvesMapController? controller;

  const MapActionDelegate(this.controller);

  void onActionSelected(BuildContext context, MapAction action) {
    switch (action) {
      case MapAction.selectStyle:
        showSelectionDialog<EntryMapStyle>(
          context: context,
          builder: (context) => AvesSingleSelectionDialog<EntryMapStyle?>(
            initialValue: settings.mapStyle,
            options: Map.fromEntries(availability.mapStyles.map((v) => MapEntry(v, v.getName(context)))),
            title: context.l10n.mapStyleDialogTitle,
          ),
          onSelection: (v) => settings.mapStyle = v,
        );
        break;
      case MapAction.zoomIn:
        controller?.zoomBy(1);
        break;
      case MapAction.zoomOut:
        controller?.zoomBy(-1);
        break;
    }
  }
}
