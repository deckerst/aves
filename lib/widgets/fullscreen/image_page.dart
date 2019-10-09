import 'dart:io';

import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/video.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

class ImagePage extends StatefulWidget {
  final ImageCollection collection;
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
    return PhotoViewGallery.builder(
      itemCount: entries.length,
      builder: (galleryContext, index) {
        final entry = entries[index];
        if (entry.isVideo) {
          final videoController = widget.videoControllers.firstWhere((kv) => kv.item1 == entry.path, orElse: () => null)?.item2;
          return PhotoViewGalleryPageOptions.customChild(
            child: videoController != null
                ? AvesVideo(
                    entry: entry,
                    controller: videoController,
                  )
                : SizedBox(),
            childSize: MediaQuery.of(galleryContext).size,
            heroAttributes: PhotoViewHeroAttributes(
              tag: entry.uri,
              transitionOnUserGestures: true,
            ),
            minScale: PhotoViewComputedScale.contained,
            initialScale: PhotoViewComputedScale.contained,
            onTapUp: (tapContext, details, value) => widget.onTap?.call(),
          );
        }
        return PhotoViewGalleryPageOptions(
          imageProvider: FileImage(File(entry.path)),
          heroAttributes: PhotoViewHeroAttributes(
            tag: entry.uri,
            transitionOnUserGestures: true,
          ),
          minScale: PhotoViewComputedScale.contained,
          initialScale: PhotoViewComputedScale.contained,
          onTapUp: (tapContext, details, value) => widget.onTap?.call(),
        );
      },
      loadingChild: Center(
        child: CircularProgressIndicator(),
      ),
      pageController: widget.pageController,
      onPageChanged: widget.onPageChanged,
      scaleStateChangedCallback: widget.onScaleChanged,
      scrollPhysics: BouncingScrollPhysics(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
