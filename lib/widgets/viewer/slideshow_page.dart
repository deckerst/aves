import 'package:aves/app_mode.dart';
import 'package:aves/model/actions/slideshow_actions.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:aves/widgets/viewer/entry_viewer_stack.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SlideshowPage extends StatefulWidget {
  static const routeName = '/collection/slideshow';

  final CollectionLens collection;

  const SlideshowPage({
    super.key,
    required this.collection,
  });

  @override
  State<SlideshowPage> createState() => _SlideshowPageState();
}

class _SlideshowPageState extends State<SlideshowPage> {
  late final ViewerController _viewerController;
  late final CollectionLens _slideshowCollection;

  @override
  void initState() {
    super.initState();
    _viewerController = ViewerController(
      initialScale: ScaleLevel(ref: settings.slideshowFillScreen ? ScaleReference.covered : ScaleReference.contained),
      transition: settings.slideshowTransition,
      repeat: settings.slideshowRepeat,
      autopilot: true,
      autopilotInterval: Duration(seconds: settings.slideshowInterval),
      autopilotAnimatedZoom: settings.slideshowAnimatedZoomEffect,
    );
    _initSlideshowCollection();
  }

  @override
  void dispose() {
    _viewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _slideshowCollection.sortedEntries;
    return ListenableProvider<ValueNotifier<AppMode>>.value(
      value: ValueNotifier(AppMode.slideshow),
      child: AvesScaffold(
        body: entries.isEmpty
            ? EmptyContent(
                icon: AIcons.image,
                text: context.l10n.collectionEmptyImages,
                alignment: Alignment.center,
              )
            : ViewStateConductorProvider(
                child: VideoConductorProvider(
                  child: MultiPageConductorProvider(
                    child: NotificationListener<SlideshowActionNotification>(
                      onNotification: (notification) {
                        _onActionSelected(notification.action);
                        return true;
                      },
                      child: EntryViewerStack(
                        collection: _slideshowCollection,
                        initialEntry: entries.first,
                        viewerController: _viewerController,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _initSlideshowCollection() {
    final originalCollection = widget.collection;
    var entries = originalCollection.sortedEntries;
    if (settings.slideshowVideoPlayback == SlideshowVideoPlayback.skip) {
      entries = entries.where((entry) => !MimeFilter.video.test(entry)).toList();
    }
    if (settings.slideshowShuffle) {
      entries.shuffle();
    }
    _slideshowCollection = CollectionLens(
      source: originalCollection.source,
      listenToSource: false,
      fixedSort: true,
      fixedSelection: entries,
    );
  }

  void _onActionSelected(SlideshowAction action) {
    switch (action) {
      case SlideshowAction.resume:
        _viewerController.autopilot = true;
        break;
      case SlideshowAction.showInCollection:
        _showInCollection();
        break;
    }
  }

  void _showInCollection() {
    final entry = _viewerController.entryNotifier.value;
    if (entry == null) return;

    final source = _slideshowCollection.source;
    final album = entry.directory;
    final uri = entry.uri;

    Navigator.maybeOf(context)?.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: source,
          filters: album != null ? {AlbumFilter(album, source.getAlbumDisplayName(context, album))} : null,
          highlightTest: (entry) => entry.uri == uri,
        ),
      ),
      (route) => false,
    );
  }
}

class SlideshowActionNotification extends Notification {
  final SlideshowAction action;

  SlideshowActionNotification(this.action);
}
