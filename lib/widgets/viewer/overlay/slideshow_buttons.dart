import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/controls/intents.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves/widgets/viewer/overlay/viewer_buttons.dart';
import 'package:aves/widgets/viewer/slideshow_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SlideshowBottomOverlay extends StatelessWidget {
  final AnimationController animationController;
  final Size availableSize;
  final EdgeInsets? viewInsets, viewPadding;

  const SlideshowBottomOverlay({
    super.key,
    required this.animationController,
    required this.availableSize,
    this.viewInsets,
    this.viewPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MediaQueryData, double>(
      selector: (context, mq) => max(mq.effectiveBottomPadding, mq.systemGestureInsets.bottom),
      builder: (context, mqPaddingBottom, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: mqPaddingBottom),
          child: child,
        );
      },
      child: SlideshowButtons(
        availableSize: availableSize,
        viewInsets: viewInsets,
        viewPadding: viewPadding,
        animationController: animationController,
      ),
    );
  }
}

class SlideshowButtons extends StatefulWidget {
  final Size availableSize;
  final EdgeInsets? viewInsets, viewPadding;
  final AnimationController animationController;

  const SlideshowButtons({
    super.key,
    required this.availableSize,
    required this.viewInsets,
    required this.viewPadding,
    required this.animationController,
  });

  @override
  State<SlideshowButtons> createState() => _SlideshowButtonsState();
}

class _SlideshowButtonsState extends State<SlideshowButtons> {
  final FocusScopeNode _buttonRowFocusScopeNode = FocusScopeNode();
  late CurvedAnimation _buttonScale;

  static const List<SlideshowAction> _actions = [
    SlideshowAction.resume,
    SlideshowAction.showInCollection,
    SlideshowAction.cast,
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
    _buttonScale.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsPadding = (widget.viewInsets ?? EdgeInsets.zero) + (widget.viewPadding ?? EdgeInsets.zero);
    final viewerButtonRow = FocusableActionDetector(
      focusNode: _buttonRowFocusScopeNode,
      shortcuts: settings.useTvLayout
          ? const {
              SingleActivator(LogicalKeyboardKey.arrowUp): TvShowLessInfoIntent(),
            }
          : null,
      actions: {
        TvShowLessInfoIntent: CallbackAction<Intent>(onInvoke: (intent) => TvShowLessInfoNotification().dispatch(context)),
      },
      child: SafeArea(
        top: false,
        bottom: false,
        minimum: EdgeInsets.only(
          left: viewInsetsPadding.left,
          right: viewInsetsPadding.right,
        ),
        child: _buildButtons(context),
      ),
    );

    final availableWidth = widget.availableSize.width;
    return SizedBox(
      width: availableWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          viewerButtonRow,
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (settings.useTvLayout) {
      return _buildTvButtonRowContent(context);
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: _padding / 2, right: _padding / 2, bottom: _padding),
        child: Row(
          textDirection: ViewerBottomOverlay.actionsDirection,
          children: [
            const Spacer(),
            ..._actions.map((action) => _buildOverlayButton(context, action)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayButton(BuildContext context, SlideshowAction action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _padding / 2),
      child: OverlayButton(
        scale: _buttonScale,
        child: IconButton(
          icon: action.getIcon(),
          onPressed: () => _onAction(context, action),
          tooltip: action.getText(context),
        ),
      ),
    );
  }

  Widget _buildTvButtonRowContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: ViewerBottomOverlay.actionsDirection,
      children: _actions.map((action) {
        return CaptionedButton(
          scale: _buttonScale,
          icon: action.getIcon(),
          caption: action.getText(context),
          onPressed: () => _onAction(context, action),
        );
      }).toList(),
    );
  }

  void _onAction(BuildContext context, SlideshowAction action) {
    switch (action) {
      case SlideshowAction.cast:
        const CastNotification(true).dispatch(context);
      default:
        SlideshowActionNotification(action).dispatch(context);
    }
  }

  void _requestFocus() => _buttonRowFocusScopeNode.children.firstOrNull?.requestFocus();
}
