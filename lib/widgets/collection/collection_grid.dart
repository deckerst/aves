import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/model/source/section_keys.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/app_bar.dart';
import 'package:aves/widgets/collection/draggable_thumb_label.dart';
import 'package:aves/widgets/collection/grid/list_details_theme.dart';
import 'package:aves/widgets/collection/grid/section_layout.dart';
import 'package:aves/widgets/collection/grid/tile.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/sloppy_scroll_physics.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/grid/draggable_thumb_label.dart';
import 'package:aves/widgets/common/grid/item_tracker.dart';
import 'package:aves/widgets/common/grid/scaling.dart';
import 'package:aves/widgets/common/grid/section_layout.dart';
import 'package:aves/widgets/common/grid/selector.dart';
import 'package:aves/widgets/common/grid/sliver.dart';
import 'package:aves/widgets/common/grid/theme.dart';
import 'package:aves/widgets/common/identity/buttons.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/identity/scroll_thumb.dart';
import 'package:aves/widgets/common/providers/tile_extent_controller_provider.dart';
import 'package:aves/widgets/common/thumbnail/decorated.dart';
import 'package:aves/widgets/common/tile_extent_controller.dart';
import 'package:aves/widgets/navigation/nav_bar/nav_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CollectionGrid extends StatefulWidget {
  final String settingsRouteKey;

  static const int columnCountDefault = 4;
  static const double extentMin = 46;
  static const double extentMax = 300;
  static const double spacing = 2;

  const CollectionGrid({
    super.key,
    required this.settingsRouteKey,
  });

  @override
  State<CollectionGrid> createState() => _CollectionGridState();
}

class _CollectionGridState extends State<CollectionGrid> {
  TileExtentController? _tileExtentController;

  @override
  void dispose() {
    _tileExtentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tileExtentController ??= TileExtentController(
      settingsRouteKey: widget.settingsRouteKey,
      columnCountDefault: CollectionGrid.columnCountDefault,
      extentMin: CollectionGrid.extentMin,
      extentMax: CollectionGrid.extentMax,
      spacing: CollectionGrid.spacing,
      horizontalPadding: 2,
    );
    return TileExtentControllerProvider(
      controller: _tileExtentController!,
      child: _CollectionGridContent(),
    );
  }
}

class _CollectionGridContent extends StatelessWidget {
  final ValueNotifier<bool> _isScrollingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final settingsRouteKey = context.read<TileExtentController>().settingsRouteKey;
    final tileLayout = context.select<Settings, TileLayout>((s) => s.getTileLayout(settingsRouteKey));
    return Consumer<CollectionLens>(
      builder: (context, collection, child) {
        final sectionedListLayoutProvider = ValueListenableBuilder<double>(
          valueListenable: context.select<TileExtentController, ValueNotifier<double>>((controller) => controller.extentNotifier),
          builder: (context, thumbnailExtent, child) {
            assert(thumbnailExtent > 0);
            return Selector<TileExtentController, Tuple4<double, int, double, double>>(
              selector: (context, c) => Tuple4(c.viewportSize.width, c.columnCount, c.spacing, c.horizontalPadding),
              builder: (context, c, child) {
                final scrollableWidth = c.item1;
                final columnCount = c.item2;
                final tileSpacing = c.item3;
                final horizontalPadding = c.item4;
                return GridTheme(
                  extent: thumbnailExtent,
                  child: EntryListDetailsTheme(
                    extent: thumbnailExtent,
                    child: ValueListenableBuilder<SourceState>(
                      valueListenable: collection.source.stateNotifier,
                      builder: (context, sourceState, child) {
                        late final Duration tileAnimationDelay;
                        if (sourceState == SourceState.ready) {
                          // do not listen for animation delay change
                          final target = context.read<DurationsData>().staggeredAnimationPageTarget;
                          tileAnimationDelay = context.read<TileExtentController>().getTileAnimationDelay(target);
                        } else {
                          tileAnimationDelay = Duration.zero;
                        }
                        return SectionedEntryListLayoutProvider(
                          collection: collection,
                          scrollableWidth: scrollableWidth,
                          tileLayout: tileLayout,
                          columnCount: columnCount,
                          spacing: tileSpacing,
                          horizontalPadding: horizontalPadding,
                          tileExtent: thumbnailExtent,
                          tileBuilder: (entry) => AnimatedBuilder(
                            animation: favourites,
                            builder: (context, child) {
                              return InteractiveTile(
                                key: ValueKey(entry.id),
                                collection: collection,
                                entry: entry,
                                thumbnailExtent: thumbnailExtent,
                                tileLayout: tileLayout,
                                isScrollingNotifier: _isScrollingNotifier,
                              );
                            },
                          ),
                          tileAnimationDelay: tileAnimationDelay,
                          child: child!,
                        );
                      },
                      child: child,
                    ),
                  ),
                );
              },
              child: child,
            );
          },
          child: _CollectionSectionedContent(
            collection: collection,
            isScrollingNotifier: _isScrollingNotifier,
            scrollController: PrimaryScrollController.of(context)!,
            tileLayout: tileLayout,
          ),
        );
        return sectionedListLayoutProvider;
      },
    );
  }
}

