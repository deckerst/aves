import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/fullscreen/fullscreen_action_delegate.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:flutter/material.dart';

class FullscreenTopOverlay extends StatelessWidget {
  final List<ImageEntry> entries;
  final int index;
  final Animation<double> scale;
  final EdgeInsets viewInsets, viewPadding;
  final Function(FullscreenAction value) onActionSelected;

  ImageEntry get entry => entries[index];

  const FullscreenTopOverlay({
    Key key,
    @required this.entries,
    @required this.index,
    @required this.scale,
    this.viewInsets,
    this.viewPadding,
    this.onActionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: (viewInsets ?? EdgeInsets.zero) + (viewPadding ?? EdgeInsets.zero),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            OverlayButton(
              scale: scale,
              child: BackButton(),
            ),
            Spacer(),
            OverlayButton(
              scale: scale,
              child: IconButton(
                icon: Icon(Icons.share),
                onPressed: () => onActionSelected?.call(FullscreenAction.share),
                tooltip: 'Share',
              ),
            ),
            SizedBox(width: 8),
            OverlayButton(
              scale: scale,
              child: IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () => onActionSelected?.call(FullscreenAction.delete),
                tooltip: 'Delete',
              ),
            ),
            SizedBox(width: 8),
            OverlayButton(
              scale: scale,
              child: PopupMenuButton<FullscreenAction>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: FullscreenAction.info,
                    child: MenuRow(text: 'Info', icon: Icons.info_outline),
                  ),
                  PopupMenuItem(
                    value: FullscreenAction.rename,
                    child: MenuRow(text: 'Rename', icon: Icons.title),
                  ),
                  if (entry.canRotate)
                    PopupMenuItem(
                      value: FullscreenAction.rotateCCW,
                      child: MenuRow(text: 'Rotate left', icon: Icons.rotate_left),
                    ),
                  if (entry.canRotate)
                    PopupMenuItem(
                      value: FullscreenAction.rotateCW,
                      child: MenuRow(text: 'Rotate right', icon: Icons.rotate_right),
                    ),
                  if (entry.canPrint)
                    PopupMenuItem(
                      value: FullscreenAction.print,
                      child: MenuRow(text: 'Print', icon: Icons.print),
                    ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: FullscreenAction.edit,
                    child: Text('Edit with…'),
                  ),
                  PopupMenuItem(
                    value: FullscreenAction.open,
                    child: Text('Open with…'),
                  ),
                  PopupMenuItem(
                    value: FullscreenAction.setAs,
                    child: Text('Set as…'),
                  ),
                  if (entry.hasGps)
                    PopupMenuItem(
                      value: FullscreenAction.openMap,
                      child: Text('Show on map…'),
                    ),
                ],
                onSelected: onActionSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
