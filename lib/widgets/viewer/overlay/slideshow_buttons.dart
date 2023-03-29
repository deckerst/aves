import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/controls/intents.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/overlay/viewer_buttons.dart';
import 'package:aves/widgets/viewer/slideshow_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlideshowButtons extends StatefulWidget {
  final AnimationController animationController;

  const SlideshowButtons({
    super.key,
    required this.animationController,
  });

  @override
  State<SlideshowButtons> createState() => _SlideshowButtonsState();
}

class _SlideshowButtonsState extends State<SlideshowButtons> {
  final FocusScopeNode _buttonRowFocusScopeNode = FocusScopeNode();
  late Animation<double> _buttonScale;

  static const List<SlideshowAction> _actions = [
    SlideshowAction.resume,
    SlideshowAction.showInCollection,
    SlideshowAction.settings,
  ];
  static const double _padding = ViewerButtonRowContent.padding;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestFocus());
  }

  @override
  void didUpdateWidget(covariant SlideshowButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _buttonRowFocusScopeNode.dispose();
    super.dispose();
  }

  void _registerWidget(SlideshowButtons widget) {
    _buttonScale = CurvedAnimation(
      parent: widget.animationController,
      // a little bounce at the top
      curve: Curves.easeOutBack,
    );
  }

  void _unregisterWidget(SlideshowButtons widget) {
    // nothing
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: _buttonRowFocusScopeNode,
      shortcuts: settings.useTvLayout
          ? const {
              SingleActivator(LogicalKeyboardKey.arrowUp): TvShowLessInfoIntent(),
            }
          : null,
      actions: {
        TvShowLessInfoIntent: CallbackAction<Intent>(onInvoke: (intent) => TvShowLessInfoNotification().dispatch(context)),
      },
      child: settings.useTvLayout
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _actions.map((action) {
                return CaptionedButton(
                  scale: _buttonScale,
                  icon: action.getIcon(),
                  caption: action.getText(context),
                  onPressed: () => _onAction(context, action),
                );
              }).toList(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: _padding / 2, right: _padding / 2, bottom: _padding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _actions
                      .map((action) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: _padding / 2),
                            child: OverlayButton(
                              scale: _buttonScale,
                              child: IconButton(
                                icon: action.getIcon(),
                                onPressed: () => _onAction(context, action),
                                tooltip: action.getText(context),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
    );
  }

  void _onAction(BuildContext context, SlideshowAction action) => SlideshowActionNotification(action).dispatch(context);

  void _requestFocus() => _buttonRowFocusScopeNode.children.firstOrNull?.requestFocus();
}
