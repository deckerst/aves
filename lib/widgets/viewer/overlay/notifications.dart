import 'package:aves/model/actions/entry_actions.dart';
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
class VideoActionNotification extends Notification {
  final AvesVideoController controller;
  final EntryAction action;

  const VideoActionNotification({
    required this.controller,
    required this.action,
  });
}
