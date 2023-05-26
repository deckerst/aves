enum EditorAction { transform }

enum CropAspectRatio { free, original, square, ar_16_9, ar_4_3 }

enum TransformActivity { none, pan, resize, straighten }

enum TransformOrientation { normal, rotate90, rotate180, rotate270, transverse, flipVertical, transpose, flipHorizontal }

extension ExtraTransformOrientation on TransformOrientation {
  TransformOrientation flipHorizontally() {
    switch (this) {
      case TransformOrientation.normal:
        return TransformOrientation.flipHorizontal;
      case TransformOrientation.rotate90:
        return TransformOrientation.transverse;
      case TransformOrientation.rotate180:
        return TransformOrientation.flipVertical;
      case TransformOrientation.rotate270:
        return TransformOrientation.transpose;
      case TransformOrientation.transverse:
        return TransformOrientation.rotate90;
      case TransformOrientation.flipVertical:
        return TransformOrientation.rotate180;
      case TransformOrientation.transpose:
        return TransformOrientation.rotate270;
      case TransformOrientation.flipHorizontal:
        return TransformOrientation.normal;
    }
  }

  bool get isFlipped {
    switch (this) {
      case TransformOrientation.normal:
      case TransformOrientation.rotate90:
      case TransformOrientation.rotate180:
      case TransformOrientation.rotate270:
        return false;
      case TransformOrientation.transverse:
      case TransformOrientation.flipVertical:
      case TransformOrientation.transpose:
      case TransformOrientation.flipHorizontal:
        return true;
    }
  }

  TransformOrientation rotateClockwise() {
    switch (this) {
      case TransformOrientation.normal:
        return TransformOrientation.rotate90;
      case TransformOrientation.rotate90:
        return TransformOrientation.rotate180;
      case TransformOrientation.rotate180:
        return TransformOrientation.rotate270;
      case TransformOrientation.rotate270:
        return TransformOrientation.normal;
      case TransformOrientation.transverse:
        return TransformOrientation.flipHorizontal;
      case TransformOrientation.flipVertical:
        return TransformOrientation.transverse;
      case TransformOrientation.transpose:
        return TransformOrientation.flipVertical;
      case TransformOrientation.flipHorizontal:
        return TransformOrientation.transpose;
    }
  }
}
