import 'package:flutter/widgets.dart';

@immutable
class DraggableScrollbarNotification extends Notification {
  final DraggableScrollbarEvent event;

  const DraggableScrollbarNotification(this.event);
}

enum DraggableScrollbarEvent { dragStart, dragEnd }
