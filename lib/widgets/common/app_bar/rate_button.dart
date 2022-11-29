import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/chooser_button.dart';
import 'package:aves/widgets/common/app_bar/quick_choosers/rate_chooser.dart';
import 'package:flutter/material.dart';

class RateButton extends ChooserQuickButton<int> {
  const RateButton({
    super.key,
    super.chooserPosition,
    super.onChooserValue,
    required super.onPressed,
  });

  @override
  State<RateButton> createState() => _RateQuickButtonState();
}

class _RateQuickButtonState extends ChooserQuickButtonState<RateButton, int> {
  static const _action = EntryAction.editRating;

  @override
  Widget get icon => _action.getIcon();

  @override
  String get tooltip => _action.getText(context);

  @override
  int? get defaultValue => 3;

  @override
  Widget buildChooser(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: RateQuickChooser(
          ratingNotifier: chooserValueNotifier,
          moveUpdates: moveUpdates,
        ),
      ),
    );
  }
}
