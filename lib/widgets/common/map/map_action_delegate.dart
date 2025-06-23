import 'package:aves/geo/uri.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/map/style_selection_dialog.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapActionDelegate with FeedbackMixin {
  final AvesMapController controller;

  const MapActionDelegate(this.controller);

  bool isVisible(BuildContext context, MapAction action) {
    switch (action) {
      case MapAction.selectStyle:
      case MapAction.openMapApp:
      case MapAction.zoomIn:
      case MapAction.zoomOut:
        return true;
      case MapAction.addShortcut:
        return device.canPinShortcut && context.currentRouteName == MapPage.routeName;
    }
  }

  void onActionSelected(BuildContext context, MapAction action) {
    switch (action) {
      case MapAction.selectStyle:
        selectStyle(context);
      case MapAction.openMapApp:
        OpenMapAppNotification().dispatch(context);
      case MapAction.zoomIn:
        controller.zoomBy(1);
      case MapAction.zoomOut:
        controller.zoomBy(-1);
      case MapAction.addShortcut:
        _addShortcut(context);
    }
  }

  static void selectStyle(BuildContext context) {
    Navigator.maybeOf(context)?.push<EntryMapStyle>(
      MaterialPageRoute(
        settings: const RouteSettings(name: MapStyleSelectionDialog.routeName),
        builder: (context) => const MapStyleSelectionDialog(),
      ),
    );
  }

  Future<void> _addShortcut(BuildContext context) async {
    final idleBounds = controller.idleBounds;
    if (idleBounds == null) {
      showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
      return;
    }

    final collection = context.read<CollectionLens>();
    final result = await showDialog<(AvesEntry?, String)>(
      context: context,
      builder: (context) => AddShortcutDialog(
        defaultName: '',
        collection: collection,
      ),
      routeSettings: const RouteSettings(name: AddShortcutDialog.routeName),
    );
    if (result == null) return;

    final (coverEntry, name) = result;
    if (name.isEmpty) return;

    final geoUri = toGeoUri(idleBounds.projectedCenter, zoom: idleBounds.zoom);
    await appService.pinToHomeScreen(
      name,
      coverEntry,
      route: MapPage.routeName,
      filters: collection.filters,
      geoUri: geoUri,
    );
    if (!device.showPinShortcutFeedback) {
      showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
    }
  }
}

class OpenMapAppNotification extends Notification {}
