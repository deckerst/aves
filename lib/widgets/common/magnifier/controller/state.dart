import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class MagnifierState {
  const MagnifierState({
    required this.position,
    required this.scale,
    required this.source,
  });

  final Offset position;
  final double? scale;
  final ChangeSource source;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MagnifierState && runtimeType == other.runtimeType && position == other.position && scale == other.scale;

  @override
  int get hashCode => hashValues(position, scale, source);

  @override
  String toString() => '$runtimeType#${shortHash(this)}{position: $position, scale: $scale, source: $source}';
}

enum ChangeSource { internal, gesture, animation }
