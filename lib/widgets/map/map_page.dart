import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/map/controller.dart';
import 'package:aves/widgets/common/map/geo_map.dart';
import 'package:aves/widgets/common/map/theme.dart';
import 'package:aves/widgets/common/map/zoomed_bounds.dart';
import 'package:aves/widgets/common/providers/highlight_info_provider.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/thumbnail/scroller.dart';
import 'package:aves/widgets/map/map_info_row.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  static const routeName = '/collection/map';

  final CollectionLens collection;
  final AvesEntry? initialEntry;

  const MapPage({
    Key? key,
    required this.collection,
    this.initialEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // do not rely on the `HighlightInfoProvider` app level
    // as the map can be stacked on top of other pages
    // that catch highlight events and will not let it bubble up
    return HighlightInfoProvider(
      child: MediaQueryDataProvider(
        child: Scaffold(
          body: SafeArea(
            left: false,
            top: false,
            right: false,
            bottom: true,
            child: MapPageContent(
              collection: collection,
              initialEntry: initialEntry,
            ),
          ),
        ),
      ),
    );
  }
}

class MapPageContent extends StatefulWidget {
  final CollectionLens collection;
  final AvesEntry? initialEntry;

  const MapPageContent({
    Key? key,
    required this.collection,
    this.initialEntry,
  }) : super(key: key);

  @override
  _MapPageContentState createState() => _MapPageContentState();
}

class _MapPageContentState extends State<MapPageContent> with SingleTickerProviderStateMixin {
  final List<StreamSubscription> _subscriptions = [];
  final AvesMapController _mapController = AvesMapController();
  late final ValueNotifier<bool> _isPageAnimatingNotifier;
  final ValueNotifier<int?> _selectedIndexNotifier = ValueNotifier(0);
  final ValueNotifier<CollectionLens?> _regionCollectionNotifier = ValueNotifier(null);
  final ValueNotifier<AvesEntry?> _dotEntryNotifier = ValueNotifier(null), _infoEntryNotifier = ValueNotifier(null);
  final Debouncer _infoDebouncer = Debouncer(delay: Durations.mapInfoDebounceDelay);
  final ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  late AnimationController _overlayAnimationController;
  late Animation<double> _overlayScale, _scrollerSize;

  List<AvesEntry> get entries => widget.collection.sortedEntries;

  CollectionLens? get regionCollection => _regionCollectionNotifier.value;

