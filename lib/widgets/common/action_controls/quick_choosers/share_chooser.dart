import 'dart:async';

import 'package:aves/model/actions/share.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/menu.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class ShareQuickChooser extends StatelessWidget {
  final ValueNotifier<ShareAction?> valueNotifier;
  final List<ShareAction> options;
  final bool autoReverse;
  final bool blurred;
  final PopupMenuPosition chooserPosition;
  final Stream<Offset> pointerGlobalPosition;

  const ShareQuickChooser({
    super.key,
    required this.valueNotifier,
    required this.options,
    required this.autoReverse,
    required this.blurred,
    required this.chooserPosition,
    required this.pointerGlobalPosition,
  });

  @override
  Widget build(BuildContext context) {
    return MenuQuickChooser<ShareAction>(
      valueNotifier: valueNotifier,
      options: options,
      autoReverse: autoReverse,
      blurred: blurred,
      chooserPosition: chooserPosition,
      pointerGlobalPosition: pointerGlobalPosition,
      itemBuilder: (context, action) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: MenuRow(
            text: action.getText(context),
            icon: action.getIcon(),
          ),
        ),
      ),
    );
  }
}
