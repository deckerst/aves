enum EditorAction { transform }

enum CropAspectRatio { free, original, square, ar_16_9, ar_4_3 }

enum TransformActivity { none, pan, resize, straighten }

enum TransformOrientation { normal, rotate90, rotate180, rotate270, transverse, flipVertical, transpose, flipHorizontal }

extension ExtraTransformOrientation on TransformOrientation {
  TransformOrientation flipHorizontally() {
    switch (this) {
      case .normal:
        return TransformOrientation.flipHorizontal;
      case .rotate90:
        return TransformOrientation.transverse;
      case .rotate180:
        return TransformOrientation.flipVertical;
      case .rotate270:
        return TransformOrientation.transpose;
      case .transverse:
        return TransformOrientation.rotate90;
      case .flipVertical:
        return TransformOrientation.rotate180;
      case .transpose:
        return TransformOrientation.rotate270;
      case .flipHorizontal:
        return TransformOrientation.normal;
    }
  }

  bool get isFlipped {
    switch (this) {
      case .normal:
      case .rotate90:
      case .rotate180:
      case .rotate270:
        return false;
      case .transverse:
      case .flipVertical:
      case .transpose:
      case .flipHorizontal:
        return true;
    }
  }

  TransformOrientation rotateClockwise() {
    switch (this) {
      case .normal:
        return TransformOrientation.rotate90;
      case .rotate90:
        return TransformOrientation.rotate180;
      case .rotate180:
        return TransformOrientation.rotate270;
      case .rotate270:
        return TransformOrientation.normal;
      case .transverse:
        return TransformOrientation.flipHorizontal;
      case .flipVertical:
        return TransformOrientation.transverse;
      case .transpose:
        return TransformOrientation.flipVertical;
      case .flipHorizontal:
        return TransformOrientation.transpose;
    }
  }
}
