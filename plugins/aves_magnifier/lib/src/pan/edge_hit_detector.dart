import 'package:aves_magnifier/src/controller/controller_delegate.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

mixin EdgeHitDetector on AvesMagnifierControllerDelegate {
  // the content width/height is not accurate for some image size & scale combos
  // e.g. 3580.0 * 0.1005586592178771 yields 360.0
  // but 4764.0 * 0.07556675062972293 yields 360.00000000000006
  // so be sure to compare with `precisionErrorTolerance`

  EdgeHit getXEdgeHit() {
    final _boundaries = scaleBoundaries;
    final _scale = controller.scale;
    if (_boundaries == null || _scale == null) return const EdgeHit(false, false);

    final x = -position.dx;
    final range = _boundaries.getXEdges(scale: _scale);
    return EdgeHit(x <= range.min + precisionErrorTolerance, x >= range.max - precisionErrorTolerance);
  }

  EdgeHit getYEdgeHit() {
    final _boundaries = scaleBoundaries;
    final _scale = controller.scale;
    if (_boundaries == null || _scale == null) return const EdgeHit(false, false);

    final y = -position.dy;
    final range = _boundaries.getYEdges(scale: _scale);
    return EdgeHit(y <= range.min + precisionErrorTolerance, y >= range.max - precisionErrorTolerance);
  }

  bool shouldMoveX(Offset move, bool canFling) {
    final hit = getXEdgeHit();
    return _shouldMove(hit, move.dx) || (canFling && !hit.hasHitBoth);
  }

  bool shouldMoveY(Offset move, bool canFling) {
    final hit = getYEdgeHit();
    return _shouldMove(hit, move.dy) || (canFling && !hit.hasHitBoth);
  }

  bool _shouldMove(EdgeHit hit, double move) {
    if (hit.hasHitAny && move != 0) {
      if (hit.hasHitBoth) return false;
      if (hit.hasHitMax) return move < 0;
      return move > 0;
    }
    return true;
  }
}

@immutable
class EdgeHit extends Equatable {
  final bool hasHitMin;
  final bool hasHitMax;

  @override
  List<Object?> get props => [hasHitMin, hasHitMax];

  const EdgeHit(this.hasHitMin, this.hasHitMax);

  bool get hasHitAny => hasHitMin || hasHitMax;

  bool get hasHitBoth => hasHitMin && hasHitMax;
}
