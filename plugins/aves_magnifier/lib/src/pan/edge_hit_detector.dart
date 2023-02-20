import 'package:aves_magnifier/src/controller/controller_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

mixin EdgeHitDetector on AvesMagnifierControllerDelegate {
  // the child width/height is not accurate for some image size & scale combos
  // e.g. 3580.0 * 0.1005586592178771 yields 360.0
  // but 4764.0 * 0.07556675062972293 yields 360.00000000000006
  // so be sure to compare with `precisionErrorTolerance`

  EdgeHit getXEdgeHit() {
    final boundaries = scaleBoundaries;
    if (boundaries == null) return const EdgeHit(false, false);

    final childWidth = boundaries.childSize.width * scale!;
    final viewportWidth = boundaries.viewportSize.width;
    if (viewportWidth + precisionErrorTolerance >= childWidth) {
      return const EdgeHit(true, true);
    }
    final x = -position.dx;
    final range = getXEdges();
    return EdgeHit(x <= range.min, x >= range.max);
  }

  EdgeHit getYEdgeHit() {
    final boundaries = scaleBoundaries;
    if (boundaries == null) return const EdgeHit(false, false);

    final childHeight = boundaries.childSize.height * scale!;
    final viewportHeight = boundaries.viewportSize.height;
    if (viewportHeight + precisionErrorTolerance >= childHeight) {
      return const EdgeHit(true, true);
    }
    final y = -position.dy;
    final range = getYEdges();
    return EdgeHit(y <= range.min, y >= range.max);
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

class EdgeHit {
  const EdgeHit(this.hasHitMin, this.hasHitMax);

  final bool hasHitMin;
  final bool hasHitMax;

  bool get hasHitAny => hasHitMin || hasHitMax;

  bool get hasHitBoth => hasHitMin && hasHitMax;
}
