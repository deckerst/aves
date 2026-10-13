import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_video/aves_video.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class const VideoCover({
  super.key,
  required final AvesEntry mainEntry,
  required final AvesEntry pageEntry,
  required final AvesMagnifierController magnifierController,
  required final AvesVideoController videoController,
  required final Size videoDisplaySize,
  required final void Function({Alignment? alignment}) onTap,
  required final Widget Function(
    AvesMagnifierController coverController,
    Size coverSize,
    ImageProvider videoCoverUriImage,
  )
  magnifierBuilder,
}) extends StatefulWidget {
  @override
  State<VideoCover> createState() => _VideoCoverState();
}

class _VideoCoverState extends State<VideoCover> {
  ImageStream? _videoCoverStream;
  late ImageStreamListener _videoCoverStreamListener;
  final ValueNotifier<ImageInfo?> _videoCoverInfoNotifier = ValueNotifier(null);

  AvesMagnifierController? _dismissedCoverMagnifierController;

  AvesMagnifierController get dismissedCoverMagnifierController {
    _dismissedCoverMagnifierController ??= AvesMagnifierController();
    return _dismissedCoverMagnifierController!;
  }

  AvesEntry get mainEntry => widget.mainEntry;

  AvesEntry get entry => widget.pageEntry;

  AvesMagnifierController get magnifierController => widget.magnifierController;

  AvesVideoController get videoController => widget.videoController;

  Size get videoDisplaySize => widget.videoDisplaySize;

  // use the high res photo as cover for the video part of a motion photo
  ImageProvider get videoCoverUriImage => (mainEntry.isMotionPhoto ? mainEntry : entry).getFullImage();

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant VideoCover oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pageEntry != widget.pageEntry) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _dismissedCoverMagnifierController?.dispose();
    _videoCoverInfoNotifier.dispose();
    super.dispose();
  }

  void _registerWidget(VideoCover widget) {
    _videoCoverStreamListener = ImageStreamListener((image, _) => _videoCoverInfoNotifier.value = image);
    _videoCoverStream = videoCoverUriImage.resolve(ImageConfiguration.empty);
    _videoCoverStream!.addListener(_videoCoverStreamListener);
  }

  void _unregisterWidget(VideoCover oldWidget) {
    _videoCoverStream?.removeListener(_videoCoverStreamListener);
    _videoCoverStream = null;
    _videoCoverInfoNotifier.value = null;
  }

  @override
  Widget build(BuildContext context) {
    // fade out image to ease transition with the player
    return StreamBuilder<PlaybackStatus>(
      stream: videoController.statusStream,
      builder: (context, _) {
        return StreamBuilder<int>(
          stream: videoController.positionStream,
          builder: (context, _) {
            final showCover = !(videoController.isReady && videoController.currentPosition > 0);
            return IgnorePointer(
              ignoring: !showCover,
              child: AnimatedOpacity(
                opacity: showCover ? 1 : 0,
                curve: Curves.easeInCirc,
                // instant transition when the cover is the first frame
                duration: settings.videoThumbnailMethods.firstOrNull == .first ? Duration.zero : ADurations.viewerVideoPlayerTransition,
                onEnd: () {
                  // while cover is fading out, the same controller is used for both the cover and the video,
                  // and both fire scale boundaries events, so we make sure that in the end
                  // the scale boundaries from the video are used after the cover is gone
                  final boundaries = magnifierController.scaleBoundaries;
                  if (boundaries != null) {
                    magnifierController.setScaleBoundaries(
                      boundaries.copyWith(
                        contentSize: videoDisplaySize,
                      ),
                    );
                  }
                },
                child: ValueListenableBuilder<ImageInfo?>(
                  valueListenable: _videoCoverInfoNotifier,
                  builder: (context, videoCoverInfo, child) {
                    if (videoCoverInfo != null) {
                      // full cover image may have a different size and different aspect ratio
                      final coverSize = Size(
                        videoCoverInfo.image.width.toDouble(),
                        videoCoverInfo.image.height.toDouble(),
                      );
                      // when the cover is the same size as the video itself
                      // (which is often the case when the cover is not embedded but just a frame),
                      // we can reuse the same magnifier and preserve its state when switching from cover to video
                      final coverController = showCover || coverSize == videoDisplaySize ? magnifierController : dismissedCoverMagnifierController;
                      return widget.magnifierBuilder(coverController, coverSize, videoCoverUriImage);
                    }

                    // default to cached thumbnail, if any
                    final extent = entry.cachedThumbnails.firstOrNull?.key.extent;
                    if (extent != null && extent > 0) {
                      return GestureDetector(
                        onTap: widget.onTap,
                        child: ThumbnailImage(
                          entry: entry,
                          extent: extent,
                          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                          fit: BoxFit.contain,
                          showLoadingBackground: false,
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
