enum EditorAction { transform }

enum CropAspectRatio { free, original, square, ar_16_9, ar_4_3 }

enum TransformActivity { none, pan, resize, straighten }

enum TransformOrientation { normal, rotate90, rotate180, rotate270, transverse, flipVertical, transpose, flipHorizontal }

extension ExtraTransformOrientation on TransformOrientation {
  TransformOrientation flipHorizontally() {
    switch (this) {
      case .normal:
        return .flipHorizontal;
      case .rotate90:
        return .transverse;
      case .rotate180:
        return .flipVertical;
      case .rotate270:
        return .transpose;
      case .transverse:
        return .rotate90;
      case .flipVertical:
        return .rotate180;
      case .transpose:
        return .rotate270;
      case .flipHorizontal:
        return .normal;
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
        return .rotate90;
      case .rotate90:
        return .rotate180;
      case .rotate180:
        return .rotate270;
      case .rotate270:
        return .normal;
      case .transverse:
        return .flipHorizontal;
      case .flipVertical:
        return .transverse;
      case .transpose:
        return .flipVertical;
      case .flipHorizontal:
        return .transpose;
    }
  }
}
