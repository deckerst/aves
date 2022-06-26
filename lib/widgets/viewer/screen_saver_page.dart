import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/slideshow_interval.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
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

class _ScreenSaverPageState extends State<ScreenSaverPage> {
  late final ViewerController _viewerController;
  CollectionLens? _slideshowCollection;

  CollectionSource get source => widget.source;

  @override
  void initState() {
    super.initState();
    _viewerController = ViewerController(
      transition: settings.screenSaverTransition,
      repeat: true,
      autopilot: true,
      autopilotInterval: settings.screenSaverInterval.getDuration(),
    );
    source.stateNotifier.addListener(_onSourceStateChanged);
    _initSlideshowCollection();
  }

  void _onSourceStateChanged() {
    if (_slideshowCollection == null) {
      _initSlideshowCollection();
      if (_slideshowCollection != null) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    source.stateNotifier.removeListener(_onSourceStateChanged);
    _viewerController.dispose();
    super.dispose();
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

  void _initSlideshowCollection() {
    if (source.stateNotifier.value != SourceState.ready || _slideshowCollection != null) return;

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
