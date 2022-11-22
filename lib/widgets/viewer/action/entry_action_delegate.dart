import 'dart:async';
import 'dart:convert';

import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/move_type.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_metadata_edition.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/image_op_events.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/services/media/media_edit_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/entry_storage.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/entry_editors/rename_entry_dialog.dart';
import 'package:aves/widgets/dialogs/export_entry_dialog.dart';
import 'package:aves/widgets/filter_grids/album_pick.dart';
import 'package:aves/widgets/viewer/action/entry_info_action_delegate.dart';
import 'package:aves/widgets/viewer/action/printer.dart';
import 'package:aves/widgets/viewer/action/single_entry_editor.dart';
import 'package:aves/widgets/viewer/debug/debug_page.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/notifications.dart';
import 'package:aves/widgets/viewer/source_viewer_page.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class EntryActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin, SingleEntryEditorMixin, EntryStorageMixin {
  final AvesEntry mainEntry, pageEntry;
  final CollectionLens? collection;
  final EntryInfoActionDelegate _metadataActionDelegate = EntryInfoActionDelegate();

  EntryActionDelegate(this.mainEntry, this.pageEntry, this.collection);

  bool isVisible(EntryAction action) {
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
      switch (action) {
        case EntryAction.toggleFavourite:
          return collection != null;
        case EntryAction.delete:
        case EntryAction.rename:
        case EntryAction.copy:
        case EntryAction.move:
          return targetEntry.canEdit;
        case EntryAction.rotateCCW:
        case EntryAction.rotateCW:
          return targetEntry.canRotate;
        case EntryAction.flip:
          return targetEntry.canFlip;
        case EntryAction.convert:
        case EntryAction.print:
          return !targetEntry.isVideo && device.canPrint;
        case EntryAction.openMap:
          return targetEntry.hasGps;
        case EntryAction.viewSource:
          return targetEntry.isSvg;
        case EntryAction.videoCaptureFrame:
        case EntryAction.videoToggleMute:
        case EntryAction.videoSelectStreams:
        case EntryAction.videoSetSpeed:
        case EntryAction.videoSettings:
        case EntryAction.videoTogglePlay:
        case EntryAction.videoReplay10:
        case EntryAction.videoSkip10:
          return targetEntry.isVideo;
        case EntryAction.rotateScreen:
          return settings.isRotationLocked;
        case EntryAction.addShortcut:
          return device.canPinShortcut;
        case EntryAction.info:
        case EntryAction.copyToClipboard:
        case EntryAction.edit:
        case EntryAction.open:
        case EntryAction.setAs:
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
          return _metadataActionDelegate.isVisible(targetEntry, action);
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
      default:
        return true;
    }
  }

  void onActionSelected(BuildContext context, EntryAction action) {
    var targetEntry = mainEntry;
    if (mainEntry.isMultiPage && (mainEntry.isBurst || EntryActions.pageActions.contains(action))) {
      final multiPageController = context.read<MultiPageConductor>().getController(mainEntry);
      if (multiPageController != null) {
        final multiPageInfo = multiPageController.info;
        final pageEntry = multiPageInfo?.getPageEntryByIndex(multiPageController.page);
        if (pageEntry != null) {
          targetEntry = pageEntry;
        }
      }
    }

    switch (action) {
      case EntryAction.info:
        ShowInfoNotification().dispatch(context);
        break;
      case EntryAction.addShortcut:
        _addShortcut(context, targetEntry);
        break;
      case EntryAction.copyToClipboard:
        androidAppService.copyToClipboard(targetEntry.uri, targetEntry.bestTitle).then((success) {
          showFeedback(context, success ? context.l10n.genericSuccessFeedback : context.l10n.genericFailureFeedback);
        });
        break;
      case EntryAction.delete:
        _delete(context, targetEntry);
        break;
      case EntryAction.restore:
        _move(context, targetEntry, moveType: MoveType.fromBin);
        break;
      case EntryAction.convert:
        _convert(context, targetEntry);
        break;
      case EntryAction.print:
        EntryPrinter(targetEntry).print(context);
        break;
      case EntryAction.rename:
        _rename(context, targetEntry);
        break;
      case EntryAction.copy:
        _move(context, targetEntry, moveType: MoveType.copy);
        break;
      case EntryAction.move:
        _move(context, targetEntry, moveType: MoveType.move);
        break;
      case EntryAction.share:
        androidAppService.shareEntries({targetEntry}).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.toggleFavourite:
        targetEntry.toggleFavourite();
        break;
      // raster
      case EntryAction.rotateCCW:
        _rotate(context, targetEntry, clockwise: false);
        break;
      case EntryAction.rotateCW:
        _rotate(context, targetEntry, clockwise: true);
        break;
      case EntryAction.flip:
        _flip(context, targetEntry);
        break;
      // vector
      case EntryAction.viewSource:
        _goToSourceViewer(context, targetEntry);
        break;
      // video
      case EntryAction.videoCaptureFrame:
      case EntryAction.videoToggleMute:
      case EntryAction.videoSelectStreams:
      case EntryAction.videoSetSpeed:
      case EntryAction.videoSettings:
      case EntryAction.videoTogglePlay:
      case EntryAction.videoReplay10:
      case EntryAction.videoSkip10:
        final controller = context.read<VideoConductor>().getController(targetEntry);
        if (controller != null) {
          VideoActionNotification(controller: controller, action: action).dispatch(context);
        }
        break;
      case EntryAction.edit:
        androidAppService.edit(targetEntry.uri, targetEntry.mimeType).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.open:
        androidAppService.open(targetEntry.uri, targetEntry.mimeTypeAnySubtype).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.openMap:
        androidAppService.openMap(targetEntry.latLng!).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      case EntryAction.setAs:
        androidAppService.setAs(targetEntry.uri, targetEntry.mimeType).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      // platform
      case EntryAction.rotateScreen:
        _rotateScreen(context);
        break;
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
        break;
      // debug
      case EntryAction.debug:
        _goToDebug(context, targetEntry);
        break;
    }
  }

  Future<void> _addShortcut(BuildContext context, AvesEntry targetEntry) async {
    final result = await showDialog<Tuple2<AvesEntry?, String>>(
      context: context,
      builder: (context) => AddShortcutDialog(
        defaultName: targetEntry.bestTitle ?? '',
      ),
    );
    if (result == null) return;

    final name = result.item2;
    if (name.isEmpty) return;

    await androidAppService.pinToHomeScreen(name, targetEntry, uri: targetEntry.uri);
    if (!device.showPinShortcutFeedback) {
      showFeedback(context, context.l10n.genericSuccessFeedback);
    }
  }

  Future<void> _flip(BuildContext context, AvesEntry targetEntry) async {
    await edit(context, targetEntry, targetEntry.flip);
  }

  Future<void> _rotate(BuildContext context, AvesEntry targetEntry, {required bool clockwise}) async {
    await edit(context, targetEntry, () => targetEntry.rotate(clockwise: clockwise));
  }

  Future<void> _rotateScreen(BuildContext context) async {
    switch (context.read<MediaQueryData>().orientation) {
      case Orientation.landscape:
        await windowService.requestOrientation(Orientation.portrait);
        break;
      case Orientation.portrait:
        await windowService.requestOrientation(Orientation.landscape);
        break;
    }
  }

  Future<void> _delete(BuildContext context, AvesEntry targetEntry) async {
    if (settings.enableBin && !targetEntry.trashed) {
      await _move(context, targetEntry, moveType: MoveType.toBin);
      return;
    }

    final l10n = context.l10n;
    if (!await showConfirmationDialog(
      context: context,
      type: ConfirmationDialog.deleteForever,
      message: l10n.deleteEntriesConfirmationDialogMessage(1),
      confirmationButtonLabel: l10n.deleteButtonLabel,
    )) return;

    if (!await checkStoragePermission(context, {targetEntry})) return;

    if (!await targetEntry.delete()) {
      showFeedback(context, l10n.genericFailureFeedback);
    } else {
      final source = context.read<CollectionSource>();
      if (source.initState != SourceInitializationState.none) {
        await source.removeEntries({targetEntry.uri}, includeTrash: true);
      }
      EntryDeletedNotification({targetEntry}).dispatch(context);
    }
  }

  Future<void> _convert(BuildContext context, AvesEntry targetEntry) async {
    final options = await showDialog<EntryExportOptions>(
      context: context,
      builder: (context) => ExportEntryDialog(entry: targetEntry),
    );
    if (options == null) return;

    final destinationAlbum = await pickAlbum(context: context, moveType: MoveType.export);
    if (destinationAlbum == null) return;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (!await checkFreeSpaceForMove(context, {targetEntry}, destinationAlbum, MoveType.export)) return;

    final selection = <AvesEntry>{};
    if (targetEntry.isMultiPage) {
      final multiPageInfo = await targetEntry.getMultiPageInfo();
      if (multiPageInfo != null) {
        if (targetEntry.isMotionPhoto) {
          await multiPageInfo.extractMotionPhotoVideo();
        }
        if (multiPageInfo.pageCount > 1) {
          selection.addAll(multiPageInfo.exportEntries);
        }
      }
    } else {
      selection.add(targetEntry);
    }

    final selectionCount = selection.length;
    final source = context.read<CollectionSource>();
    source.pauseMonitoring();
    await showOpReport<ExportOpEvent>(
      context: context,
      opStream: mediaEditService.export(
        selection,
        options: options,
        destinationAlbum: destinationAlbum,
        nameConflictStrategy: NameConflictStrategy.rename,
      ),
      itemCount: selectionCount,
      onDone: (processed) {
        final successOps = processed.where((e) => e.success).toSet();
        final exportedOps = successOps.where((e) => !e.skipped).toSet();
        final newUris = exportedOps.map((v) => v.newFields['uri'] as String?).whereNotNull().toSet();
        final isMainMode = context.read<ValueNotifier<AppMode>>().value == AppMode.main;

        source.resumeMonitoring();
        source.refreshUris(newUris);

        final l10n = context.l10n;
        final showAction = isMainMode && newUris.isNotEmpty
            ? SnackBarAction(
                label: l10n.showButtonLabel,
                onPressed: () {
                  // local context may be deactivated when action is triggered after navigation
                  final context = AvesApp.navigatorKey.currentContext;
                  if (context != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: CollectionPage.routeName),
                        builder: (context) => CollectionPage(
                          source: source,
                          filters: {AlbumFilter(destinationAlbum, source.getAlbumDisplayName(context, destinationAlbum))},
                          highlightTest: (entry) => newUris.contains(entry.uri),
                        ),
                      ),
                      (route) => false,
                    );
                  }
                },
              )
            : null;
        final successCount = successOps.length;
        if (successCount < selectionCount) {
          final count = selectionCount - successCount;
          showFeedback(
            context,
            l10n.collectionExportFailureFeedback(count),
            showAction,
          );
        } else {
          showFeedback(
            context,
            l10n.genericSuccessFeedback,
            showAction,
          );
        }
      },
    );
  }

  Future<void> _move(BuildContext context, AvesEntry targetEntry, {required MoveType moveType}) => move(
        context,
        moveType: moveType,
        entries: {targetEntry},
      );

  Future<void> _rename(BuildContext context, AvesEntry targetEntry) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameEntryDialog(entry: targetEntry),
    );
    if (newName == null || newName.isEmpty || newName == targetEntry.filenameWithoutExtension) return;

    // wait for the dialog to hide as applying the change may block the UI
    await Future.delayed(Durations.dialogTransitionAnimation * timeDilation);
    await rename(
      context,
      entriesToNewName: {targetEntry: '$newName${targetEntry.extension}'},
      persist: _isMainMode(context),
      onSuccess: targetEntry.metadataChangeNotifier.notify,
    );
  }

  bool _isMainMode(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.main;

  void _goToSourceViewer(BuildContext context, AvesEntry targetEntry) {
    Navigator.push(
      context,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: ViewerDebugPage.routeName),
        builder: (context) => ViewerDebugPage(entry: targetEntry),
      ),
    );
  }
}
