import 'dart:async';
import 'dart:convert';

import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/events.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_info.dart';
import 'package:aves/model/entry_metadata_edition.dart';
import 'package:aves/model/geotiff.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/entry_editor.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/map/map_page.dart';
import 'package:aves/widgets/viewer/action/single_entry_editor.dart';
import 'package:aves/widgets/viewer/embedded/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EntryInfoActionDelegate with FeedbackMixin, PermissionAwareMixin, EntryEditorMixin, SingleEntryEditorMixin {
  final StreamController<ActionEvent<EntryAction>> _eventStreamController = StreamController.broadcast();

  Stream<ActionEvent<EntryAction>> get eventStream => _eventStreamController.stream;

  bool isVisible(AvesEntry targetEntry, EntryAction action) {
    switch (action) {
      // general
      case EntryAction.editDate:
      case EntryAction.editLocation:
      case EntryAction.editTitleDescription:
      case EntryAction.editRating:
      case EntryAction.editTags:
      case EntryAction.removeMetadata:
      case EntryAction.exportMetadata:
        return true;
      // GeoTIFF
      case EntryAction.showGeoTiffOnMap:
        return targetEntry.isGeotiff;
      // motion photo
      case EntryAction.convertMotionPhotoToStillImage:
      case EntryAction.viewMotionPhotoVideo:
        return targetEntry.isMotionPhoto;
      default:
        return false;
    }
  }

  bool canApply(AvesEntry targetEntry, EntryAction action) {
    switch (action) {
      // general
      case EntryAction.editDate:
        return targetEntry.canEditDate;
      case EntryAction.editLocation:
        return targetEntry.canEditLocation;
      case EntryAction.editTitleDescription:
        return targetEntry.canEditTitleDescription;
      case EntryAction.editRating:
        return targetEntry.canEditRating;
      case EntryAction.editTags:
        return targetEntry.canEditTags;
      case EntryAction.removeMetadata:
        return targetEntry.canRemoveMetadata;
      case EntryAction.exportMetadata:
        return true;
      // GeoTIFF
      case EntryAction.showGeoTiffOnMap:
        return true;
      // motion photo
      case EntryAction.convertMotionPhotoToStillImage:
        return targetEntry.canEditXmp;
      case EntryAction.viewMotionPhotoVideo:
        return true;
      default:
        return false;
    }
  }

  void onActionSelected(BuildContext context, AvesEntry targetEntry, CollectionLens? collection, EntryAction action) async {
    _eventStreamController.add(ActionStartedEvent(action));
    switch (action) {
      // general
      case EntryAction.editDate:
        await _editDate(context, targetEntry, collection);
        break;
      case EntryAction.editLocation:
        await _editLocation(context, targetEntry, collection);
        break;
      case EntryAction.editTitleDescription:
        await _editTitleDescription(context, targetEntry);
        break;
      case EntryAction.editRating:
        await _editRating(context, targetEntry);
        break;
      case EntryAction.editTags:
        await _editTags(context, targetEntry);
        break;
      case EntryAction.removeMetadata:
        await _removeMetadata(context, targetEntry);
        break;
      case EntryAction.exportMetadata:
        await _exportMetadata(context, targetEntry);
        break;
      // GeoTIFF
      case EntryAction.showGeoTiffOnMap:
        await _showGeoTiffOnMap(context, targetEntry, collection);
        break;
      // motion photo
      case EntryAction.convertMotionPhotoToStillImage:
        await _convertMotionPhotoToStillImage(context, targetEntry);
        break;
      case EntryAction.viewMotionPhotoVideo:
        OpenEmbeddedDataNotification.motionPhotoVideo().dispatch(context);
        break;
      default:
        break;
    }
    _eventStreamController.add(ActionEndedEvent(action));
  }

  Future<void> _editDate(BuildContext context, AvesEntry targetEntry, CollectionLens? collection) async {
    final modifier = await selectDateModifier(context, {targetEntry}, collection);
    if (modifier == null) return;

    await edit(context, targetEntry, () => targetEntry.editDate(modifier));
  }

  Future<void> _editLocation(BuildContext context, AvesEntry targetEntry, CollectionLens? collection) async {
    final location = await selectLocation(context, {targetEntry}, collection);
    if (location == null) return;

    await edit(context, targetEntry, () => targetEntry.editLocation(location));
  }

  Future<void> _editTitleDescription(BuildContext context, AvesEntry targetEntry) async {
    final modifier = await selectTitleDescriptionModifier(context, {targetEntry});
    if (modifier == null) return;

    await edit(context, targetEntry, () => targetEntry.editTitleDescription(modifier));
  }

  Future<void> _editRating(BuildContext context, AvesEntry targetEntry) async {
    final rating = await selectRating(context, {targetEntry});
    if (rating == null) return;

    await edit(context, targetEntry, () => targetEntry.editRating(rating));
  }

  Future<void> _editTags(BuildContext context, AvesEntry targetEntry) async {
    final newTagsByEntry = await selectTags(context, {targetEntry});
    if (newTagsByEntry == null) return;

    final newTags = newTagsByEntry[targetEntry] ?? targetEntry.tags;
    final currentTags = targetEntry.tags;
    if (newTags.length == currentTags.length && newTags.every(currentTags.contains)) return;

    await edit(context, targetEntry, () => targetEntry.editTags(newTags));
  }

  Future<void> _removeMetadata(BuildContext context, AvesEntry targetEntry) async {
    final types = await selectMetadataToRemove(context, {targetEntry});
    if (types == null) return;

    await edit(context, targetEntry, () => targetEntry.removeMetadata(types));
  }

  Future<void> _exportMetadata(BuildContext context, AvesEntry targetEntry) async {
    final lines = <String>[];
    final padding = ' ' * 2;
    final titledDirectories = await targetEntry.getMetadataDirectories(context);
    titledDirectories.forEach((kv) {
      final title = kv.key;
      final dir = kv.value;

      lines.add('[$title]');
      final dirContent = dir.allTags;
      final tags = dirContent.keys.toList()..sort();
      tags.forEach((tag) {
        final value = dirContent[tag];
        lines.add('$padding$tag: $value');
      });
    });
    final metadataString = lines.join('\n');

    final success = await storageService.createFile(
      '${targetEntry.filenameWithoutExtension}-metadata.txt',
      MimeTypes.plainText,
      Uint8List.fromList(utf8.encode(metadataString)),
    );
    if (success != null) {
      if (success) {
        showFeedback(context, context.l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, context.l10n.genericFailureFeedback);
      }
    }
  }

  Future<void> _convertMotionPhotoToStillImage(BuildContext context, AvesEntry targetEntry) async {
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

    await edit(context, targetEntry, targetEntry.removeTrailerVideo);
  }

  Future<void> _showGeoTiffOnMap(BuildContext context, AvesEntry targetEntry, CollectionLens? collection) async {
    final info = await metadataFetchService.getGeoTiffInfo(targetEntry);
    if (info == null) return;

    final mappedGeoTiff = MappedGeoTiff(
      info: info,
      entry: targetEntry,
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
              fixedSelection: baseCollection.sortedEntries.where((entry) => entry.hasGps).where((entry) => entry != targetEntry).toList(),
            ),
            overlayEntry: mappedGeoTiff,
          );
        },
      ),
    );
  }
}
