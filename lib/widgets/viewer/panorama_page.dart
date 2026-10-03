import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/keys.dart';
import 'package:aves/model/entry/origins.dart';
import 'package:aves/model/media/panorama.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panorama/panorama.dart';
import 'package:provider/provider.dart';

class const PanoramaPage({
  super.key,
  required final AvesEntry entry,
  required final PanoramaInfo info,
}) extends StatefulWidget {
  static const routeName = '/viewer/panorama';

  @override
  State<PanoramaPage> createState() => _PanoramaPageState();
}

class _PanoramaPageState extends State<PanoramaPage> {
  final ValueNotifier<bool> _overlayVisibleNotifier = ValueNotifier(true);
  final ValueNotifier<SensorControl> _sensorControlNotifier = ValueNotifier(.none);
  Future<AvesAudioController>? _audioControllerLoader;

  AvesEntry get entry => widget.entry;

  PanoramaInfo get info => widget.info;

  static const double _minZoom = .25;
  static const int _sensorOrientationMeanCount = 15;

  @override
  void initState() {
    super.initState();
    _overlayVisibleNotifier.addListener(_onOverlayVisibleChanged);
    AvesApp.lifecycleStateNotifier.addListener(_onAppLifecycleStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initOverlay());

    final propPath = info.audioPropPath?.cast<Object>();
    final propMimeType = info.audioPropMimeType;
    if (propPath != null && propMimeType != null) {
      _audioControllerLoader = _initAudioPlayback(propPath: propPath, propMimeType: propMimeType);
    }
  }

  Future<AvesAudioController>? _initAudioPlayback({
    required List<Object> propPath,
    required String propMimeType,
  }) async {
    final fields = await embeddedDataService.extractXmpDataProp(entry, propPath, propMimeType);
    fields[EntryFields.sourceMimeType] ??= fields[EntryFields.mimeType];
    fields[EntryFields.origin] ??= EntryOrigins.unknownContent;
    final audioEntry = AvesEntry.fromMap(fields);

    final audioController = audioControllerFactory.buildController(audioEntry);
    await audioController.enableLoop(true);
    await audioController.play();
    return audioController;
  }

  @override
  void dispose() {
    _overlayVisibleNotifier.dispose();
    _sensorControlNotifier.dispose();
    _audioControllerLoader?.then((v) => v.dispose());
    AvesApp.lifecycleStateNotifier.removeListener(_onAppLifecycleStateChanged);
    super.dispose();
  }

  void _onAppLifecycleStateChanged() {
    switch (AvesApp.lifecycleStateNotifier.value) {
      case .inactive:
        break;
      case .hidden:
      case .paused:
      case .detached:
        _pauseAudioController();
      case .resumed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _onLeave(),
      child: AvesScaffold(
        body: Stack(
          children: [
            ValueListenableBuilder<SensorControl>(
              valueListenable: _sensorControlNotifier,
              builder: (context, sensorControl, child) {
                void onTap(longitude, latitude, tilt) => _overlayVisibleNotifier.value = !_overlayVisibleNotifier.value;
                final imageChild = child as Image;

                if (info.hasCroppedArea) {
                  final croppedArea = info.croppedAreaRect!;
                  final fullSize = info.fullPanoSize!;
                  final longitude = ((croppedArea.left + croppedArea.width / 2) / fullSize.width - 1 / 2) * 360;
                  return Panorama(
                    longitude: longitude,
                    minZoom: _minZoom,
                    sensorControl: sensorControl,
                    sensorOrientationMeanCount: _sensorOrientationMeanCount,
                    croppedArea: croppedArea,
                    croppedFullWidth: fullSize.width,
                    croppedFullHeight: fullSize.height,
                    onTap: onTap,
                    child: imageChild,
                  );
                } else {
                  return Panorama(
                    minZoom: _minZoom,
                    sensorControl: sensorControl,
                    sensorOrientationMeanCount: _sensorOrientationMeanCount,
                    onTap: onTap,
                    child: imageChild,
                  );
                }
              },
              child: Image(
                image: entry.getFullImage(),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildOverlay(context),
            ),
            const TopGestureAreaProtector(),
            const SideGestureAreaProtector(),
            const BottomGestureAreaProtector(),
          ],
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    if (settings.useTvLayout) return const SizedBox();

    final l10n = context.l10n;
    return TooltipTheme(
      data: TooltipTheme.of(context).copyWith(
        preferBelow: false,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _overlayVisibleNotifier,
        builder: (context, overlayVisible, child) {
          return Visibility(
            visible: overlayVisible,
            child: Selector<MediaQueryData, double>(
              selector: (context, mq) => mq.safeBottomPadding,
              builder: (context, safeBottomPadding, child) {
                return SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(8) + EdgeInsets.only(bottom: safeBottomPadding),
                    child: child,
                  ),
                );
              },
              child: Row(
                children: [
                  FutureBuilder<AvesAudioController>(
                    future: _audioControllerLoader,
                    builder: (context, snapshot) {
                      final audioController = snapshot.data;
                      if (audioController == null) return const SizedBox();

                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: OverlayButton(
                          child: StreamBuilder<PlaybackStatus>(
                            stream: audioController.statusStream,
                            builder: (context, _) {
                              final isPlaying = audioController.isPlaying;
                              return IconButton(
                                icon: Icon(isPlaying ? AIcons.mute : AIcons.unmute),
                                onPressed: () => isPlaying ? audioController.pause() : audioController.play(),
                                tooltip: isPlaying ? l10n.videoActionMute : l10n.videoActionUnmute,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  OverlayButton(
                    child: ValueListenableBuilder<SensorControl>(
                      valueListenable: _sensorControlNotifier,
                      builder: (context, sensorControl, child) {
                        return IconButton(
                          icon: Icon(sensorControl == .none ? AIcons.sensorControlEnabled : AIcons.sensorControlDisabled),
                          onPressed: _toggleSensor,
                          tooltip: sensorControl == .none ? l10n.panoramaEnableSensorControl : l10n.panoramaDisableSensorControl,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleSensor() {
    switch (_sensorControlNotifier.value) {
      case .none:
        _sensorControlNotifier.value = .absoluteOrientation;
      case .absoluteOrientation:
      case .orientation:
        _sensorControlNotifier.value = .none;
    }
  }

  void _pauseAudioController() {
    _audioControllerLoader?.then((v) => v.pause());
  }

  Future<void> _onLeave() async {
    await AvesApp.showSystemUI(true);
  }

  // system UI

  // overlay

  Future<void> _initOverlay() async {
    // wait for MaterialPageRoute.transitionDuration
    // to show overlay after page animation is complete
    await Future.delayed(ModalRoute.of(context)!.transitionDuration * timeDilation);
    await _onOverlayVisibleChanged();
  }

  Future<void> _onOverlayVisibleChanged() async {
    if (_overlayVisibleNotifier.value) {
      await AvesApp.showSystemUI(true);
    } else {
      await AvesApp.showSystemUI(false);
    }
  }
}
