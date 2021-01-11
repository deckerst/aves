import 'package:aves/model/image_entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/magnifier/pan/gesture_detector_scope.dart';
import 'package:aves/widgets/common/magnifier/pan/scroll_physics.dart';
import 'package:aves/widgets/fullscreen/image_view.dart';
import 'package:aves/widgets/fullscreen/multipage_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:tuple/tuple.dart';

class MultiImagePage extends StatefulWidget {
  final CollectionLens collection;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTap;
  final List<Tuple2<String, IjkMediaController>> videoControllers;
  final List<Tuple2<String, MultiPageController>> multiPageControllers;
  final void Function(String uri) onViewDisposed;

  const MultiImagePage({
    this.collection,
    this.pageController,
    this.onPageChanged,
    this.onTap,
    this.videoControllers,
    this.multiPageControllers,
    this.onViewDisposed,
  });

  @override
  State<StatefulWidget> createState() => MultiImagePageState();
}

class MultiImagePageState extends State<MultiImagePage> with AutomaticKeepAliveClientMixin {
  List<ImageEntry> get entries => widget.collection.sortedEntries;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MagnifierGestureDetectorScope(
      axis: [Axis.horizontal, Axis.vertical],
      child: PageView.builder(
        key: Key('horizontal-pageview'),
        scrollDirection: Axis.horizontal,
        controller: widget.pageController,
        physics: MagnifierScrollerPhysics(parent: BouncingScrollPhysics()),
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          final entry = entries[index];

          Widget child;
          if (entry.isMultipage) {
            final multiPageController = _getMultiPageController(entry);
            if (multiPageController != null) {
              child = FutureBuilder<MultiPageInfo>(
                future: multiPageController.info,
                builder: (context, snapshot) {
                  final multiPageInfo = snapshot.data;
                  return ValueListenableBuilder<int>(
                    valueListenable: multiPageController.pageNotifier,
                    builder: (context, page, child) {
                      return _buildViewer(entry, multiPageInfo: multiPageInfo, page: page);
                    },
                  );
                },
              );
            }
          }
          child ??= _buildViewer(entry);

          return ClipRect(
            child: child,
          );
        },
        itemCount: entries.length,
      ),
    );
  }

  ImageView _buildViewer(ImageEntry entry, {MultiPageInfo multiPageInfo, int page = 0}) {
    return ImageView(
      key: Key('imageview'),
      entry: entry,
      multiPageInfo: multiPageInfo,
      page: page,
      heroTag: widget.collection.heroTag(entry),
      onTap: (_) => widget.onTap?.call(),
      videoControllers: widget.videoControllers,
      onDisposed: () => widget.onViewDisposed?.call(entry.uri),
    );
  }

  MultiPageController _getMultiPageController(ImageEntry entry) {
    return widget.multiPageControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2;
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleImagePage extends StatefulWidget {
  final ImageEntry entry;
  final VoidCallback onTap;
  final List<Tuple2<String, IjkMediaController>> videoControllers;
  final List<Tuple2<String, MultiPageController>> multiPageControllers;

  const SingleImagePage({
    this.entry,
    this.onTap,
    this.videoControllers,
    this.multiPageControllers,
  });

  @override
  State<StatefulWidget> createState() => SingleImagePageState();
}

class SingleImagePageState extends State<SingleImagePage> with AutomaticKeepAliveClientMixin {
  ImageEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;
    if (entry.isMultipage) {
      final multiPageController = _getMultiPageController(entry);
      if (multiPageController != null) {
        child = FutureBuilder<MultiPageInfo>(
          future: multiPageController.info,
          builder: (context, snapshot) {
            final multiPageInfo = snapshot.data;
            return ValueListenableBuilder<int>(
              valueListenable: multiPageController.pageNotifier,
              builder: (context, page, child) {
                return _buildViewer(multiPageInfo: multiPageInfo, page: page);
              },
            );
          },
        );
      }
    }
    child ??= _buildViewer();

    return MagnifierGestureDetectorScope(
      axis: [Axis.vertical],
      child: child,
    );
  }

  ImageView _buildViewer({MultiPageInfo multiPageInfo, int page = 0}) {
    return ImageView(
      entry: entry,
      multiPageInfo: multiPageInfo,
      page: page,
      onTap: (_) => widget.onTap?.call(),
      videoControllers: widget.videoControllers,
    );
  }

  MultiPageController _getMultiPageController(ImageEntry entry) {
    return widget.multiPageControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2;
  }

  @override
  bool get wantKeepAlive => true;
}
