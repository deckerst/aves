import 'package:aves/model/actions/slideshow_actions.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/viewer_buttons.dart';
import 'package:aves/widgets/viewer/slideshow_page.dart';
import 'package:flutter/material.dart';

class SlideshowButtons extends StatelessWidget {
  final Animation<double> scale;

  const SlideshowButtons({
    super.key,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    const padding = ViewerButtonRowContent.padding;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: padding / 2, right: padding / 2, bottom: padding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SlideshowAction.resume,
            SlideshowAction.showInCollection,
          ]
              .map((action) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding / 2),
                    child: OverlayButton(
                      scale: scale,
                      child: IconButton(
                        icon: action.getIcon(),
                        onPressed: () => SlideshowActionNotification(action).dispatch(context),
                        tooltip: action.getText(context),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
