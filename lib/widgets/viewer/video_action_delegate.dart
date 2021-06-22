import 'dart:async';

import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/action_mixins/size_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/video_speed_dialog.dart';
import 'package:aves/widgets/dialogs/video_stream_selection_dialog.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

class VideoActionDelegate with FeedbackMixin, PermissionAwareMixin, SizeAwareMixin {
  final CollectionLens? collection;

  VideoActionDelegate({
    required this.collection,
  });

  void onActionSelected(BuildContext context, AvesVideoController controller, VideoAction action) {
    switch (action) {
      case VideoAction.captureFrame:
        _captureFrame(context, controller);
        break;
      case VideoAction.replay10:
        if (controller.isReady) controller.seekTo(controller.currentPosition - 10000);
        break;
      case VideoAction.selectStreams:
        _showStreamSelectionDialog(context, controller);
        break;
      case VideoAction.setSpeed:
        _showSpeedDialog(context, controller);
        break;
      case VideoAction.togglePlay:
        _togglePlayPause(context, controller);
        break;
    }
  }

  Future<void> _captureFrame(BuildContext context, AvesVideoController controller) async {
    final positionMillis = controller.currentPosition;
    final bytes = await controller.captureFrame();

    final destinationAlbum = androidFileUtils.videoCapturesPath;
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

    final newFields = await imageFileService.captureFrame(
      entry,
      desiredName: '${entry.bestTitle}_${'$positionMillis'.padLeft(8, '0')}',
      exif: exif,
      bytes: bytes,
      destinationAlbum: destinationAlbum,
    );
    final success = newFields.isNotEmpty;

    if (success) {
      final _collection = collection;
      final showAction = _collection != null
          ? SnackBarAction(
              label: context.l10n.showButtonLabel,
              onPressed: () async {
                final highlightInfo = context.read<HighlightInfo>();
                final source = _collection.source;
                final targetCollection = CollectionLens(
                  source: source,
                  filters: {AlbumFilter(destinationAlbum, source.getAlbumDisplayName(context, destinationAlbum))},
                  groupFactor: _collection.groupFactor,
                  sortFactor: _collection.sortFactor,
                );
                unawaited(Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: CollectionPage.routeName),
                    builder: (context) {
                      return CollectionPage(
                        targetCollection,
                      );
                    },
                  ),
                  (route) => false,
                ));
                await Future.delayed(Durations.staggeredAnimationPageTarget + Durations.highlightScrollInitDelay);
                final newUri = newFields['uri'] as String?;
                final targetEntry = targetCollection.sortedEntries.firstWhereOrNull((entry) => entry.uri == newUri);
                if (targetEntry != null) {
                  highlightInfo.trackItem(targetEntry, highlightItem: targetEntry);
                }
              },
            )
          : null;
      showFeedback(context, context.l10n.genericSuccessFeedback, showAction);
    } else {
      showFeedback(context, context.l10n.genericFailureFeedback);
    }
  }

  Future<void> _showStreamSelectionDialog(BuildContext context, AvesVideoController controller) async {
    final streams = controller.streams;
    final currentSelectedStreams = await Future.wait(StreamType.values.map(controller.getSelectedStream));
    final currentSelectedIndices = currentSelectedStreams.where((v) => v != null).cast<StreamSummary>().map((v) => v.index).toSet();

    final userSelectedStreams = await showDialog<Map<StreamType, StreamSummary>>(
      context: context,
      builder: (context) => VideoStreamSelectionDialog(
        streams: Map.fromEntries(streams.map((stream) => MapEntry(stream, currentSelectedIndices.contains(stream.index)))),
      ),
    );
    if (userSelectedStreams == null || userSelectedStreams.isEmpty) return;

    await Future.forEach<MapEntry<StreamType, StreamSummary>>(
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

  Future<void> _togglePlayPause(BuildContext context, AvesVideoController controller) async {
    if (controller.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }
}
