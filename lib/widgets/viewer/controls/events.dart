import 'package:flutter/foundation.dart';

@immutable
class ViewerShowNextEvent;

@immutable
class ViewerOverlayToggleEvent {
  final bool? visible;

  const new({required this.visible});
}