  @override
  void initState() {
    super.initState();

    if (settings.infoMapStyle.isGoogleMaps) {
      _isPageAnimatingNotifier = ValueNotifier(true);
      Future.delayed(Durations.pageTransitionAnimation * timeDilation).then((_) {
        if (!mounted) return;
        _isPageAnimatingNotifier.value = false;
      });
    } else {
      _isPageAnimatingNotifier = ValueNotifier(false);
    }

    _dotEntryNotifier.addListener(_updateInfoEntry);

    _overlayAnimationController = AnimationController(
      duration: Durations.viewerOverlayAnimation,
      vsync: this,
    );
    _overlayScale = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutBack,
    );
    _scrollerSize = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutQuad,
    );
    _overlayVisible.addListener(_onOverlayVisibleChange);

    _subscriptions.add(_mapController.idleUpdates.listen((event) => _onIdle(event.bounds)));

    _selectedIndexNotifier.addListener(_onThumbnailIndexChange);
    Future.delayed(Durations.pageTransitionAnimation * timeDilation + const Duration(seconds: 1), () {
      final regionEntries = regionCollection?.sortedEntries ?? [];
      final initialEntry = widget.initialEntry ?? regionEntries.firstOrNull;
      if (initialEntry != null) {
        final index = regionEntries.indexOf(initialEntry);
        if (index != -1) {
          _selectedIndexNotifier.value = index;
        }
        _onEntrySelected(initialEntry);
      }
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) => _onOverlayVisibleChange(animate: false));
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _dotEntryNotifier.removeListener(_updateInfoEntry);
    _overlayAnimationController.dispose();
    _overlayVisible.removeListener(_onOverlayVisibleChange);
    _mapController.dispose();
    _selectedIndexNotifier.removeListener(_onThumbnailIndexChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, EntryMapStyle>(
      selector: (context, s) => s.infoMapStyle,
      builder: (context, mapStyle, child) {
        late Widget scroller;
        if (mapStyle.isGoogleMaps) {
          // the Google map widget is too heavy for a smooth resizing animation
          // so we just toggle visibility when overlay animation is done
          scroller = ValueListenableBuilder<double>(
            valueListenable: _overlayAnimationController,
            builder: (context, animation, child) {
              return Visibility(
                visible: !_overlayAnimationController.isDismissed,
                child: child!,
              );
            },
            child: child,
          );
        } else {
          // the Leaflet map widget is light enough for a smooth resizing animation
          scroller = FadeTransition(
            opacity: _scrollerSize,
            child: SizeTransition(
              sizeFactor: _scrollerSize,
              axisAlignment: 1.0,
              child: child,
            ),
          );
        }

        return Column(
          children: [
            Expanded(child: _buildMap()),
            scroller,
          ],
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          _buildScroller(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return MapTheme(
      interactive: true,
      navigationButton: MapNavigationButton.back,
      scale: _overlayScale,
      child: GeoMap(
        controller: _mapController,
        entries: entries,
        initialEntry: widget.initialEntry,
        isAnimatingNotifier: _isPageAnimatingNotifier,
        dotEntryNotifier: _dotEntryNotifier,
        onMapTap: _toggleOverlay,
        onMarkerTap: (markerEntry, getClusterEntries) async {
          final index = regionCollection?.sortedEntries.indexOf(markerEntry);
          if (index != null && _selectedIndexNotifier.value != index) {
            _selectedIndexNotifier.value = index;
          }
          await Future.delayed(const Duration(milliseconds: 500));
          context.read<HighlightInfo>().set(markerEntry);
        },
      ),
    );
  }

  Widget _buildScroller() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              top: false,
              bottom: false,
              child: MapInfoRow(entryNotifier: _infoEntryNotifier),
            ),
            const SizedBox(height: 8),
            Selector<MediaQueryData, double>(
              selector: (c, mq) => mq.size.width,
              builder: (c, mqWidth, child) => ValueListenableBuilder<CollectionLens?>(
                valueListenable: _regionCollectionNotifier,
                builder: (context, regionCollection, child) {
                  final regionEntries = regionCollection?.sortedEntries ?? [];
                  return ThumbnailScroller(
                    availableWidth: mqWidth,
                    entryCount: regionEntries.length,
                    entryBuilder: (index) => regionEntries[index],
                    indexNotifier: _selectedIndexNotifier,
                    onTap: _onThumbnailTap,
                    heroTagger: (entry) => Object.hashAll([regionCollection?.id, entry.uri]),
                    highlightable: true,
                  );
                },
              ),
            ),
          ],
        ),
        Positioned.fill(
          child: ValueListenableBuilder<CollectionLens?>(
            valueListenable: _regionCollectionNotifier,
            builder: (context, regionCollection, child) {
              return regionCollection != null && regionCollection.isEmpty
                  ? EmptyContent(
                      text: context.l10n.mapEmptyRegion,
                      fontSize: 18,
                    )
                  : const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  void _onIdle(ZoomedBounds bounds) {
    AvesEntry? selectedEntry;
    if (regionCollection != null) {
      final regionEntries = regionCollection!.sortedEntries;
      final selectedIndex = _selectedIndexNotifier.value;
      selectedEntry = selectedIndex != null && selectedIndex < regionEntries.length ? regionEntries[selectedIndex] : null;
    }

    _regionCollectionNotifier.value = CollectionLens(
      source: widget.collection.source,
      listenToSource: false,
      fixedSelection: entries.where((entry) => bounds.contains(entry.latLng!)).toList(),
    );

    // get entries from the new collection, so the entry order is the same
    // as the one used by the thumbnail scroller (considering sort/section/group)
    final regionEntries = regionCollection!.sortedEntries;
    final selectedIndex = (selectedEntry != null && regionEntries.contains(selectedEntry))
        ? regionEntries.indexOf(selectedEntry)
        : regionEntries.isEmpty
            ? null
            : 0;
    _selectedIndexNotifier.value = selectedIndex;
    // force update, as the region entries may change without a change of index
    _onThumbnailIndexChange();
  }

  AvesEntry? _getRegionEntry(int? index) {
    if (index != null && regionCollection != null) {
      final regionEntries = regionCollection!.sortedEntries;
      if (index < regionEntries.length) {
        return regionEntries[index];
      }
    }
    return null;
  }

  void _onThumbnailTap(int index) => _goToViewer(_getRegionEntry(index));

  void _onThumbnailIndexChange() => _onEntrySelected(_getRegionEntry(_selectedIndexNotifier.value));

  void _onEntrySelected(AvesEntry? selectedEntry) => _dotEntryNotifier.value = selectedEntry;

  void _updateInfoEntry() {
    final selectedEntry = _dotEntryNotifier.value;
    if (_infoEntryNotifier.value == null || selectedEntry == null) {
      _infoEntryNotifier.value = selectedEntry;
    } else {
      _infoDebouncer(() => _infoEntryNotifier.value = selectedEntry);
    }
  }

  void _goToViewer(AvesEntry? initialEntry) {
    if (initialEntry == null) return;

    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        settings: const RouteSettings(name: EntryViewerPage.routeName),
        pageBuilder: (c, a, sa) {
          return EntryViewerPage(
            collection: regionCollection,
            initialEntry: initialEntry,
          );
        },
      ),
    );
  }

  // overlay

  void _toggleOverlay() => _overlayVisible.value = !_overlayVisible.value;

  Future<void> _onOverlayVisibleChange({bool animate = true}) async {
    if (_overlayVisible.value) {
      if (animate) {
        await _overlayAnimationController.forward();
      } else {
        _overlayAnimationController.value = _overlayAnimationController.upperBound;
      }
    } else {
      if (animate) {
        await _overlayAnimationController.reverse();
      } else {
        _overlayAnimationController.reset();
      }
    }
  }
}
