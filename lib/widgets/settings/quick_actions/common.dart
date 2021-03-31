import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  final bool highlight;
  final Widget child;

  const ActionPanel({
    this.highlight = false,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? Theme.of(context).accentColor : Colors.blueGrey;
    return AnimatedContainer(
      foregroundDecoration: BoxDecoration(
        color: color.withOpacity(.2),
        border: Border.all(
          color: color,
          width: highlight ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(16),
      duration: Durations.quickActionHighlightAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final EntryAction action;
  final bool enabled, showCaption;

  const ActionButton({
    @required this.action,
    this.enabled = true,
    this.showCaption = true,
  });

  static const padding = 8.0;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.caption;
    return SizedBox(
      width: OverlayButton.getSize(context) + padding * 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: padding),
          OverlayButton(
            child: IconButton(
              icon: Icon(action.getIcon()),
              onPressed: enabled ? () {} : null,
            ),
          ),
          if (showCaption) ...[
            SizedBox(height: padding),
            Text(
              action.getText(context),
              style: enabled ? textStyle : textStyle.copyWith(color: textStyle.color.withOpacity(.2)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
          SizedBox(height: padding),
        ],
      ),
    );
  }
}

class DraggedPlaceholder extends StatelessWidget {
  final Widget child;

  const DraggedPlaceholder({
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .2,
      child: child,
    );
  }
}
