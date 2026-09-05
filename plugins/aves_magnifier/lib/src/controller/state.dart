import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class const MagnifierState({
  required final Offset position,
  required final double? scale,
  required final ChangeSource source,
}) extends Equatable {
  @override
  List<Object?> get props => [position, scale, source];
}

enum ChangeSource { internal, gesture, animation }
