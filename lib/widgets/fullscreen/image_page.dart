import 'dart:io';

import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/video.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

class ImagePage extends StatefulWidget {
  final CollectionLens collection;
  final PageController pageController;
  final VoidCallback onTap;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<PhotoViewScaleState> onScaleChanged;
  final List<Tuple2<String, VideoPlayerController>> videoControllers;

  const ImagePage({
    this.collection,
    this.pageController,
    this.onTap,
    this.onPageChanged,
    this.onScaleChanged,
    this.videoControllers,
  });

  @override
  State<StatefulWidget> createState() => ImagePageState();
}

class ImagePageState extends State<ImagePage> with AutomaticKeepAliveClientMixin {
  List<ImageEntry> get entries => widget.collection.sortedEntries;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    const scrollDirection = Axis.horizontal;
    const backgroundDecoration = BoxDecoration(color: Colors.transparent);
    final scaleStateChangedCallback = widget.onScaleChanged;

    return PhotoViewGestureDetectorScope(
      axis: scrollDirection,
      child: PageView.builder(
        controller: widget.pageController,
        onPageChanged: widget.onPageChanged,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          if (entry.isVideo) {
            final videoController = widget.videoControllers.firstWhere((kv) => kv.item1 == entry.path, orElse: () => null)?.item2;
            return PhotoView.customChild(
              child: videoController != null
                  ? AvesVideo(
                      entry: entry,
                      controller: videoController,
                    )
                  : const SizedBox(),
              backgroundDecoration: backgroundDecoration,
              // no hero as most videos fullscreen image is different from its thumbnail
              scaleStateChangedCallback: scaleStateChangedCallback,
              minScale: PhotoViewComputedScale.contained,
              initialScale: PhotoViewComputedScale.contained,
              onTapUp: (tapContext, details, value) => widget.onTap?.call(),
            );
          }
          return PhotoView(
            // key includes size and orientation to refresh when the image is rotated
            key: ValueKey('${entry.orientationDegrees}_${entry.width}_${entry.height}_${entry.path}'),
            imageProvider: FileImage(File(entry.path)),
            loadingBuilder: (context, event) => const Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
            backgroundDecoration: backgroundDecoration,
            heroAttributes: PhotoViewHeroAttributes(
              tag: entry.uri,
              transitionOnUserGestures: true,
            ),
            scaleStateChangedCallback: scaleStateChangedCallback,
            minScale: PhotoViewComputedScale.contained,
            initialScale: PhotoViewComputedScale.contained,
            onTapUp: (tapContext, details, value) => widget.onTap?.call(),
            filterQuality: FilterQuality.low,
          );
        },
        scrollDirection: scrollDirection,
        physics: const BouncingScrollPhysics(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
