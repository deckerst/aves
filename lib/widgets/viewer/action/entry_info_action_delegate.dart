import 'dart:async';

import 'package:aves/model/actions/entry_info_actions.dart';
import 'package:aves/model/actions/events.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_metadata_edition.dart';
import 'package:aves/model/geotiff.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/entry_editor.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/viewer/action/single_entry_editor.dart';
import 'package:aves/widgets/viewer/debug/debug_page.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EntryInfoActionDelegate with FeedbackMixin, PermissionAwareMixin, EntryEditorMixin, SingleEntryEditorMixin {
  @override
  final AvesEntry entry;
  final CollectionLens? collection;

  final StreamController<ActionEvent<EntryInfoAction>> _eventStreamController = StreamController.broadcast();

  Stream<ActionEvent<EntryInfoAction>> get eventStream => _eventStreamController.stream;

  EntryInfoActionDelegate(this.entry, this.collection);

  bool isVisible(EntryInfoAction action) {
    switch (action) {
      // general
      case EntryInfoAction.editDate:
      case EntryInfoAction.editLocation:
      case EntryInfoAction.editDescription:
      case EntryInfoAction.editRating:
      case EntryInfoAction.editTags:
      case EntryInfoAction.removeMetadata:
        return true;
      // GeoTIFF
      case EntryInfoAction.showGeoTiffOnMap:
        return entry.isGeotiff;
      // motion photo
      case EntryInfoAction.convertMotionPhotoToStillImage:
      case EntryInfoAction.viewMotionPhotoVideo:
        return entry.isMotionPhoto;
      // debug
      case EntryInfoAction.debug:
        return kDebugMode;
    }
  }

  bool canApply(EntryInfoAction action) {
    switch (action) {
      // general
      case EntryInfoAction.editDate:
        return entry.canEditDate;
      case EntryInfoAction.editLocation:
        return entry.canEditLocation;
      case EntryInfoAction.editDescription:
        return entry.canEditDescription;
      case EntryInfoAction.editRating:
        return entry.canEditRating;
      case EntryInfoAction.editTags:
        return entry.canEditTags;
      case EntryInfoAction.removeMetadata:
        return entry.canRemoveMetadata;
      // GeoTIFF
      case EntryInfoAction.showGeoTiffOnMap:
        return true;
      // motion photo
      case EntryInfoAction.convertMotionPhotoToStillImage:
        return entry.canEditXmp;
      case EntryInfoAction.viewMotionPhotoVideo:
        return true;
      // debug
      case EntryInfoAction.debug:
        return true;
    }
  }

  void onActionSelected(BuildContext context, EntryInfoAction action) async {
    _eventStreamController.add(ActionStartedEvent(action));
    switch (action) {
      // general
      case EntryInfoAction.editDate:
        await _editDate(context);
        break;
      case EntryInfoAction.editLocation:
        await _editLocation(context);
        break;
      case EntryInfoAction.editDescription:
        await _editDescription(context);
        break;
      case EntryInfoAction.editRating:
        await _editRating(context);
        break;
      case EntryInfoAction.editTags:
        await _editTags(context);
        break;
      case EntryInfoAction.removeMetadata:
        await _removeMetadata(context);
        break;
      // GeoTIFF
      case EntryInfoAction.showGeoTiffOnMap:
        await _showGeoTiffOnMap(context);
        break;
      // motion photo
      case EntryInfoAction.convertMotionPhotoToStillImage:
        await _convertMotionPhotoToStillImage(context);
        break;
      case EntryInfoAction.viewMotionPhotoVideo:
        OpenEmbeddedDataNotification.motionPhotoVideo().dispatch(context);
        break;
      // debug
      case EntryInfoAction.debug:
        _goToDebug(context);
        break;
    }
    _eventStreamController.add(ActionEndedEvent(action));
  }

  Future<void> _editDate(BuildContext context) async {
    final modifier = await selectDateModifier(context, {entry}, collection);
    if (modifier == null) return;

    await edit(context, () => entry.editDate(modifier));
  }

  Future<void> _editLocation(BuildContext context) async {
    final location = await selectLocation(context, {entry}, collection);
    if (location == null) return;

    await edit(context, () => entry.editLocation(location));
  }

  Future<void> _editDescription(BuildContext context) async {
    final description = await selectDescription(context, {entry});
    if (description == null) return;

    await edit(context, () => entry.editDescription(description));
  }

  Future<void> _editRating(BuildContext context) async {
    final rating = await selectRating(context, {entry});
    if (rating == null) return;

    await edit(context, () => entry.editRating(rating));
  }

  Future<void> _editTags(BuildContext context) async {
    final newTagsByEntry = await selectTags(context, {entry});
    if (newTagsByEntry == null) return;

    final newTags = newTagsByEntry[entry] ?? entry.tags;
    final currentTags = entry.tags;
    if (newTags.length == currentTags.length && newTags.every(currentTags.contains)) return;

    await edit(context, () => entry.editTags(newTags));
  }

  Future<void> _removeMetadata(BuildContext context) async {
    final types = await selectMetadataToRemove(context, {entry});
    if (types == null) return;

    await edit(context, () => entry.removeMetadata(types));
  }

  Future<void> _convertMotionPhotoToStillImage(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AvesDialog(
          content: Text(context.l10n.convertMotionPhotoToStillImageWarningDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.applyButtonLabel),
            ),
          ],
        );
      },
    );
    if (confirmed == null || !confirmed) return;

    await edit(context, entry.removeTrailerVideo);
  }

  Future<void> _showGeoTiffOnMap(BuildContext context) async {
    final info = await metadataFetchService.getGeoTiffInfo(entry);
    if (info == null) return;

    final mappedGeoTiff = MappedGeoTiff(
      info: info,
      entry: entry,
    );
    if (!mappedGeoTiff.canOverlay) return;

    final baseCollection = collection;
    if (baseCollection == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) {
          return MapPage(
            collection: baseCollection.copyWith(
              listenToSource: true,
              fixedSelection: baseCollection.sortedEntries.where((entry) => entry.hasGps).where((entry) => entry != this.entry).toList(),
            ),
            overlayEntry: mappedGeoTiff,
          );
        },
      ),
    );
  }

  void _goToDebug(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: ViewerDebugPage.routeName),
        builder: (context) => ViewerDebugPage(entry: entry),
      ),
    );
  }
}
