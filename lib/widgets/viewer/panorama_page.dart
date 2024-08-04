import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/media/panorama.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:panorama/panorama.dart';
import 'package:provider/provider.dart';

class PanoramaPage extends StatefulWidget {
  static const routeName = '/viewer/panorama';

  final AvesEntry entry;
  final PanoramaInfo info;

  const PanoramaPage({
    super.key,
    required this.entry,
    required this.info,
  });

  @override
  State<PanoramaPage> createState() => _PanoramaPageState();
}

class _PanoramaPageState extends State<PanoramaPage> {
  final ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  final ValueNotifier<SensorControl> _sensorControl = ValueNotifier(SensorControl.None);

  AvesEntry get entry => widget.entry;

  PanoramaInfo get info => widget.info;

  @override
  void initState() {
    super.initState();
    _overlayVisible.addListener(_onOverlayVisibleChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initOverlay());
  }

  @override
  void dispose() {
    _overlayVisible.dispose();
    _sensorControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) => _onLeave(),
      child: AvesScaffold(
        body: Stack(
          children: [
            ValueListenableBuilder<SensorControl>(
              valueListenable: _sensorControl,
              builder: (context, sensorControl, child) {
                void onTap(longitude, latitude, tilt) => _overlayVisible.value = !_overlayVisible.value;
                final imageChild = child as Image;

                if (info.hasCroppedArea) {
                  final croppedArea = info.croppedAreaRect!;
                  final fullSize = info.fullPanoSize!;
                  final longitude = ((croppedArea.left + croppedArea.width / 2) / fullSize.width - 1 / 2) * 360;
                  return Panorama(
                    longitude: longitude,
                    sensorControl: sensorControl,
                    croppedArea: croppedArea,
                    croppedFullWidth: fullSize.width,
                    croppedFullHeight: fullSize.height,
                    onTap: onTap,
                    child: imageChild,
                  );
                } else {
                  return Panorama(
                    sensorControl: sensorControl,
                    onTap: onTap,
                    child: imageChild,
                  );
                }
              },
              child: Image(
                image: entry.uriImage,
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

    return TooltipTheme(
      data: TooltipTheme.of(context).copyWith(
        preferBelow: false,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _overlayVisible,
        builder: (context, overlayVisible, child) {
          return Visibility(
            visible: overlayVisible,
            child: Selector<MediaQueryData, double>(
              selector: (context, mq) => max(mq.effectiveBottomPadding, mq.systemGestureInsets.bottom),
              builder: (context, mqPaddingBottom, child) {
                return SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(8) + EdgeInsets.only(bottom: mqPaddingBottom),
                    child: child,
                  ),
                );
              },
              child: OverlayButton(
                child: ValueListenableBuilder<SensorControl>(
                  valueListenable: _sensorControl,
                  builder: (context, sensorControl, child) {
                    return IconButton(
                      icon: Icon(sensorControl == SensorControl.None ? AIcons.sensorControlEnabled : AIcons.sensorControlDisabled),
                      onPressed: _toggleSensor,
                      tooltip: sensorControl == SensorControl.None ? context.l10n.panoramaEnableSensorControl : context.l10n.panoramaDisableSensorControl,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleSensor() {
    switch (_sensorControl.value) {
      case SensorControl.None:
        _sensorControl.value = SensorControl.AbsoluteOrientation;
      case SensorControl.AbsoluteOrientation:
      case SensorControl.Orientation:
        _sensorControl.value = SensorControl.None;
    }
  }

  Future<void> _onLeave() async {
    await AvesApp.showSystemUI();
    AvesApp.setSystemUIStyle(Theme.of(context));
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
    if (_overlayVisible.value) {
      await AvesApp.showSystemUI();
      AvesApp.setSystemUIStyle(Theme.of(context));
    } else {
      await AvesApp.hideSystemUI();
    }
  }
}
