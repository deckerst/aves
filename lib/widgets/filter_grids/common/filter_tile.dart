import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/enums.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/grid/scaling.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/covered_filter_chip.dart';
import 'package:aves/widgets/filter_grids/common/filter_chip_grid_decorator.dart';
import 'package:aves/widgets/filter_grids/common/list_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InteractiveFilterTile<T extends CollectionFilter> extends StatefulWidget {
  final FilterGridItem<T> gridItem;
  final double chipExtent, thumbnailExtent;
  final TileLayout tileLayout;
  final String? banner;
  final HeroType heroType;

  const InteractiveFilterTile({
    super.key,
    required this.gridItem,
    required this.chipExtent,
    required this.thumbnailExtent,
    required this.tileLayout,
    this.banner,
    required this.heroType,
  });

  @override
  State<InteractiveFilterTile<T>> createState() => _InteractiveFilterTileState<T>();
}

class _InteractiveFilterTileState<T extends CollectionFilter> extends State<InteractiveFilterTile<T>> {
  HeroType? _heroTypeOverride;

  FilterGridItem<T> get gridItem => widget.gridItem;

  HeroType get effectiveHeroType => _heroTypeOverride ?? widget.heroType;

  @override
  Widget build(BuildContext context) {
    final filter = gridItem.filter;

    void onTap() {
      final appMode = context.read<ValueNotifier<AppMode>>().value;
      switch (appMode) {
        case AppMode.main:
        case AppMode.pickSingleMediaExternal:
        case AppMode.pickMultipleMediaExternal:
          final selection = context.read<Selection<FilterGridItem<T>>>();
          if (selection.isSelecting) {
            selection.toggleSelection(gridItem);
          } else {
            _goToCollection(context, filter);
          }
          break;
        case AppMode.pickFilterInternal:
          Navigator.pop<T>(context, filter);
          break;
        case AppMode.pickMediaInternal:
        case AppMode.screenSaver:
        case AppMode.setWallpaper:
        case AppMode.slideshow:
        case AppMode.view:
          break;
      }
    }

    return MetaData(
      metaData: ScalerMetadata(gridItem),
      child: FilterTile(
        gridItem: gridItem,
        chipExtent: widget.chipExtent,
        thumbnailExtent: widget.thumbnailExtent,
        tileLayout: widget.tileLayout,
        banner: widget.banner,
        selectable: true,
        highlightable: true,
        onTap: onTap,
        heroType: effectiveHeroType,
      ),
    );
  }

  void _goToCollection(BuildContext context, CollectionFilter filter) {
    if (effectiveHeroType == HeroType.onTap) {
      // make sure the chip hero triggers, even when tapping on the list view details
      setState(() => _heroTypeOverride = HeroType.always);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: CollectionPage.routeName),
          builder: (context) => CollectionPage(
            source: context.read<CollectionSource>(),
            filters: {filter},
          ),
        ),
      );
    });
  }
}

class FilterTile<T extends CollectionFilter> extends StatelessWidget {
  final FilterGridItem<T> gridItem;
  final double chipExtent, thumbnailExtent;
  final TileLayout tileLayout;
  final String? banner;
  final bool selectable, highlightable;
  final VoidCallback? onTap;
  final HeroType heroType;

  const FilterTile({
    super.key,
    required this.gridItem,
    required this.chipExtent,
    required this.thumbnailExtent,
    required this.tileLayout,
    this.banner,
    this.selectable = false,
    this.highlightable = false,
    this.onTap,
    this.heroType = HeroType.never,
  });

  @override
  Widget build(BuildContext context) {
    final filter = gridItem.filter;
    final pinned = settings.pinnedFilters.contains(filter);
    final onChipTap = onTap != null ? (filter) => onTap?.call() : null;

    switch (tileLayout) {
      case TileLayout.grid:
        return FilterChipGridDecorator<T, FilterGridItem<T>>(
          gridItem: gridItem,
          extent: chipExtent,
          selectable: selectable,
          highlightable: highlightable,
          child: CoveredFilterChip(
            filter: filter,
            extent: chipExtent,
            thumbnailExtent: thumbnailExtent,
            showText: true,
            pinned: pinned,
            banner: banner,
            onTap: onChipTap,
            heroType: heroType,
          ),
        );
      case TileLayout.list:
        Widget child = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilterChipGridDecorator<T, FilterGridItem<T>>(
              gridItem: gridItem,
              extent: chipExtent,
              selectable: selectable,
              highlightable: highlightable,
              child: CoveredFilterChip(
                filter: filter,
                extent: chipExtent,
                thumbnailExtent: thumbnailExtent,
                showText: false,
                banner: banner,
                onTap: onChipTap,
                heroType: heroType,
              ),
            ),
            Expanded(
              child: FilterListDetails(
                gridItem: gridItem,
                pinned: pinned,
              ),
            ),
          ],
        );
        if (onTap != null) {
          // larger than the chip corner radius, so ink effects will be effectively clipped from the leading chip corners
          const radius = Radius.circular(123);
          child = InkWell(
            // as of Flutter v2.8.1, `InkWell` does not use `BorderRadiusGeometry`
            borderRadius: context.isRtl ? const BorderRadius.only(topRight: radius, bottomRight: radius) : const BorderRadius.only(topLeft: radius, bottomLeft: radius),
            onTap: onTap,
            child: child,
          );
        }
        return child;
    }
  }
}
