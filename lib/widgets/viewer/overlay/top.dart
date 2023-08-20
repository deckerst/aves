import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/overlay/details/details.dart';
import 'package:aves/widgets/viewer/overlay/histogram.dart';
import 'package:aves/widgets/viewer/overlay/minimap.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves/widgets/viewer/view/conductor.dart';
import 'package:aves/widgets/viewer/view/controller.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerTopOverlay extends StatelessWidget {
  final List<AvesEntry> entries;
  final int index;
  final AvesEntry mainEntry;
  final Animation<double> scale;
  final bool hasCollection;
  final ValueNotifier<bool> expandedNotifier;
  final Size availableSize;
  final EdgeInsets? viewInsets, viewPadding;

  static const Color componentBorderColor = Colors.white30;
  static const double componentDimension = 96;

  const ViewerTopOverlay({
    super.key,
    required this.entries,
    required this.index,
    required this.mainEntry,
    required this.scale,
    required this.hasCollection,
    required this.expandedNotifier,
    required this.availableSize,
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
        final viewStateNotifier = viewStateConductor.getOrCreateController(pageEntry).viewStateNotifier;

        final blurred = settings.enableBlurEffect;
        final viewInsetsPadding = (viewInsets ?? EdgeInsets.zero) + (viewPadding ?? EdgeInsets.zero);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showInfo)
              GestureDetector(
                onTap: () => expandedNotifier.value = !expandedNotifier.value,
                child: BlurredRect(
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
                        expandedNotifier: expandedNotifier,
                        availableSize: availableSize,
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  ),
                const Spacer(),
                if (settings.overlayHistogramStyle != OverlayHistogramStyle.none)
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
                        child: Selector<ViewStateConductor, ViewStateController>(
                          selector: (context, vsc) => vsc.getOrCreateController(pageEntry!),
                          builder: (context, viewStateController, child) {
                            return ValueListenableBuilder<ImageProvider?>(
                              valueListenable: viewStateController.fullImageNotifier,
                              builder: (context, fullImage, child) {
                                if (fullImage == null || pageEntry == null) return const SizedBox();
                                return ImageHistogram(
                                  viewStateController: viewStateController,
                                  image: fullImage,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
