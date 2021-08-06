import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class MagnifierState extends Equatable {
  final Offset position;
  final double? scale;
  final ChangeSource source;

  @override
  List<Object?> get props => [position, scale, source];

  const MagnifierState({
    required this.position,
    required this.scale,
    required this.source,
  });
}

enum ChangeSource { internal, gesture, animation }
