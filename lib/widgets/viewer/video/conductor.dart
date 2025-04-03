import 'dart:async';
import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/viewer/video/db_playback_state_handler.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';

class VideoConductor {
  final CollectionLens? _collection;
  final List<AvesVideoController> _controllers = [];
  final Map<AvesVideoController, StreamSubscription> _subscriptions = {};
  final PlaybackStateHandler _playbackStateHandler = DatabasePlaybackStateHandler();

  final ValueNotifier<AvesVideoController?> playingVideoControllerNotifier = ValueNotifier(null);

  static const _defaultMaxControllerCount = 3;

  VideoConductor({CollectionLens? collection}) : _collection = collection {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$VideoConductor',
        object: this,
      );
    }
  }

  Future<void> dispose() async {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    await _disposeAll();
    playingVideoControllerNotifier.dispose();
    _controllers.clear();
    if (settings.keepScreenOn == KeepScreenOn.videoPlayback) {
      await windowService.keepScreenOn(false);
    }
  }

  Future<AvesVideoController> getOrCreateController(AvesEntry entry, {int? maxControllerCount}) async {
    var controller = getController(entry);
    if (controller != null) {
      _controllers.remove(controller);
    } else {
      maxControllerCount = max(_defaultMaxControllerCount, maxControllerCount ?? 0);
      while (_controllers.length >= maxControllerCount) {
        await _disposeController(_controllers.removeLast());
      }
      await deviceService.requestGarbageCollection();
      controller = videoControllerFactory.buildController(
        entry,
        playbackStateHandler: _playbackStateHandler,
        settings: settings,
      );
      _subscriptions[controller] = controller.statusStream.listen((event) => _onControllerStatusChanged(entry, controller!, event));
    }
    _controllers.insert(0, controller);
    return controller;
  }

  AvesVideoController? getPlayingController() => _controllers.firstWhereOrNull((c) => c.isPlaying);

  AvesVideoController? getController(AvesEntry entry) {
    return _controllers.firstWhereOrNull((c) => c.entry.uri == entry.uri && c.entry.pageId == entry.pageId);
  }

  Future<void> _onControllerStatusChanged(AvesEntry entry, AvesVideoController controller, VideoStatus status) async {
    bool canSkipToNext = false, canSkipToPrevious = false;
    final entries = _collection?.sortedEntries;
    if (entries != null) {
      final currentIndex = entries.indexOf(entry);
      if (currentIndex != -1) {
        bool isVideo(AvesEntry entry) => entry.isVideo;
        canSkipToPrevious = entries.take(currentIndex).lastWhereOrNull(isVideo) != null;
        canSkipToNext = entries.skip(currentIndex + 1).firstWhereOrNull(isVideo) != null;
      }
    }

    await mediaSessionService.update(
      entry: entry,
      controller: controller,
      canSkipToNext: canSkipToNext,
      canSkipToPrevious: canSkipToPrevious,
    );
    if (settings.keepScreenOn == KeepScreenOn.videoPlayback) {
      await windowService.keepScreenOn(status == VideoStatus.playing);
    }

    playingVideoControllerNotifier.value = getPlayingController();
  }

  Future<void> _applyToAll(FutureOr Function(AvesVideoController controller) action) => Future.forEach<AvesVideoController>(_controllers, action);

  Future<void> _disposeAll() => _applyToAll(_disposeController);

  Future<void> pauseAll() => _applyToAll((controller) => controller.pause());

  Future<void> muteAll(bool muted) => _applyToAll((controller) => controller.mute(muted));

  Future<void> _disposeController(AvesVideoController controller) async {
    await _subscriptions.remove(controller)?.cancel();
    await controller.dispose();
  }
}
