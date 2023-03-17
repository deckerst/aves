import 'package:aves/model/entry/entry.dart';
import 'package:flutter/widgets.dart';

@immutable
class OpenViewerNotification extends Notification {
  final AvesEntry entry;

  const OpenViewerNotification(this.entry);
}
