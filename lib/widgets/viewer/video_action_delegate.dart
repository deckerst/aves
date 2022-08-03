import 'dart:async';

import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/media/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/video_speed_dialog.dart';
import 'package:aves/widgets/dialogs/video_stream_selection_dialog.dart';
import 'package:aves/widgets/settings/video/video_settings_page.dart';
import 'package:aves/widgets/viewer/notifications.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  Timer? _overlayHidingTimer;
  final CollectionLens? collection;

  VideoActionDelegate({
    required this.collection,
  });

  void dispose() {
    stopOverlayHidingTimer();
  }

  void onActionSelected(BuildContext context, AvesVideoController controller, EntryAction action) {
    // make sure overlay is not disappearing when selecting an action
    stopOverlayHidingTimer();
    const ToggleOverlayNotification(visible: true).dispatch(context);

    switch (action) {
      case EntryAction.videoCaptureFrame:
        _captureFrame(context, controller);
        break;
      case EntryAction.videoToggleMute:
        controller.toggleMute();
        break;
      case EntryAction.videoSelectStreams:
        _showStreamSelectionDialog(context, controller);
        break;
      case EntryAction.videoSetSpeed:
        _showSpeedDialog(context, controller);
        break;
      case EntryAction.videoSettings:
        _showSettings(context, controller);
        break;
      case EntryAction.videoTogglePlay:
        _togglePlayPause(context, controller);
        break;
      case EntryAction.videoReplay10:
        controller.seekTo(controller.currentPosition - 10000);
        break;
      case EntryAction.videoSkip10:
        controller.seekTo(controller.currentPosition + 10000);
        break;
      case EntryAction.open:
        final entry = controller.entry;
        androidAppService.open(entry.uri, entry.mimeTypeAnySubtype).then((success) {
          if (!success) showNoMatchingAppDialog(context);
        });
        break;
      default:
        throw UnsupportedError('$action is not a video action');
    }
  }

  Future<void> _captureFrame(BuildContext context, AvesVideoController controller) async {
    final positionMillis = controller.currentPosition;
    final bytes = await controller.captureFrame();

    final destinationAlbum = androidFileUtils.avesVideoCapturesPath;
    if (!await checkStoragePermissionForAlbums(context, {destinationAlbum})) return;

    if (!await checkFreeSpace(context, bytes.length, destinationAlbum)) return;

    final entry = controller.entry;
    final rotationDegrees = entry.rotationDegrees;
    final dateTimeMillis = entry.catalogMetadata?.dateMillis;
    final latLng = entry.latLng;
    final exif = {
      if (rotationDegrees != 0) 'rotationDegrees': rotationDegrees,
      if (dateTimeMillis != null && dateTimeMillis != 0) 'dateTimeMillis': dateTimeMillis,
      if (latLng != null) ...{
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      }
    };

    final newFields = await mediaEditService.captureFrame(
      entry,
      desiredName: '${entry.bestTitle}_${'$positionMillis'.padLeft(8, '0')}',
      exif: exif,
      bytes: bytes,
      destinationAlbum: destinationAlbum,
      nameConflictStrategy: NameConflictStrategy.rename,
    );
    final success = newFields.isNotEmpty;

    final l10n = context.l10n;
    if (success) {
      final _collection = collection;
      final showAction = _collection != null
          ? SnackBarAction(
              label: l10n.showButtonLabel,
              onPressed: () {
                // local context may be deactivated when action is triggered after navigation
                final context = AvesApp.navigatorKey.currentContext;
                if (context != null) {
                  final source = _collection.source;
                  final newUri = newFields['uri'] as String?;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: CollectionPage.routeName),
                      builder: (context) => CollectionPage(
                        source: source,
                        filters: {AlbumFilter(destinationAlbum, source.getAlbumDisplayName(context, destinationAlbum))},
                        highlightTest: (entry) => entry.uri == newUri,
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
            )
          : null;
      showFeedback(context, l10n.genericSuccessFeedback, showAction);
    } else {
      showFeedback(context, l10n.genericFailureFeedback);
    }
  }

  Future<void> _showStreamSelectionDialog(BuildContext context, AvesVideoController controller) async {
    final streams = controller.streams;
    final currentSelectedStreams = await Future.wait(StreamType.values.map(controller.getSelectedStream));
    final currentSelectedIndices = currentSelectedStreams.whereNotNull().map((v) => v.index).toSet();

    final userSelectedStreams = await showDialog<Map<StreamType, StreamSummary?>>(
      context: context,
      builder: (context) => VideoStreamSelectionDialog(
        streams: Map.fromEntries(streams.map((stream) => MapEntry(stream, currentSelectedIndices.contains(stream.index)))),
      ),
    );
    if (userSelectedStreams == null || userSelectedStreams.isEmpty) return;

    await Future.forEach<MapEntry<StreamType, StreamSummary?>>(
      userSelectedStreams.entries,
      (kv) => controller.selectStream(kv.key, kv.value),
    );
  }

  Future<void> _showSpeedDialog(BuildContext context, AvesVideoController controller) async {
    final newSpeed = await showDialog<double>(
      context: context,
      builder: (context) => VideoSpeedDialog(
        current: controller.speed,
        min: controller.minSpeed,
        max: controller.maxSpeed,
      ),
    );
    if (newSpeed == null) return;

    controller.speed = newSpeed;
  }

  Future<void> _showSettings(BuildContext context, AvesVideoController controller) async {
    int? resumePosition;
    if (controller.isPlaying) {
      resumePosition = controller.currentPosition;
      await controller.pause();
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: VideoSettingsPage.routeName),
        builder: (context) => const VideoSettingsPage(),
      ),
    );
    if (resumePosition != null) {
      if (!controller.isReady) {
        await controller.seekTo(resumePosition);
      }
      await controller.play();
    }
  }

  Future<void> _togglePlayPause(BuildContext context, AvesVideoController controller) async {
    if (controller.isPlaying) {
      await controller.pause();
    } else {
      final resumeTimeMillis = await controller.getResumeTime(context);
      if (resumeTimeMillis != null) {
        await controller.seekTo(resumeTimeMillis);
      } else {
        await controller.play();
      }
      // hide overlay
      _overlayHidingTimer = Timer(context.read<DurationsData>().iconAnimation + Durations.videoOverlayHideDelay, () {
        const ToggleOverlayNotification(visible: false).dispatch(context);
      });
    }
  }

  void stopOverlayHidingTimer() => _overlayHidingTimer?.cancel();
}
