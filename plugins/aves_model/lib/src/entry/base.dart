import 'dart:ui';

import 'package:flutter/foundation.dart';

mixin AvesEntryBase {
  int get id;

  String get uri;

  int? get pageId;

  String get mimeType;

  String? get path;

  String? get bestTitle;

  int? get sizeBytes;

  int? get durationMillis;

  bool get isAnimated;

  int get rotationDegrees;

  Size get displaySize;

  double get displayAspectRatio;

  Listenable get visualChangeNotifier;
}
