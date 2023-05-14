import 'package:aves/ref/unicode.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEditorActionView on EditorAction {
  String getText(BuildContext context) {
    switch (this) {
      case EditorAction.transform:
        return context.l10n.editorActionTransform;
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      case EditorAction.transform:
        return AIcons.transform;
    }
  }
}

extension ExtraCropAspectRatioView on CropAspectRatio {
  String getText(BuildContext context) {
    switch (this) {
      case CropAspectRatio.free:
        return context.l10n.cropAspectRatioFree;
      case CropAspectRatio.original:
        return context.l10n.cropAspectRatioOriginal;
      case CropAspectRatio.square:
        return context.l10n.cropAspectRatioSquare;
      case CropAspectRatio.ar_16_9:
        return '16${UniChars.ratio}9';
      case CropAspectRatio.ar_4_3:
        return '4${UniChars.ratio}3';
    }
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    switch (this) {
      case CropAspectRatio.free:
        return AIcons.aspectRatioFree;
      case CropAspectRatio.original:
        return AIcons.aspectRatioOriginal;
      case CropAspectRatio.square:
        return AIcons.aspectRatioSquare;
      case CropAspectRatio.ar_16_9:
        return AIcons.aspectRatio_16_9;
      case CropAspectRatio.ar_4_3:
        return AIcons.aspectRatio_4_3;
    }
  }
}
