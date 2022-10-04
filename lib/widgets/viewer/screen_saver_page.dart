import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/slideshow_interval.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/magnifier/scale/scale_level.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:aves/widgets/viewer/entry_viewer_stack.dart';
import 'package:flutter/material.dart';

class ScreenSaverPage extends StatefulWidget {
  static const routeName = '/screen_saver';

  final CollectionSource source;

  const ScreenSaverPage({
    super.key,
    required this.source,
  });

  @override
  State<ScreenSaverPage> createState() => _ScreenSaverPageState();
}

class _ScreenSaverPageState extends State<ScreenSaverPage> with WidgetsBindingObserver {
  late final ViewerController _viewerController;
  CollectionLens? _slideshowCollection;

  CollectionSource get source => widget.source;

  @override
  void initState() {
    super.initState();
    _viewerController = ViewerController(
      initialScale: ScaleLevel(ref: settings.screenSaverFillScreen ? ScaleReference.covered : ScaleReference.contained),
      transition: settings.screenSaverTransition,
      repeat: true,
      autopilot: true,
      autopilotInterval: settings.screenSaverInterval.getDuration(),
      autopilotAnimatedZoom: settings.screenSaverAnimatedZoomEffect,
    );
    source.stateNotifier.addListener(_onSourceStateChanged);
    _initSlideshowCollection();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    source.stateNotifier.removeListener(_onSourceStateChanged);
    _viewerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewerController.autopilot = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    final collection = _slideshowCollection;
    if (collection == null) {
      child = const SizedBox();
    } else {
      final entries = collection.sortedEntries;
      if (entries.isEmpty) {
        child = EmptyContent(
          icon: AIcons.image,
          text: context.l10n.collectionEmptyImages,
          alignment: Alignment.center,
        );
      } else {
        child = ViewStateConductorProvider(
          child: VideoConductorProvider(
            child: MultiPageConductorProvider(
              child: EntryViewerStack(
                collection: collection,
                initialEntry: entries.first,
                viewerController: _viewerController,
              ),
            ),
          ),
        );
      }
    }

    return MediaQueryDataProvider(
      child: Scaffold(
        body: child,
      ),
    );
  }

  void _onSourceStateChanged() {
    if (_slideshowCollection == null) {
      _initSlideshowCollection();
      if (_slideshowCollection != null) {
        setState(() {});
      }
    }
  }

  void _initSlideshowCollection() {
    if (!source.isReady || _slideshowCollection != null) return;

    final originalCollection = CollectionLens(
      source: source,
      filters: settings.screenSaverCollectionFilters,
    );
    var entries = originalCollection.sortedEntries;
    if (settings.screenSaverVideoPlayback == SlideshowVideoPlayback.skip) {
      entries = entries.where((entry) => !MimeFilter.video.test(entry)).toList();
    }
    entries.shuffle();
    _slideshowCollection = CollectionLens(
      source: originalCollection.source,
      listenToSource: false,
      fixedSort: true,
      fixedSelection: entries,
    );
  }
}
