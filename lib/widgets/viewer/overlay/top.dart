import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/overlay/details.dart';
import 'package:aves/widgets/viewer/overlay/minimap.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerTopOverlay extends StatelessWidget {
  final List<AvesEntry> entries;
  final int index;
  final AvesEntry mainEntry;
  final Animation<double> scale;
  final bool hasCollection;
  final EdgeInsets? viewInsets, viewPadding;

  const ViewerTopOverlay({
    super.key,
    required this.entries,
    required this.index,
    required this.mainEntry,
    required this.scale,
    required this.hasCollection,
    required this.viewInsets,
    required this.viewPadding,
  });

  @override
  Widget build(BuildContext context) {
    final multiPageController = mainEntry.isMultiPage ? context.read<MultiPageConductor>().getController(mainEntry) : null;
    return PageEntryBuilder(
      multiPageController: multiPageController,
      builder: (pageEntry) {
        pageEntry ??= mainEntry;

        final showInfo = settings.showOverlayInfo;

        final viewStateConductor = context.read<ViewStateConductor>();
        final viewStateNotifier = viewStateConductor.getOrCreateController(pageEntry);

        final blurred = settings.enableBlurEffect;
        final viewInsetsPadding = (viewInsets ?? EdgeInsets.zero) + (viewPadding ?? EdgeInsets.zero);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showInfo)
              BlurredRect(
                enabled: blurred,
                child: Container(
                  color: Themes.overlayBackgroundColor(brightness: Theme.of(context).brightness, blurred: blurred),
                  child: SafeArea(
                    bottom: false,
                    minimum: EdgeInsets.only(
                      left: viewInsetsPadding.left,
                      top: viewInsetsPadding.top,
                      right: viewInsetsPadding.right,
                    ),
                    child: ViewerDetailOverlay(
                      index: index,
                      entries: entries,
                      hasCollection: hasCollection,
                      multiPageController: multiPageController,
                    ),
                  ),
                ),
              ),
            if (settings.showOverlayMinimap)
              SafeArea(
                top: !showInfo,
                minimum: EdgeInsets.only(
                  left: viewInsetsPadding.left,
                  right: viewInsetsPadding.right,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: FadeTransition(
                    opacity: scale,
                    child: Minimap(
                      viewStateNotifier: viewStateNotifier,
                    ),
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
