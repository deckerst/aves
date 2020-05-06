import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tuple/tuple.dart';

class MultiImagePage extends StatefulWidget {
  final CollectionLens collection;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<PhotoViewScaleState> onScaleChanged;
  final VoidCallback onTap;
  final List<Tuple2<String, IjkMediaController>> videoControllers;

  const MultiImagePage({
    this.collection,
    this.pageController,
    this.onPageChanged,
    this.onScaleChanged,
    this.onTap,
    this.videoControllers,
  });

  @override
  State<StatefulWidget> createState() => MultiImagePageState();
}

class MultiImagePageState extends State<MultiImagePage> with AutomaticKeepAliveClientMixin {
  List<ImageEntry> get entries => widget.collection.sortedEntries;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    const scrollDirection = Axis.horizontal;
    return PhotoViewGestureDetectorScope(
      axis: scrollDirection,
      child: PageView.builder(
        scrollDirection: scrollDirection,
        controller: widget.pageController,
        physics: const PhotoViewPageViewScrollPhysics(parent: BouncingScrollPhysics()),
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return ImageView(
            entry: entry,
            heroTag: widget.collection.heroTag(entry),
            onScaleChanged: widget.onScaleChanged,
            onTap: widget.onTap,
            videoControllers: widget.videoControllers,
          );
        },
        itemCount: entries.length,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleImagePage extends StatefulWidget {
  final ImageEntry entry;
  final ValueChanged<PhotoViewScaleState> onScaleChanged;
  final VoidCallback onTap;
  final List<Tuple2<String, IjkMediaController>> videoControllers;

  const SingleImagePage({
    this.entry,
    this.onScaleChanged,
    this.onTap,
    this.videoControllers,
  });

  @override
  State<StatefulWidget> createState() => SingleImagePageState();
}

class SingleImagePageState extends State<SingleImagePage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ImageView(
      entry: widget.entry,
      onScaleChanged: widget.onScaleChanged,
      onTap: widget.onTap,
      videoControllers: widget.videoControllers,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
