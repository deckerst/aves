import 'package:aves/widgets/common/magnifier/controller/controller_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

mixin CornerHitDetector on MagnifierControllerDelegate {
  _AxisHit hitAxis() => _AxisHit(_hitCornersX(), _hitCornersY());

  // the child width/height is not accurate for some image size & scale combos
  // e.g. 3580.0 * 0.1005586592178771 yields 360.0
  // but 4764.0 * 0.07556675062972293 yields 360.00000000000006
  // so be sure to compare with `precisionErrorTolerance`

  _CornerHit _hitCornersX() {
    final childWidth = scaleBoundaries.childSize.width * scale!;
    final viewportWidth = scaleBoundaries.viewportSize.width;
    if (viewportWidth + precisionErrorTolerance >= childWidth) {
      return _CornerHit(true, true);
    }
    final x = -position.dx;
    final cornersX = this.cornersX();
    return _CornerHit(x <= cornersX.min, x >= cornersX.max);
  }

  _CornerHit _hitCornersY() {
    final childHeight = scaleBoundaries.childSize.height * scale!;
    final viewportHeight = scaleBoundaries.viewportSize.height;
    if (viewportHeight + precisionErrorTolerance >= childHeight) {
      return _CornerHit(true, true);
    }
    final y = -position.dy;
    final cornersY = this.cornersY();
    return _CornerHit(y <= cornersY.min, y >= cornersY.max);
  }

  bool shouldMoveX(Offset move) {
    final hitCornersX = _hitCornersX();
    if (hitCornersX.hasHitAny && move != Offset.zero) {
      if (hitCornersX.hasHitBoth) return false;
      if (hitCornersX.hasHitMax) return move.dx < 0;
      return move.dx > 0;
    }
    return true;
  }

  bool shouldMoveY(Offset move) {
    final hitCornersY = _hitCornersY();
    if (hitCornersY.hasHitAny && move != Offset.zero) {
      if (hitCornersY.hasHitBoth) return false;
      if (hitCornersY.hasHitMax) return move.dy < 0;
      return move.dy > 0;
    }
    return true;
  }
}

class _AxisHit {
  _AxisHit(this.hasHitX, this.hasHitY);

  final _CornerHit hasHitX;
  final _CornerHit hasHitY;

  bool get hasHitAny => hasHitX.hasHitAny || hasHitY.hasHitAny;

  bool get hasHitBoth => hasHitX.hasHitBoth && hasHitY.hasHitBoth;
}

class _CornerHit {
  const _CornerHit(this.hasHitMin, this.hasHitMax);

  final bool hasHitMin;
  final bool hasHitMax;

  bool get hasHitAny => hasHitMin || hasHitMax;

  bool get hasHitBoth => hasHitMin && hasHitMax;
}
