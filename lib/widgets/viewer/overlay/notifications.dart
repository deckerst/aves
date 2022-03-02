import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:flutter/material.dart';

@immutable
class ToggleOverlayNotification extends Notification {
  final bool? visible;

  const ToggleOverlayNotification({this.visible});
}

@immutable
class ViewEntryNotification extends Notification {
  final int index;

  const ViewEntryNotification({required this.index});
}

@immutable
class VideoGestureNotification extends Notification {
  final AvesVideoController controller;
  final VideoAction action;

  const VideoGestureNotification({
    required this.controller,
    required this.action,
  });
}
