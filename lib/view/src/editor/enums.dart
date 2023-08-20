import 'package:aves/ref/unicode.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEditorActionView on EditorAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      EditorAction.transform => l10n.editorActionTransform,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      EditorAction.transform => AIcons.transform,
    };
  }
}

extension ExtraCropAspectRatioView on CropAspectRatio {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      CropAspectRatio.free => l10n.cropAspectRatioFree,
      CropAspectRatio.original => l10n.cropAspectRatioOriginal,
      CropAspectRatio.square => l10n.cropAspectRatioSquare,
      CropAspectRatio.ar_16_9 => '16${UniChars.ratio}9',
      CropAspectRatio.ar_4_3 => '4${UniChars.ratio}3',
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      CropAspectRatio.free => AIcons.aspectRatioFree,
      CropAspectRatio.original => AIcons.aspectRatioOriginal,
      CropAspectRatio.square => AIcons.aspectRatioSquare,
      CropAspectRatio.ar_16_9 => AIcons.aspectRatio_16_9,
      CropAspectRatio.ar_4_3 => AIcons.aspectRatio_4_3,
    };
  }
}
