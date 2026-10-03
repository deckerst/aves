import 'package:flutter/widgets.dart';

@immutable
class const DraggableScrollbarNotification(final DraggableScrollbarEvent event) extends Notification;

enum DraggableScrollbarEvent { dragStart, dragEnd }