class _CollectionSectionedContent extends StatefulWidget {
  final CollectionLens collection;
  final ValueNotifier<bool> isScrollingNotifier;
  final ScrollController scrollController;
  final TileLayout tileLayout;

  const _CollectionSectionedContent({
    required this.collection,
    required this.isScrollingNotifier,
    required this.scrollController,
    required this.tileLayout,
  });

  @override
  State<_CollectionSectionedContent> createState() => _CollectionSectionedContentState();
}

class _CollectionSectionedContentState extends State<_CollectionSectionedContent> {
  CollectionLens get collection => widget.collection;

  TileLayout get tileLayout => widget.tileLayout;

  ScrollController get scrollController => widget.scrollController;

  final ValueNotifier<double> appBarHeightNotifier = ValueNotifier(0);

  final GlobalKey scrollableKey = GlobalKey(debugLabel: 'thumbnail-collection-scrollable');

  @override
  Widget build(BuildContext context) {
    final scrollView = AnimationLimiter(
      child: _CollectionScrollView(
        scrollableKey: scrollableKey,
        collection: collection,
        appBar: CollectionAppBar(
          appBarHeightNotifier: appBarHeightNotifier,
          collection: collection,
        ),
        appBarHeightNotifier: appBarHeightNotifier,
        isScrollingNotifier: widget.isScrollingNotifier,
        scrollController: scrollController,
      ),
    );

    final scaler = _CollectionScaler(
      scrollableKey: scrollableKey,
      appBarHeightNotifier: appBarHeightNotifier,
      tileLayout: tileLayout,
      child: scrollView,
    );

    final selector = GridSelectionGestureDetector(
      scrollableKey: scrollableKey,
      selectable: context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canSelectMedia),
      items: collection.sortedEntries,
      scrollController: scrollController,
      appBarHeightNotifier: appBarHeightNotifier,
      child: scaler,
    );

    return GridItemTracker<AvesEntry>(
      scrollableKey: scrollableKey,
      tileLayout: tileLayout,
      appBarHeightNotifier: appBarHeightNotifier,
      scrollController: scrollController,
      child: selector,
    );
  }
}

class _CollectionScaler extends StatelessWidget {
  final GlobalKey scrollableKey;
  final ValueNotifier<double> appBarHeightNotifier;
  final TileLayout tileLayout;
  final Widget child;

  const _CollectionScaler({
    required this.scrollableKey,
    required this.appBarHeightNotifier,
    required this.tileLayout,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = context.select<TileExtentController, Tuple2<double, double>>((v) => Tuple2(v.spacing, v.horizontalPadding));
    final tileSpacing = metrics.item1;
    final horizontalPadding = metrics.item2;
    return GridScaleGestureDetector<AvesEntry>(
      scrollableKey: scrollableKey,
      tileLayout: tileLayout,
      heightForWidth: (width) => width,
      gridBuilder: (center, tileSize, child) => CustomPaint(
        painter: GridPainter(
          tileLayout: tileLayout,
          tileCenter: center,
          tileSize: tileSize,
          spacing: tileSpacing,
          horizontalPadding: horizontalPadding,
          borderWidth: DecoratedThumbnail.borderWidth,
          borderRadius: Radius.zero,
          color: DecoratedThumbnail.borderColor,
          textDirection: Directionality.of(context),
        ),
        child: child,
      ),
      scaledBuilder: (entry, tileSize) => EntryListDetailsTheme(
        extent: tileSize.height,
        child: Tile(
          entry: entry,
          thumbnailExtent: context.read<TileExtentController>().effectiveExtentMax,
          tileLayout: tileLayout,
        ),
      ),
      child: child,
    );
  }
}

class _CollectionScrollView extends StatefulWidget {
  final GlobalKey scrollableKey;
  final CollectionLens collection;
  final Widget appBar;
  final ValueNotifier<double> appBarHeightNotifier;
  final ValueNotifier<bool> isScrollingNotifier;
  final ScrollController scrollController;

