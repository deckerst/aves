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
