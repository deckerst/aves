import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/share_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/common/button.dart';
import 'package:aves/widgets/common/action_controls/quick_choosers/share_chooser.dart';
import 'package:flutter/material.dart';

class ShareButton extends ChooserQuickButton<ShareAction> {
  final Set<AvesEntry> entries;

  const ShareButton({
    super.key,
    required super.blurred,
    required this.entries,
    super.onChooserValue,
    super.focusNode,
    required super.onPressed,
  });

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends ChooserQuickButtonState<ShareButton, ShareAction> {
  EntryAction get action => EntryAction.share;

  @override
  Widget get icon => action.getIcon();

  @override
  String get tooltip => action.getText(context);

  @override
  bool get hasChooser => super.hasChooser && options.isNotEmpty;

  List<ShareAction> get options => [
        if (widget.entries.any((entry) => entry.isMotionPhoto)) ...[
          ShareAction.imageOnly,
          ShareAction.videoOnly,
        ],
      ];

  @override
  Widget buildChooser(Animation<double> animation, PopupMenuPosition chooserPosition) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        alignment: chooserPosition == PopupMenuPosition.over ? Alignment.bottomCenter : Alignment.topCenter,
        child: ShareQuickChooser(
          valueNotifier: chooserValueNotifier,
          options: options,
          autoReverse: false,
          blurred: widget.blurred,
          chooserPosition: chooserPosition,
          pointerGlobalPosition: pointerGlobalPosition,
        ),
      ),
    );
  }
}
