import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/settings/viewer/slideshow.dart';
import 'package:aves/widgets/viewer/controls/controller.dart';
import 'package:aves/widgets/viewer/entry_viewer_stack.dart';
import 'package:aves/widgets/viewer/providers.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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
  late ViewerController _viewerController;
  late CollectionLens _slideshowCollection;
  AvesEntry? _initialEntry;

  CollectionSource get source => widget.collection.source;

  @override
  void initState() {
    super.initState();
    _initViewerController(autopilot: true);
    _initSlideshowCollection();
    _initialEntry = _slideshowCollection.sortedEntries.firstOrNull;
  }

  @override
  void dispose() {
    _disposeViewerController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialEntry = _initialEntry;
    return ListenableProvider<ValueNotifier<AppMode>>.value(
      value: ValueNotifier(AppMode.slideshow),
      child: AvesScaffold(
        body: initialEntry == null
            ? EmptyContent(
                icon: AIcons.image,
                text: context.l10n.collectionEmptyImages,
                alignment: Alignment.center,
              )
            : MultiProvider(
                providers: [
                  ViewStateConductorProvider(),
                  VideoConductorProvider(),
                  MultiPageConductorProvider(),
                ],
                child: NotificationListener<SlideshowActionNotification>(
                  onNotification: (notification) {
                    _onActionSelected(notification.action);
                    return true;
                  },
                  child: EntryViewerStack(
                    key: ValueKey(_viewerController),
                    collection: _slideshowCollection,
                    initialEntry: initialEntry,
                    viewerController: _viewerController,
                  ),
                ),
              ),
      ),
    );
  }

  void _initViewerController({required bool autopilot}) {
    _viewerController = ViewerController(
      initialScale: ScaleLevel(ref: settings.slideshowFillScreen ? ScaleReference.covered : ScaleReference.contained),
      transition: settings.slideshowTransition,
      repeat: settings.slideshowRepeat,
      autopilot: autopilot,
      autopilotInterval: Duration(seconds: settings.slideshowInterval),
      autopilotAnimatedZoom: settings.slideshowAnimatedZoomEffect,
    );
  }

  void _disposeViewerController() => _viewerController.dispose();

  void _initSlideshowCollection() {
    var entries = List.of(widget.collection.sortedEntries);
    if (settings.slideshowVideoPlayback == SlideshowVideoPlayback.skip) {
      entries = entries.where((entry) => !MimeFilter.video.test(entry)).toList();
    }
    if (settings.slideshowShuffle) {
      entries.shuffle();
    }
    _slideshowCollection = CollectionLens(
      source: source,
      listenToSource: false,
      fixedSort: true,
      fixedSelection: entries,
    );
  }

  void _onActionSelected(SlideshowAction action) {
    switch (action) {
      case SlideshowAction.resume:
        _viewerController.autopilot = true;
      case SlideshowAction.showInCollection:
        _showInCollection();
      case SlideshowAction.settings:
        _showSettings(context);
    }
  }

  void _showInCollection() {
    final currentEntry = _viewerController.entryNotifier.value;
    if (currentEntry == null) return;

    final album = currentEntry.directory;
    final uri = currentEntry.uri;

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

  Tuple2<bool, bool> get collectionSettings => Tuple2(settings.slideshowShuffle, settings.slideshowVideoPlayback == SlideshowVideoPlayback.skip);

  Future<void> _showSettings(BuildContext context) async {
    final oldCollectionSettings = collectionSettings;
    final currentEntry = _viewerController.entryNotifier.value;

    await Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: ViewerSlideshowPage.routeName),
        builder: (context) => const ViewerSlideshowPage(),
      ),
    );

    _disposeViewerController();
    _initViewerController(autopilot: false);
    if (oldCollectionSettings != collectionSettings) {
      _initSlideshowCollection();
    }
    final slideshowEntries = _slideshowCollection.sortedEntries;
    _initialEntry = slideshowEntries.contains(currentEntry) ? currentEntry : slideshowEntries.firstOrNull;
    setState(() {});
  }
}

class SlideshowActionNotification extends Notification {
  final SlideshowAction action;

  SlideshowActionNotification(this.action);
}
