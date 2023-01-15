import 'package:aves/model/actions/map_actions.dart';
import 'package:aves/model/settings/enums/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_selection_dialog.dart';
import 'package:aves_map/aves_map.dart';
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
          builder: (context) => AvesSelectionDialog<EntryMapStyle?>(
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
