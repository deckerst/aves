import 'package:aves/ref/unicode.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraEditorActionView on EditorAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .transform => l10n.editorActionTransform,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      .transform => AIcons.transform,
    };
  }
}

extension ExtraCropAspectRatioView on CropAspectRatio {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .free => l10n.cropAspectRatioFree,
      .original => l10n.cropAspectRatioOriginal,
      .square => l10n.cropAspectRatioSquare,
      .ar_16_9 => '16${UniChars.ratio}9',
      .ar_4_3 => '4${UniChars.ratio}3',
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      .free => AIcons.aspectRatioFree,
      .original => AIcons.aspectRatioOriginal,
      .square => AIcons.aspectRatioSquare,
      .ar_16_9 => AIcons.aspectRatio_16_9,
      .ar_4_3 => AIcons.aspectRatio_4_3,
    };
  }
}
