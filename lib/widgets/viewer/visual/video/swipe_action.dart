import 'dart:async';

import 'package:aves/theme/icons.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

enum SwipeAction { brightness, volume }

extension ExtraSwipeAction on SwipeAction {
  Future<double> get() {
    switch (this) {
      case SwipeAction.brightness:
        return ScreenBrightness().current;
      case SwipeAction.volume:
        return VolumeController().getVolume();
    }
  }

  Future<void> set(double value) async {
    switch (this) {
      case SwipeAction.brightness:
        await ScreenBrightness().setScreenBrightness(value);
        break;
      case SwipeAction.volume:
        VolumeController().setVolume(value, showSystemUI: false);
        break;
    }
  }
}

class SwipeActionFeedback extends StatelessWidget {
  final SwipeAction action;
  final ValueNotifier<double?> valueNotifier;

  const SwipeActionFeedback({
    super.key,
    required this.action,
    required this.valueNotifier,
  });

  static const double width = 32;
  static const double height = 160;
  static const Radius radius = Radius.circular(width / 2);
  static const double borderWidth = 2;
  static const Color borderColor = Colors.white;
  static final Color fillColor = Colors.white.withOpacity(.8);
  static final Color backgroundColor = Colors.black.withOpacity(.2);
  static final Color innerBorderColor = Colors.black.withOpacity(.5);
  static const Color iconColor = Colors.white;
  static const Color shadowColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<double?>(
        valueListenable: valueNotifier,
        builder: (context, value, child) {
          if (value == null) return const SizedBox();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(_getMaxIcon()),
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(
                    width: borderWidth * 2,
                    color: innerBorderColor,
                  ),
                  borderRadius: const BorderRadius.all(radius),
                ),
                foregroundDecoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                  borderRadius: const BorderRadius.all(radius),
                ),
                width: width,
                height: height,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(radius),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: fillColor,
                      width: width,
                      height: height * value,
                    ),
                  ),
                ),
              ),
              _buildIcon(_getMinIcon()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DecoratedIcon(
        icon,
        size: width,
        color: iconColor,
        shadows: const [
          Shadow(
            color: shadowColor,
            blurRadius: 4,
          )
        ],
      ),
    );
  }

  IconData _getMinIcon() {
    switch (action) {
      case SwipeAction.brightness:
        return AIcons.brightnessMin;
      case SwipeAction.volume:
        return AIcons.volumeMin;
    }
  }

  IconData _getMaxIcon() {
    switch (action) {
      case SwipeAction.brightness:
        return AIcons.brightnessMax;
      case SwipeAction.volume:
        return AIcons.volumeMax;
    }
  }
}
