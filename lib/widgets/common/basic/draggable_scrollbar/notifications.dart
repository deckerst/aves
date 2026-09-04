import 'package:flutter/widgets.dart';

@immutable
class DraggableScrollbarNotification extends Notification {
  final DraggableScrollbarEvent event;

  const new(this.event);
}

enum DraggableScrollbarEvent { dragStart, dragEnd }
