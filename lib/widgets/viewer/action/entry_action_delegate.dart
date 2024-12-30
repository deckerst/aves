import 'dart:async';
import 'dart:convert';

import 'package:aves/app_mode.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/favourites.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/entry/extensions/metadata_edition.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/media_edit_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/entry_storage.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/convert_entry_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/rename_entry_dialog.dart';
import 'package:aves/widgets/viewer/action/entry_info_action_delegate.dart';
import 'package:aves/widgets/viewer/action/printer.dart';
import 'package:aves/widgets/viewer/action/single_entry_editor.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/debug/debug_page.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class EntryActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin, SingleEntryEditorMixin, EntryStorageMixin, VaultAwareMixin {
  final AvesEntry mainEntry, pageEntry;
  final CollectionLens? collection;
  final EntryInfoActionDelegate _metadataActionDelegate = EntryInfoActionDelegate();

  EntryActionDelegate(this.mainEntry, this.pageEntry, this.collection);

  bool isVisible({
    required AppMode appMode,
    required EntryAction action,
  }) {
    if (mainEntry.trashed) {
      switch (action) {
        case EntryAction.delete:
        case EntryAction.restore:
          return true;
        case EntryAction.debug:
          return kDebugMode;
        default:
          return false;
      }
    } else {
      final targetEntry = EntryActions.pageActions.contains(action) ? pageEntry : mainEntry;
      final canWrite = appMode.canEditEntry && !settings.isReadOnly;
      switch (action) {
        case EntryAction.toggleFavourite:
          return collection != null;
        case EntryAction.delete:
        case EntryAction.rename:
        case EntryAction.move:
          return targetEntry.canEdit;
        case EntryAction.copy:
          return canWrite;
        case EntryAction.rotateCCW:
        case EntryAction.rotateCW:
          return targetEntry.canRotate;
        case EntryAction.flip:
          return targetEntry.canFlip;
        case EntryAction.convert:
          return canWrite && !targetEntry.isPureVideo;
        case EntryAction.print:
          return !targetEntry.isPureVideo;
        case EntryAction.openMap:
          return !settings.useTvLayout && targetEntry.hasGps;
        case EntryAction.viewSource:
          return targetEntry.isSvg;
        case EntryAction.videoCaptureFrame:
          return canWrite && targetEntry.isPureVideo;
        case EntryAction.lockViewer:
        case EntryAction.videoToggleMute:
          return !settings.useTvLayout && targetEntry.isPureVideo;
        case EntryAction.videoSelectStreams:
        case EntryAction.videoSetSpeed:
        case EntryAction.videoABRepeat:
        case EntryAction.videoSettings:
        case EntryAction.videoTogglePlay:
        case EntryAction.videoReplay10:
        case EntryAction.videoSkip10:
        case EntryAction.videoShowPreviousFrame:
        case EntryAction.videoShowNextFrame:
        case EntryAction.openVideoPlayer:
          return targetEntry.isPureVideo;
        case EntryAction.rotateScreen:
          return !settings.useTvLayout && settings.isRotationLocked;
        case EntryAction.addShortcut:
          return device.canPinShortcut;
        case EntryAction.edit:
          return canWrite;
        case EntryAction.copyToClipboard:
        case EntryAction.open:
        case EntryAction.setAs:
        case EntryAction.cast:
          return !settings.useTvLayout;
        case EntryAction.info:
        case EntryAction.share:
          return true;
        case EntryAction.restore:
          return false;
        case EntryAction.editDate:
        case EntryAction.editLocation:
        case EntryAction.editTitleDescription:
        case EntryAction.editRating:
        case EntryAction.editTags:
        case EntryAction.removeMetadata:
        case EntryAction.exportMetadata:
        case EntryAction.showGeoTiffOnMap:
        case EntryAction.convertMotionPhotoToStillImage:
        case EntryAction.viewMotionPhotoVideo:
          return _metadataActionDelegate.isVisible(
            appMode: appMode,
            targetEntry: targetEntry,
            action: action,
          );
        case EntryAction.debug:
          return kDebugMode;
      }
    }
  }

  bool canApply(EntryAction action) {
    final targetEntry = EntryActions.pageActions.contains(action) ? pageEntry : mainEntry;
    switch (action) {
      case EntryAction.rotateCCW:
      case EntryAction.rotateCW:
        return targetEntry.canRotate;
      case EntryAction.flip:
        return targetEntry.canFlip;
      case EntryAction.editDate:
      case EntryAction.editLocation:
      case EntryAction.editTitleDescription:
      case EntryAction.editRating:
      case EntryAction.editTags:
      case EntryAction.removeMetadata:
      case EntryAction.exportMetadata:
      case EntryAction.showGeoTiffOnMap:
      case EntryAction.convertMotionPhotoToStillImage:
      case EntryAction.viewMotionPhotoVideo:
        return _metadataActionDelegate.canApply(targetEntry, action);
      case EntryAction.convert:
      case EntryAction.copy:
      case EntryAction.move:
        return !availability.isLocked;
      default:
        return true;
    }
  }

  AvesEntry _getTargetEntry(BuildContext context, EntryAction action) {
    if (mainEntry.isMultiPage && (mainEntry.isStack || EntryActions.pageActions.contains(action))) {
      final multiPageController = context.read<MultiPageConductor>().getController(mainEntry);
      if (multiPageController != null) {
        final multiPageInfo = multiPageController.info;
        final pageEntry = multiPageInfo?.getPageEntryByIndex(multiPageController.page);
        if (pageEntry != null) {
          return pageEntry;
        }
      }
    }
    return mainEntry;
  }

  void onActionSelected(BuildContext context, EntryAction action) {
    reportService.log('$runtimeType handles $action');
    final targetEntry = _getTargetEntry(context, action);

    switch (action) {
      case EntryAction.info:
        ShowInfoPageNotification().dispatch(context);
      case EntryAction.addShortcut:
        _addShortcut(context, targetEntry);
      case EntryAction.copyToClipboard:
        appService.copyToClipboard(targetEntry.uri, targetEntry.bestTitle).then((success) {
          if (success) {
            showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
          } else {
            showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
          }
        });
      case EntryAction.delete:
        _delete(context, targetEntry);
      case EntryAction.restore:
        _move(context, targetEntry, moveType: MoveType.fromBin);
      case EntryAction.convert:
        _convert(context, targetEntry);
      case EntryAction.print:
        EntryPrinter(targetEntry).print(context);
      case EntryAction.rename:
        _rename(context, targetEntry);
      case EntryAction.copy:
        _move(context, targetEntry, moveType: MoveType.copy);
      case EntryAction.move:
        _move(context, targetEntry, moveType: MoveType.move);
      case EntryAction.share:
        appService.shareEntries({targetEntry}).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
      case EntryAction.toggleFavourite:
        targetEntry.toggleFavourite();
      // raster
      case EntryAction.rotateCCW:
        _rotate(context, targetEntry, clockwise: false);
      case EntryAction.rotateCW:
        _rotate(context, targetEntry, clockwise: true);
      case EntryAction.flip:
        _flip(context, targetEntry);
      // vector
      case EntryAction.viewSource:
        _goToSourceViewer(context, targetEntry);
      case EntryAction.lockViewer:
        const LockViewNotification(locked: true).dispatch(context);
      // video
      case EntryAction.videoCaptureFrame:
      case EntryAction.videoToggleMute:
      case EntryAction.videoSelectStreams:
      case EntryAction.videoSetSpeed:
      case EntryAction.videoABRepeat:
      case EntryAction.videoSettings:
      case EntryAction.videoTogglePlay:
      case EntryAction.videoReplay10:
      case EntryAction.videoSkip10:
      case EntryAction.videoShowPreviousFrame:
      case EntryAction.videoShowNextFrame:
      case EntryAction.openVideoPlayer:
        final controller = context.read<VideoConductor>().getController(targetEntry);
        if (controller != null) {
          VideoActionNotification(
            controller: controller,
            entry: targetEntry,
            action: action,
          ).dispatch(context);
        }
      case EntryAction.edit:
        appService.edit(targetEntry.uri, targetEntry.mimeType).then((fields) async {
          final error = fields['error'] as String?;
          if (error == null) {
            final resultUri = fields['uri'] as String?;
            final mimeType = fields['mimeType'] as String?;
            await _handleEditResult(context, resultUri, mimeType);
          } else if (error == 'edit-resolve') {
            await showNoMatchingAppDialog(context);
          }
        });
      case EntryAction.open:
        appService.open(targetEntry.uri, targetEntry.mimeTypeAnySubtype, forceChooser: true).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
      case EntryAction.openMap:
        appService.openMap(targetEntry.latLng!).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
      case EntryAction.setAs:
        appService.setAs(targetEntry.uri, targetEntry.mimeType).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
      case EntryAction.cast:
        const CastNotification(true).dispatch(context);
      // platform
      case EntryAction.rotateScreen:
        _rotateScreen(context);
      // metadata
      case EntryAction.editDate:
      case EntryAction.editLocation:
      case EntryAction.editTitleDescription:
      case EntryAction.editRating:
      case EntryAction.editTags:
      case EntryAction.removeMetadata:
      case EntryAction.exportMetadata:
      case EntryAction.showGeoTiffOnMap:
      case EntryAction.convertMotionPhotoToStillImage:
      case EntryAction.viewMotionPhotoVideo:
        _metadataActionDelegate.onActionSelected(context, targetEntry, collection, action);
      // debug
      case EntryAction.debug:
        _goToDebug(context, targetEntry);
    }
  }

  Future<void> _handleEditResult(BuildContext context, String? resultUri, String? mimeType) async {
    final _collection = collection;
    if (_collection == null || resultUri == null) return;

    final editedEntry = await mediaFetchService.getEntry(resultUri, mimeType);
    if (editedEntry == null) return;

    final editedUri = editedEntry.uri;
    final matchCurrentFilters = _collection.filters.every((filter) => filter.test(editedEntry));

    final l10n = context.l10n;
    // get navigator beforehand because
    // local context may be deactivated when action is triggered after navigation
    final navigator = Navigator.maybeOf(context);
    final showAction = SnackBarAction(
      label: l10n.showButtonLabel,
      onPressed: () {
        if (navigator != null) {
          final source = _collection.source;
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              settings: const RouteSettings(name: CollectionPage.routeName),
              builder: (context) => CollectionPage(
                source: source,
                filters: matchCurrentFilters ? _collection.filters : {},
                highlightTest: (entry) => entry.uri == editedUri,
              ),
            ),
            (route) => false,
          );
        }
      },
    );
    showFeedback(context, FeedbackType.info, l10n.genericSuccessFeedback, showAction);
  }

  Future<void> quickMove(BuildContext context, String album, {required bool copy}) async {
    if (!await unlockAlbum(context, album)) return;

    final targetEntry = _getTargetEntry(context, copy ? EntryAction.copy : EntryAction.move);
    if (!copy && targetEntry.directory == album) return;

    await doQuickMove(
      context,
      moveType: copy ? MoveType.copy : MoveType.move,
      entriesByDestination: {
        album: {targetEntry}
      },
    );
  }

  Future<void> quickShare(BuildContext context, ShareAction action) async {
    switch (action) {
      case ShareAction.imageOnly:
        if (mainEntry.isMotionPhoto) {
          final fields = await embeddedDataService.extractMotionPhotoImage(mainEntry);
          await _shareMotionPhotoPart(context, fields);
        }
      case ShareAction.videoOnly:
        if (mainEntry.isMotionPhoto) {
          final fields = await embeddedDataService.extractMotionPhotoVideo(mainEntry);
          await _shareMotionPhotoPart(context, fields);
        }
    }
  }

  Future<void> _shareMotionPhotoPart(BuildContext context, Map fields) async {
    final uri = fields['uri'] as String?;
    final mimeType = fields['mimeType'] as String?;
    if (uri != null && mimeType != null) {
      await appService.shareSingle(uri, mimeType).then((success) {
        if (!success) showNoMatchingAppDialog(context);
      });
    }
  }

  void quickRate(BuildContext context, int rating) {
    final targetEntry = _getTargetEntry(context, EntryAction.editRating);
    _metadataActionDelegate.quickRate(context, targetEntry, rating);
  }

  void quickTag(BuildContext context, CollectionFilter filter) {
    final targetEntry = _getTargetEntry(context, EntryAction.editTags);
    _metadataActionDelegate.quickTag(context, targetEntry, filter);
  }

  Future<void> _addShortcut(BuildContext context, AvesEntry targetEntry) async {
    final result = await showDialog<(AvesEntry?, String)>(
      context: context,
      builder: (context) => AddShortcutDialog(
        defaultName: targetEntry.bestTitle ?? '',
      ),
      routeSettings: const RouteSettings(name: AddShortcutDialog.routeName),
    );
    if (result == null) return;

    final name = result.$2;
    if (name.isEmpty) return;

    await appService.pinToHomeScreen(name, targetEntry, route: EntryViewerPage.routeName, viewUri: targetEntry.uri);
    if (!device.showPinShortcutFeedback) {
      showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
    }
  }

  Future<void> _flip(BuildContext context, AvesEntry targetEntry) async {
    await edit(context, targetEntry, targetEntry.flip);
  }

  Future<void> _rotate(BuildContext context, AvesEntry targetEntry, {required bool clockwise}) async {
    await edit(context, targetEntry, () => targetEntry.rotate(clockwise: clockwise));
  }

  Future<void> _rotateScreen(BuildContext context) async {
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    await windowService.requestOrientation(isPortrait ? Orientation.landscape : Orientation.portrait);
  }

  Future<void> _delete(BuildContext context, AvesEntry targetEntry) async {
    final vault = vaults.getVault(targetEntry.directory);
    final enableBin = vault?.useBin ?? settings.enableBin;

    if (enableBin && !targetEntry.trashed) {
      await _move(context, targetEntry, moveType: MoveType.toBin);
      return;
    }

    final l10n = context.l10n;
    if (!await showSkippableConfirmationDialog(
      context: context,
      type: ConfirmationDialog.deleteForever,
      message: l10n.deleteEntriesConfirmationDialogMessage(1),
      confirmationButtonLabel: l10n.deleteButtonLabel,
    )) {
      return;
    }

    if (!await checkStoragePermission(context, {targetEntry})) return;

    if (!await targetEntry.delete()) {
      showFeedback(context, FeedbackType.warn, l10n.genericFailureFeedback);
    } else {
      final source = context.read<CollectionSource>();
      await source.removeEntries({targetEntry.uri}, includeTrash: true);
      EntryDeletedNotification({targetEntry}).dispatch(context);
    }
  }

  Future<void> _move(BuildContext context, AvesEntry targetEntry, {required MoveType moveType}) => doMove(
        context,
        moveType: moveType,
        entries: {targetEntry},
      );

  Future<void> _convert(BuildContext context, AvesEntry targetEntry) async {
    final options = await showDialog<EntryConvertOptions>(
      context: context,
      builder: (context) => ConvertEntryDialog(entries: {targetEntry}),
      routeSettings: const RouteSettings(name: ConvertEntryDialog.routeName),
    );
    if (options == null) return;

    switch (options.action) {
      case EntryConvertAction.convert:
        await doExport(context, {targetEntry}, options);
      case EntryConvertAction.convertMotionPhotoToStillImage:
        await _metadataActionDelegate.onActionSelected(context, targetEntry, collection, EntryAction.convertMotionPhotoToStillImage);
    }
  }

  Future<void> _rename(BuildContext context, AvesEntry targetEntry) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameEntryDialog(entry: targetEntry),
      routeSettings: const RouteSettings(name: RenameEntryDialog.routeName),
    );
    if (newName == null || newName.isEmpty || newName == targetEntry.filenameWithoutExtension) return;

    // wait for the dialog to hide
    await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);
    await rename(
      context,
      entriesToNewName: {targetEntry: '$newName${targetEntry.extension}'},
      persist: _isMainMode(context),
      onSuccess: targetEntry.metadataChangeNotifier.notify,
    );
  }

  bool _isMainMode(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.main;

  void _goToSourceViewer(BuildContext context, AvesEntry targetEntry) {
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: SourceViewerPage.routeName),
        builder: (context) => SourceViewerPage(
          loader: () async {
            final data = await mediaFetchService.getSvg(
              targetEntry.uri,
              targetEntry.mimeType,
              sizeBytes: targetEntry.sizeBytes,
            );
            return utf8.decode(data);
          },
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