  const _CollectionScrollView({
    required this.scrollableKey,
    required this.collection,
    required this.appBar,
    required this.appBarHeightNotifier,
    required this.isScrollingNotifier,
    required this.scrollController,
  });

  @override
  State<_CollectionScrollView> createState() => _CollectionScrollViewState();
}

class _CollectionScrollViewState extends State<_CollectionScrollView> with WidgetsBindingObserver {
  Timer? _scrollMonitoringTimer;
  bool _checkingStoragePermission = false;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant _CollectionScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unregisterWidget(widget);
    _stopScrollMonitoringTimer();
    super.dispose();
  }

  void _registerWidget(_CollectionScrollView widget) {
    widget.collection.filterChangeNotifier.addListener(_scrollToTop);
    widget.collection.sortSectionChangeNotifier.addListener(_scrollToTop);
    widget.scrollController.addListener(_onScrollChange);
  }

  void _unregisterWidget(_CollectionScrollView widget) {
    widget.collection.filterChangeNotifier.removeListener(_scrollToTop);
    widget.collection.sortSectionChangeNotifier.removeListener(_scrollToTop);
    widget.scrollController.removeListener(_onScrollChange);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        if (_checkingStoragePermission) {
          _checkingStoragePermission = false;
          _isStoragePermissionGranted.then((granted) {
            if (granted) {
              widget.collection.source.init();
            }
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = _buildScrollView(widget.appBar, widget.collection);
    return _buildDraggableScrollView(scrollView, widget.collection);
  }

  Widget _buildDraggableScrollView(ScrollView scrollView, CollectionLens collection) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.appBarHeightNotifier,
      builder: (context, appBarHeight, child) {
        return Selector<MediaQueryData, double>(
          selector: (context, mq) => mq.effectiveBottomPadding,
          builder: (context, mqPaddingBottom, child) {
            return Selector<Settings, bool>(
              selector: (context, s) => s.enableBottomNavigationBar,
              builder: (context, enableBottomNavigationBar, child) {
                final canNavigate = context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canNavigate);
                final showBottomNavigationBar = canNavigate && enableBottomNavigationBar;
                final navBarHeight = showBottomNavigationBar ? AppBottomNavBar.height : 0;
                return Selector<SectionedListLayout<AvesEntry>, List<SectionLayout>>(
                  selector: (context, layout) => layout.sectionLayouts,
                  builder: (context, sectionLayouts, child) {
                    return DraggableScrollbar(
                      backgroundColor: Colors.white,
                      scrollThumbSize: Size(avesScrollThumbWidth, avesScrollThumbHeight),
                      scrollThumbBuilder: avesScrollThumbBuilder(
                        height: avesScrollThumbHeight,
                        backgroundColor: Colors.white,
                      ),
                      controller: widget.scrollController,
                      crumbsBuilder: () => _getCrumbs(sectionLayouts),
                      padding: EdgeInsets.only(
                        // padding to keep scroll thumb between app bar above and nav bar below
                        top: appBarHeight,
                        bottom: navBarHeight + mqPaddingBottom,
                      ),
                      labelTextBuilder: (offsetY) => CollectionDraggableThumbLabel(
                        collection: collection,
                        offsetY: offsetY,
                      ),
                      crumbTextBuilder: (label) => DraggableCrumbLabel(label: label),
                      child: scrollView,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  ScrollView _buildScrollView(Widget appBar, CollectionLens collection) {
    return CustomScrollView(
      key: widget.scrollableKey,
      primary: true,
      // workaround to prevent scrolling the app bar away
      // when there is no content and we use `SliverFillRemaining`
      physics: collection.isEmpty
          ? const NeverScrollableScrollPhysics()
          : SloppyScrollPhysics(
              gestureSettings: context.select<MediaQueryData, DeviceGestureSettings>((mq) => mq.gestureSettings),
              parent: const AlwaysScrollableScrollPhysics(),
            ),
      cacheExtent: context.select<TileExtentController, double>((controller) => controller.effectiveExtentMax),
      slivers: [
        appBar,
        collection.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyCollectionPlaceholder(collection),
              )
            : const SectionedListSliver<AvesEntry>(),
        const NavBarPaddingSliver(),
        const BottomPaddingSliver(),
      ],
    );
  }

  Widget _buildEmptyCollectionPlaceholder(CollectionLens collection) {
    return ValueListenableBuilder<SourceState>(
      valueListenable: collection.source.stateNotifier,
      builder: (context, sourceState, child) {
        if (sourceState == SourceState.loading) {
          return const SizedBox();
        }

        return FutureBuilder<bool>(
          future: _isStoragePermissionGranted,
          builder: (context, snapshot) {
            final granted = snapshot.data ?? true;
            Widget? bottom = granted
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AvesOutlinedButton(
                      label: context.l10n.collectionEmptyGrantAccessButtonLabel,
                      onPressed: () async {
                        if (await openAppSettings()) {
                          _checkingStoragePermission = true;
                        }
                      },
                    ),
                  );

            if (collection.filters.any((filter) => filter is FavouriteFilter)) {
              return EmptyContent(
                icon: AIcons.favourite,
                text: context.l10n.collectionEmptyFavourites,
                bottom: bottom,
              );
            }
            if (collection.filters.any((filter) => filter is MimeFilter && filter.mime == MimeTypes.anyVideo)) {
              return EmptyContent(
                icon: AIcons.video,
                text: context.l10n.collectionEmptyVideos,
                bottom: bottom,
              );
            }
            return EmptyContent(
              icon: AIcons.image,
              text: context.l10n.collectionEmptyImages,
              bottom: bottom,
            );
          },
        );
      },
    );
  }

  void _scrollToTop() => widget.scrollController.jumpTo(0);

  void _onScrollChange() {
    widget.isScrollingNotifier.value = true;
    _stopScrollMonitoringTimer();
    _scrollMonitoringTimer = Timer(Durations.collectionScrollMonitoringTimerDelay, () {
      widget.isScrollingNotifier.value = false;
    });
  }

  void _stopScrollMonitoringTimer() {
    _scrollMonitoringTimer?.cancel();
  }

  Map<double, String> _getCrumbs(List<SectionLayout> sectionLayouts) {
    final crumbs = <double, String>{};
    if (sectionLayouts.length <= 1) return crumbs;

    final maxOffset = sectionLayouts.last.maxOffset;
    void addAlbums(CollectionLens collection, List<SectionLayout> sectionLayouts, Map<double, String> crumbs) {
      final source = collection.source;
      sectionLayouts.forEach((section) {
        final directory = (section.sectionKey as EntryAlbumSectionKey).directory;
        if (directory != null) {
          final label = source.getAlbumDisplayName(context, directory);
          crumbs[section.minOffset / maxOffset] = label;
        }
      });
    }

    final collection = widget.collection;
    switch (collection.sortFactor) {
      case EntrySortFactor.date:
        switch (collection.sectionFactor) {
          case EntryGroupFactor.album:
            addAlbums(collection, sectionLayouts, crumbs);
            break;
          case EntryGroupFactor.month:
          case EntryGroupFactor.day:
            final firstKey = sectionLayouts.first.sectionKey;
            final lastKey = sectionLayouts.last.sectionKey;
            if (firstKey is EntryDateSectionKey && lastKey is EntryDateSectionKey) {
              final newest = firstKey.date;
              final oldest = lastKey.date;
              if (newest != null && oldest != null) {
                final localeName = context.l10n.localeName;
                final dateFormat = newest.difference(oldest).inDays > 365 ? DateFormat.y(localeName) : DateFormat.MMM(localeName);
                String? lastLabel;
                sectionLayouts.forEach((section) {
                  final date = (section.sectionKey as EntryDateSectionKey).date;
                  if (date != null) {
                    final label = dateFormat.format(date);
                    if (label != lastLabel) {
                      crumbs[section.minOffset / maxOffset] = label;
                      lastLabel = label;
                    }
                  }
                });
              }
            }
            break;
          case EntryGroupFactor.none:
            break;
        }
        break;
      case EntrySortFactor.name:
        addAlbums(collection, sectionLayouts, crumbs);
        break;
      case EntrySortFactor.rating:
      case EntrySortFactor.size:
        break;
    }
    return crumbs;
  }

  Future<bool> get _isStoragePermissionGranted => Permission.storage.status.then((status) => status.isGranted);
}
