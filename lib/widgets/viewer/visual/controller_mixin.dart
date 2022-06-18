import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/video/conductor.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

// state controllers/monitors
mixin EntryViewControllerMixin<T extends StatefulWidget> on State<T> {
  final Map<MultiPageController, Future<void> Function()> _multiPageControllerPageListeners = {};

  ValueNotifier<AvesEntry?> get entryNotifier;

  Future<void> initEntryControllers(AvesEntry? entry) async {
    if (entry == null) return;

    if (entry.isVideo) {
      await _initVideoController(entry);
    }
    if (entry.isMultiPage) {
      await _initMultiPageController(entry);
    }
  }

  void cleanEntryControllers(AvesEntry? entry) {
    if (entry == null) return;

    if (entry.isMultiPage) {
      _cleanMultiPageController(entry);
    }
  }

  bool _isSlideshow(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.slideshow;

  bool _shouldAutoPlay(BuildContext context) {
    if (_isSlideshow(context)) {
      switch (settings.slideshowVideoPlayback) {
        case SlideshowVideoPlayback.skip:
          return false;
        case SlideshowVideoPlayback.playMuted:
        case SlideshowVideoPlayback.playWithSound:
          return true;
      }
    }

    return settings.enableVideoAutoPlay;
  }

  Future<void> _initVideoController(AvesEntry entry) async {
    final controller = context.read<VideoConductor>().getOrCreateController(entry);
    setState(() {});

    if (_shouldAutoPlay(context)) {
      final resumeTimeMillis = await controller.getResumeTime(context);
      await _playVideo(controller, () => entry == entryNotifier.value, resumeTimeMillis: resumeTimeMillis);
    }
  }

  Future<void> _initMultiPageController(AvesEntry entry) async {
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
      Future<void> _onPageChange() async {
        await pauseVideoControllers();
        if (_shouldAutoPlay(context) || (entry.isMotionPhoto && settings.enableMotionPhotoAutoPlay)) {
          final page = multiPageController.page;
          final pageInfo = multiPageInfo.getByIndex(page)!;
          if (pageInfo.isVideo) {
            final pageEntry = multiPageInfo.getPageEntryByIndex(page);
            final pageVideoController = videoConductor.getController(pageEntry);
            assert(pageVideoController != null);
            if (pageVideoController != null) {
              await _playVideo(pageVideoController, () => entry == entryNotifier.value && page == multiPageController.page);
            }
          }
        }
      }

      _multiPageControllerPageListeners[multiPageController] = _onPageChange;
      multiPageController.pageNotifier.addListener(_onPageChange);
      await _onPageChange();

      if (entry.isMotionPhoto && settings.enableMotionPhotoAutoPlay) {
        await Future.delayed(Durations.motionPhotoAutoPlayDelay);
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

  Future<void> _playVideo(AvesVideoController videoController, bool Function() isCurrent, {int? resumeTimeMillis}) async {
    // video decoding may fail or have initial artifacts when the player initializes
    // during this widget initialization (because of the page transition and hero animation?)
    // so we play after a delay for increased stability
    await Future.delayed(const Duration(milliseconds: 300) * timeDilation);

    if (_isSlideshow(context) && settings.slideshowVideoPlayback == SlideshowVideoPlayback.playMuted && !videoController.isMuted) {
      await videoController.toggleMute();
    }

    if (resumeTimeMillis != null) {
      await videoController.seekTo(resumeTimeMillis);
    } else {
      await videoController.play();
    }

    // playing controllers are paused when the entry changes,
    // but the controller may still be preparing (not yet playing) when this happens
    // so we make sure the current entry is still the same to keep playing
    if (!isCurrent()) {
      await videoController.pause();
    }
  }

  Future<void> pauseVideoControllers() => context.read<VideoConductor>().pauseAll();
}
