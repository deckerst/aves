import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
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
  final EdgeInsets? viewInsets, viewPadding;
  final bool hasCollection;

  const ViewerTopOverlay({
    Key? key,
    required this.entries,
    required this.index,
    required this.mainEntry,
    required this.scale,
    required this.hasCollection,
    required this.viewInsets,
    required this.viewPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget child;

    if (mainEntry.isMultiPage) {
      final multiPageController = context.read<MultiPageConductor>().getController(mainEntry);
      child = PageEntryBuilder(
        multiPageController: multiPageController,
        builder: (pageEntry) => _buildOverlay(
          context,
          mainEntry,
          pageEntry: pageEntry,
          multiPageController: multiPageController,
        ),
      );
    } else {
      child = _buildOverlay(context, mainEntry);
    }

    return child;
  }

  Widget _buildOverlay(
    BuildContext context,
    AvesEntry mainEntry, {
    AvesEntry? pageEntry,
    MultiPageController? multiPageController,
  }) {
    pageEntry ??= mainEntry;

    final showInfo = settings.showOverlayInfo;

    final viewStateConductor = context.read<ViewStateConductor>();
    final viewStateNotifier = viewStateConductor.getOrCreateController(pageEntry);

    final blurred = settings.enableOverlayBlurEffect;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showInfo)
          BlurredRect(
            enabled: blurred,
            child: Container(
              color: overlayBackgroundColor(blurred: blurred),
              child: SafeArea(
                minimum: EdgeInsets.only(top: (viewInsets?.top ?? 0) + (viewPadding?.top ?? 0)),
                bottom: false,
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
  }
}
