import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

// state controllers/monitors
mixin EntryViewControllerMixin<T extends StatefulWidget> on State<T> {
  final Map<AvesEntry, VoidCallback> _metadataChangeListeners = {};
  final Map<MultiPageController, Future<void> Function()> _multiPageControllerPageListeners = {};

  bool? videoMutedOverride;

  bool get isViewingImage;

  ValueNotifier<AvesEntry?> get entryNotifier;

  Future<void> initEntryControllers(AvesEntry? entry) async {
    if (!mounted || entry == null) return;

    if (entry.isVideo) {
      await _initVideoController(entry);
    }
    if (entry.isMultiPage) {
      await _initMultiPageController(entry);
    }
    void listener() => _onMetadataChanged(entry);
    _metadataChangeListeners[entry] = listener;
    entry.metadataChangeNotifier.addListener(listener);
  }

  void cleanEntryControllers(AvesEntry? entry) {
    if (entry == null) return;

    final listener = _metadataChangeListeners.remove(entry);
    if (listener != null) {
      entry.metadataChangeNotifier.removeListener(listener);
    }
    if (entry.isMultiPage) {
      _cleanMultiPageController(entry);
    }
  }

  void _onMetadataChanged(AvesEntry entry) {
    debugPrint('reinitialize controllers for entry=$entry because metadata changed');
    cleanEntryControllers(entry);
    initEntryControllers(entry);
  }

  SlideshowVideoPlayback? get videoPlaybackOverride {
    if (!mounted) return null;
    final appMode = context.read<ValueNotifier<AppMode>>().value;
    switch (appMode) {
      case AppMode.screenSaver:
        return settings.screenSaverVideoPlayback;
      case AppMode.slideshow:
        return settings.slideshowVideoPlayback;
      default:
        return null;
    }
  }

  bool get videoAutoPlayEnabled {
    if (!isViewingImage) return false;

    switch (videoPlaybackOverride) {
      case SlideshowVideoPlayback.skip:
        return false;
      case SlideshowVideoPlayback.playMuted:
      case SlideshowVideoPlayback.playWithSound:
        return true;
      case null:
        break;
    }

    switch (settings.videoAutoPlayMode) {
      case VideoAutoPlayMode.disabled:
        return false;
      case VideoAutoPlayMode.playMuted:
      case VideoAutoPlayMode.playWithSound:
        return true;
    }
  }

  bool get shouldAutoPlayVideoMuted {
    if (videoMutedOverride != null) {
      return videoMutedOverride!;
    }

    switch (videoPlaybackOverride) {
      case SlideshowVideoPlayback.skip:
      case SlideshowVideoPlayback.playWithSound:
        return false;
      case SlideshowVideoPlayback.playMuted:
        return true;
      case null:
        break;
    }

    switch (settings.videoAutoPlayMode) {
      case VideoAutoPlayMode.disabled:
      case VideoAutoPlayMode.playWithSound:
        return false;
      case VideoAutoPlayMode.playMuted:
        return true;
    }
  }

  bool get shouldAutoPlayMotionPhoto {
    if (!isViewingImage) return false;

    return settings.enableMotionPhotoAutoPlay;
  }

  Future<void> _initVideoController(AvesEntry entry) async {
    final controller = context.read<VideoConductor>().getOrCreateController(entry);
    setState(() {});

    if (videoAutoPlayEnabled || entry.isAnimated) {
      final resumeTimeMillis = await controller.getResumeTime(context);
      await _autoPlayVideo(controller, () => entry == entryNotifier.value, resumeTimeMillis: resumeTimeMillis);
    }
  }

  Future<void> _initMultiPageController(AvesEntry entry) async {
    if (!mounted) return;

    final multiPageController = context.read<MultiPageConductor>().getOrCreateController(entry);
    setState(() {});

    final multiPageInfo = multiPageController.info ?? await multiPageController.infoStream.first;
    assert(multiPageInfo != null);
    if (multiPageInfo == null) return;

    if (entry.isMotionPhoto) {
      await multiPageInfo.extractMotionPhotoVideo();
    }

    final videoPageEntries = multiPageInfo.videoPageEntries;
    if (videoPageEntries.isNotEmpty) {
      // init video controllers for all pages that could need it
      final videoConductor = context.read<VideoConductor>();
      videoPageEntries.forEach((entry) => videoConductor.getOrCreateController(entry, maxControllerCount: videoPageEntries.length));

      // auto play/pause when changing page
      Future<void> _onPageChanged() async {
        await pauseVideoControllers();
        if (videoAutoPlayEnabled || (entry.isMotionPhoto && shouldAutoPlayMotionPhoto)) {
          final page = multiPageController.page;
          final pageInfo = multiPageInfo.getByIndex(page)!;
          if (pageInfo.isVideo) {
            final pageEntry = multiPageInfo.getPageEntryByIndex(page);
            final pageVideoController = videoConductor.getController(pageEntry);
            assert(pageVideoController != null);
            if (pageVideoController != null) {
              await _autoPlayVideo(pageVideoController, () => entry == entryNotifier.value && page == multiPageController.page);
            }
          }
        }
      }

      _multiPageControllerPageListeners[multiPageController] = _onPageChanged;
      multiPageController.pageNotifier.addListener(_onPageChanged);
      await _onPageChanged();

      if (entry.isMotionPhoto && shouldAutoPlayMotionPhoto) {
        await Future.delayed(ADurations.motionPhotoAutoPlayDelay);
        if (entry == entryNotifier.value) {
          multiPageController.page = 1;
        }
      }
    }
  }

  Future<void> _cleanMultiPageController(AvesEntry entry) async {
    final multiPageController = _multiPageControllerPageListeners.keys.firstWhereOrNull((v) => v.entry == entry);
    if (multiPageController != null) {
      final _onPageChange = _multiPageControllerPageListeners.remove(multiPageController);
      if (_onPageChange != null) {
        multiPageController.pageNotifier.removeListener(_onPageChange);
      }
    }
  }

  Future<void> _autoPlayVideo(AvesVideoController videoController, bool Function() isCurrent, {int? resumeTimeMillis}) async {
    // video decoding may fail or have initial artifacts when the player initializes
    // during this widget initialization (because of the page transition and hero animation?)
    // so we play after a delay for increased stability
    await Future.delayed(const Duration(milliseconds: 300) * timeDilation);

    if (!videoController.isMuted && (videoController.entry.isAnimated || shouldAutoPlayVideoMuted)) {
      await videoController.mute(true);
    }

    if (resumeTimeMillis != null) {
      await videoController.seekTo(resumeTimeMillis);
    }
    await videoController.play();

    // playing controllers are paused when the entry changes,
    // but the controller may still be preparing (not yet playing) when this happens
    // so we make sure the current entry is still the same to keep playing
    if (!isCurrent()) {
      await videoController.pause();
    }
  }

  Future<void> pauseVideoControllers() => context.read<VideoConductor>().pauseAll();
}
