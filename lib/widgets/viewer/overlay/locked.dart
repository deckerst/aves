import 'dart:math';

import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/overlay/viewer_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerLockedOverlay extends StatefulWidget {
  final AnimationController animationController;
  final EdgeInsets? viewInsets, viewPadding;

  const ViewerLockedOverlay({
    super.key,
    required this.animationController,
    this.viewInsets,
    this.viewPadding,
  });

  @override
  State<StatefulWidget> createState() => _ViewerLockedOverlayState();
}

class _ViewerLockedOverlayState extends State<ViewerLockedOverlay> {
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ViewerLockedOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(ViewerLockedOverlay widget) {
    _buttonScale = CurvedAnimation(
      parent: widget.animationController,
      // a little bounce at the top
      curve: Curves.easeOutBack,
    );
  }

  void _unregisterWidget(ViewerLockedOverlay widget) {
    // nothing
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MediaQueryData, double>(
      selector: (context, mq) => max(mq.effectiveBottomPadding, mq.systemGestureInsets.bottom),
      builder: (context, mqPaddingBottom, child) {
        final viewInsetsPadding = (widget.viewInsets ?? EdgeInsets.zero) + (widget.viewPadding ?? EdgeInsets.zero);
        return Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(bottom: mqPaddingBottom) + const EdgeInsets.all(ViewerButtonRowContent.padding),
          child: SafeArea(
            top: false,
            bottom: false,
            minimum: EdgeInsets.only(
              left: viewInsetsPadding.left,
              right: viewInsetsPadding.right,
            ),
            child: OverlayButton(
              scale: _buttonScale,
              child: IconButton(
                icon: const Icon(AIcons.viewerUnlock),
                onPressed: () => const LockViewNotification(locked: false).dispatch(context),
                tooltip: context.l10n.viewerActionUnlock,
              ),
            ),
          ),
        );
      },
    );
  }
}
