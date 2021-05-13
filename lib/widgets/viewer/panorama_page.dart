import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/panorama.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:panorama/panorama.dart';
import 'package:provider/provider.dart';

class PanoramaPage extends StatefulWidget {
  static const routeName = '/viewer/panorama';

  final AvesEntry entry;
  final PanoramaInfo info;

  const PanoramaPage({
    required this.entry,
    required this.info,
  });

  @override
  _PanoramaPageState createState() => _PanoramaPageState();
}

class _PanoramaPageState extends State<PanoramaPage> {
  final ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  final ValueNotifier<SensorControl> _sensorControl = ValueNotifier(SensorControl.None);

  AvesEntry get entry => widget.entry;

  PanoramaInfo get info => widget.info;

  @override
  void initState() {
    super.initState();
    _overlayVisible.addListener(_onOverlayVisibleChange);
    WidgetsBinding.instance!.addPostFrameCallback((_) => _initOverlay());
  }

  @override
  void dispose() {
    _overlayVisible.removeListener(_onOverlayVisibleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onLeave();
        return SynchronousFuture(true);
      },
      child: MediaQueryDataProvider(
        child: Scaffold(
          body: Stack(
            children: [
              ValueListenableBuilder<SensorControl>(
                valueListenable: _sensorControl,
                builder: (context, sensorControl, child) {
                  return Panorama(
                    sensorControl: sensorControl,
                    croppedArea: info.hasCroppedArea ? info.croppedAreaRect! : Rect.fromLTWH(0.0, 0.0, 1.0, 1.0),
                    croppedFullWidth: info.hasCroppedArea ? info.fullPanoSize!.width : 1.0,
                    croppedFullHeight: info.hasCroppedArea ? info.fullPanoSize!.height : 1.0,
                    onTap: (longitude, latitude, tilt) => _overlayVisible.value = !_overlayVisible.value,
                    child: child as Image?,
                  );
                },
                child: Image(
                  image: entry.uriImage,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: TooltipTheme(
                  data: TooltipTheme.of(context).copyWith(
                    preferBelow: false,
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _overlayVisible,
                    builder: (context, overlayVisible, child) {
                      return Visibility(
                        visible: overlayVisible,
                        child: Selector<MediaQueryData, EdgeInsets>(
                          selector: (c, mq) => mq.viewPadding + mq.viewInsets,
                          builder: (c, mqPadding, child) {
                            return Padding(
                              padding: EdgeInsets.all(8) + EdgeInsets.only(right: mqPadding.right, bottom: mqPadding.bottom),
                              child: OverlayButton(
                                child: ValueListenableBuilder<SensorControl>(
                                    valueListenable: _sensorControl,
                                    builder: (context, sensorControl, child) {
                                      return IconButton(
                                        icon: Icon(sensorControl == SensorControl.None ? AIcons.sensorControl : AIcons.sensorControlOff),
                                        onPressed: _toggleSensor,
                                        tooltip: sensorControl == SensorControl.None ? context.l10n.panoramaEnableSensorControl : context.l10n.panoramaDisableSensorControl,
                                      );
                                    }),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              BottomGestureAreaProtector(),
            ],
          ),
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }

  void _toggleSensor() {
    switch (_sensorControl.value) {
      case SensorControl.None:
        _sensorControl.value = SensorControl.AbsoluteOrientation;
        break;
      case SensorControl.AbsoluteOrientation:
      case SensorControl.Orientation:
        _sensorControl.value = SensorControl.None;
        break;
    }
  }

  void _onLeave() {
    _showSystemUI();
  }

  // system UI

  static void _showSystemUI() => SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  static void _hideSystemUI() => SystemChrome.setEnabledSystemUIOverlays([]);

  // overlay

  Future<void> _initOverlay() async {
    // wait for MaterialPageRoute.transitionDuration
    // to show overlay after page animation is complete
    await Future.delayed(ModalRoute.of(context)!.transitionDuration * timeDilation);
    await _onOverlayVisibleChange();
  }

  Future<void> _onOverlayVisibleChange() async {
    if (_overlayVisible.value) {
      _showSystemUI();
    } else {
      _hideSystemUI();
    }
  }
}
