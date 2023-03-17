import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:flutter/material.dart';

class ItemPicker extends StatelessWidget {
  final double extent;
  final AvesEntry entry;
  final GestureTapCallback? onTap;

  const ItemPicker({
    super.key,
    required this.extent,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageBorderRadius = BorderRadius.all(Radius.circular(extent * .25));
    final actionBoxDimension = min(40.0, extent * .4);
    final actionBoxBorderRadius = BorderRadiusDirectional.only(topStart: Radius.circular(actionBoxDimension * .6));
    return Tooltip(
      message: context.l10n.changeTooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: AvesBorder.border(context),
            borderRadius: imageBorderRadius,
          ),
          child: ClipRRect(
            borderRadius: imageBorderRadius,
            child: SizedBox(
              width: extent,
              height: extent,
              child: Stack(
                children: [
                  ThumbnailImage(
                    entry: entry,
                    extent: extent,
                  ),
                  PositionedDirectional(
                    end: -1,
                    bottom: -1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xAA000000) : const Color(0xCCFFFFFF),
                        border: AvesBorder.border(context),
                        borderRadius: actionBoxBorderRadius,
                      ),
                      width: actionBoxDimension,
                      height: actionBoxDimension,
                      child: Icon(
                        AIcons.edit,
                        size: actionBoxDimension * .6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
