import 'dart:async';
import 'dart:convert';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/info.dart';
import 'package:aves/model/entry/extensions/metadata_edition.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/media/geotiff.dart';
import 'package:aves/model/settings/settings.dart';
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
import 'package:aves/widgets/viewer/debug/debug_page.dart';
import 'package:aves/widgets/viewer/info/embedded/notifications.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EntryInfoActionDelegate with FeedbackMixin, PermissionAwareMixin, EntryEditorMixin, SingleEntryEditorMixin {
  final StreamController<ActionEvent<EntryAction>> _eventStreamController = StreamController.broadcast();

  Stream<ActionEvent<EntryAction>> get eventStream => _eventStreamController.stream;

  bool isVisible({
    required AppMode appMode,
    required AvesEntry targetEntry,
    required EntryAction action,
  }) {
    final canWrite = appMode.canEditEntry && !settings.isReadOnly;
    switch (action) {
      // general
      case EntryAction.editDate:
      case EntryAction.editLocation:
      case EntryAction.editTitleDescription:
      case EntryAction.editRating:
      case EntryAction.editTags:
      case EntryAction.removeMetadata:
        return canWrite;
      case EntryAction.exportMetadata:
        return true;
      // GeoTIFF
      case EntryAction.showGeoTiffOnMap:
        return appMode.canNavigate && targetEntry.isGeotiff;
      // motion photo
      case EntryAction.convertMotionPhotoToStillImage:
        return canWrite && targetEntry.isMotionPhoto;
      case EntryAction.viewMotionPhotoVideo:
        return appMode.canNavigate && targetEntry.isMotionPhoto;
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

  Future<void> onActionSelected(BuildContext context, AvesEntry targetEntry, CollectionLens? collection, EntryAction action) async {
    await reportService.log('$action');
    _eventStreamController.add(ActionStartedEvent(action));
    switch (action) {
      // general
      case EntryAction.editDate:
        await _editDate(context, targetEntry, collection);
      case EntryAction.editLocation:
        await _editLocation(context, targetEntry, collection);
      case EntryAction.editTitleDescription:
        await _editTitleDescription(context, targetEntry);
      case EntryAction.editRating:
        await _editRating(context, targetEntry);
      case EntryAction.editTags:
        await _editTags(context, targetEntry);
      case EntryAction.removeMetadata:
        await _removeMetadata(context, targetEntry);
      case EntryAction.exportMetadata:
        await _exportMetadata(context, targetEntry);
      // GeoTIFF
      case EntryAction.showGeoTiffOnMap:
        await _showGeoTiffOnMap(context, targetEntry, collection);
      // motion photo
      case EntryAction.convertMotionPhotoToStillImage:
        await _convertMotionPhotoToStillImage(context, targetEntry);
      case EntryAction.viewMotionPhotoVideo:
        OpenEmbeddedDataNotification.motionPhotoVideo().dispatch(context);
      // debug
      case EntryAction.debug:
        _goToDebug(context, targetEntry);
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

    await quickRate(context, targetEntry, rating);
  }

  Future<void> quickRate(BuildContext context, AvesEntry targetEntry, int rating) async {
    if (targetEntry.rating == rating) return;

    await edit(context, targetEntry, () => targetEntry.editRating(rating));
  }

  Future<void> _editTags(BuildContext context, AvesEntry targetEntry) async {
    final tagsByEntry = await selectTags(context, {targetEntry});
    if (tagsByEntry == null) return;

    final newTags = tagsByEntry[targetEntry] ?? targetEntry.tags;
    await _applyTags(context, targetEntry, newTags);
  }

  Future<void> quickTag(BuildContext context, AvesEntry targetEntry, CollectionFilter filter) async {
    final newTags = {
      ...targetEntry.tags,
      ...await getTagsFromFilters({filter}, targetEntry),
    };
    await _applyTags(context, targetEntry, newTags);
  }

  Future<void> _applyTags(BuildContext context, AvesEntry targetEntry, Set<String> newTags) async {
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
        showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
      }
    }
  }

  Future<void> _convertMotionPhotoToStillImage(BuildContext context, AvesEntry targetEntry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AvesDialog(
        content: Text(context.l10n.genericDangerWarningDialogMessage),
        actions: [
          const CancelButton(),
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(true),
            child: Text(context.l10n.applyButtonLabel),
          ),
        ],
      ),
      routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
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
      devicePixelRatio: View.of(context).devicePixelRatio,
    );
    if (!mappedGeoTiff.canOverlay) return;

    final baseCollection = collection;
    if (baseCollection == null) return;

    final mapCollection = baseCollection.copyWith(
      listenToSource: true,
      fixedSelection: baseCollection.sortedEntries.where((entry) => entry.hasGps).where((entry) => entry != targetEntry).toList(),
    );
    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: MapPage.routeName),
        builder: (context) => MapPage(
          collection: mapCollection,
          overlayEntry: mappedGeoTiff,
        ),
      ),
    );
  }

  void _goToDebug(BuildContext context, AvesEntry targetEntry) {
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: ViewerDebugPage.routeName),
        builder: (context) => ViewerDebugPage(entry: targetEntry),
      ),
    );
  }
}
