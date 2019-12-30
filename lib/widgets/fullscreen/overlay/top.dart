import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/menu_row.dart';
import 'package:aves/widgets/fullscreen/fullscreen_action_delegate.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

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
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            OverlayButton(
              scale: scale,
              child: const BackButton(),
            ),
            const Spacer(),
            OverlayButton(
              scale: scale,
              child: IconButton(
                icon: Icon(OMIcons.share),
                onPressed: () => onActionSelected?.call(FullscreenAction.share),
                tooltip: 'Share',
              ),
            ),
            const SizedBox(width: 8),
            OverlayButton(
              scale: scale,
              child: IconButton(
                icon: Icon(OMIcons.delete),
                onPressed: () => onActionSelected?.call(FullscreenAction.delete),
                tooltip: 'Delete',
              ),
            ),
            const SizedBox(width: 8),
            OverlayButton(
              scale: scale,
              child: PopupMenuButton<FullscreenAction>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: FullscreenAction.info,
                    child: MenuRow(text: 'Info', icon: OMIcons.info),
                  ),
                  PopupMenuItem(
                    value: FullscreenAction.rename,
                    child: MenuRow(text: 'Rename', icon: OMIcons.title),
                  ),
                  if (entry.canRotate)
                    PopupMenuItem(
                      value: FullscreenAction.rotateCCW,
                      child: MenuRow(text: 'Rotate left', icon: OMIcons.rotateLeft),
                    ),
                  if (entry.canRotate)
                    PopupMenuItem(
                      value: FullscreenAction.rotateCW,
                      child: MenuRow(text: 'Rotate right', icon: OMIcons.rotateRight),
                    ),
                  if (entry.canPrint)
                    PopupMenuItem(
                      value: FullscreenAction.print,
                      child: MenuRow(text: 'Print', icon: OMIcons.print),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: FullscreenAction.edit,
                    child: Text('Edit with…'),
                  ),
                  const PopupMenuItem(
                    value: FullscreenAction.open,
                    child: Text('Open with…'),
                  ),
                  const PopupMenuItem(
                    value: FullscreenAction.setAs,
                    child: Text('Set as…'),
                  ),
                  if (entry.hasGps)
                    const PopupMenuItem(
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
