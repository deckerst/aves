import 'dart:async';
import 'dart:math';

import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/menu.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ShareQuickChooser extends StatelessWidget {
  final ValueNotifier<ShareAction?> valueNotifier;
  final List<ShareAction> options;
  final bool blurred;
  final PopupMenuPosition chooserPosition;
  final Stream<Offset> pointerGlobalPosition;

  static const _itemPadding = EdgeInsetsDirectional.only(end: 8);

  const ShareQuickChooser({
    super.key,
    required this.valueNotifier,
    required this.options,
    required this.blurred,
    required this.chooserPosition,
    required this.pointerGlobalPosition,
  });

  @override
  Widget build(BuildContext context) {
    return MenuQuickChooser<ShareAction>(
      valueNotifier: valueNotifier,
      options: options,
      autoReverse: false,
      blurred: blurred,
      chooserPosition: chooserPosition,
      pointerGlobalPosition: pointerGlobalPosition,
      itemHeight: kMinInteractiveDimension,
      contentWidth: _computeLargestItemWidth,
      itemBuilder: (context, action) => Padding(
        padding: _itemPadding,
        child: MenuRow(
          text: action.getText(context),
          icon: action.getIcon(),
        ),
      ),
    );
  }

  double? _computeLargestItemWidth(BuildContext context) {
    if (options.isEmpty) return null;

    final textStyle = DefaultTextStyle.of(context).style;
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final iconSize = IconTheme.of(context).size ?? 24;

    return options.map((action) {
      final text = action.getText(context);
      final paragraph = RenderParagraph(
        TextSpan(text: text, style: textStyle),
        textDirection: textDirection,
        textScaler: textScaler,
      )..layout(const BoxConstraints(), parentUsesSize: true);
      final labelWidth = paragraph.getMaxIntrinsicWidth(double.infinity);
      return iconSize + MenuRow.leadingPadding.horizontal + labelWidth + _itemPadding.horizontal;
    }).reduce(max);
  }
}
