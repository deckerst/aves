import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/expandable_filter_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/search/delegate.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionSearchDelegate extends AvesSearchDelegate {
  final CollectionSource source;
  final CollectionLens? parentCollection;
  final ValueNotifier<String?> _expandedSectionNotifier = ValueNotifier(null);

  static const pageRouteName = '/search';
  static const int searchHistoryCount = 10;
  static final typeFilters = [
    FavouriteFilter.instance,
    MimeFilter.image,
    MimeFilter.video,
    TypeFilter.animated,
    TypeFilter.motionPhoto,
    TypeFilter.panorama,
    TypeFilter.sphericalVideo,
    TypeFilter.geotiff,
    TypeFilter.raw,
    MimeFilter(MimeTypes.svg),
  ];

  static final _monthFilters = List.generate(12, (i) => DateFilter(DateLevel.m, DateTime(1, i + 1)));

  CollectionSearchDelegate({
    required super.searchFieldLabel,
    required this.source,
    this.parentCollection,
    super.canPop,
    String? initialQuery,
  }) : super(
          routeName: pageRouteName,
        ) {
    query = initialQuery ?? '';
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final upQuery = query.trim().toUpperCase();
    bool containQuery(String s) => s.toUpperCase().contains(upQuery);
    return SafeArea(
      child: ValueListenableBuilder<String?>(
          valueListenable: _expandedSectionNotifier,
          builder: (context, expandedSection, child) {
            final queryFilter = _buildQueryFilter(false);
            return Selector<Settings, Set<CollectionFilter>>(
                selector: (context, s) => s.hiddenFilters,
                builder: (context, hiddenFilters, child) {
                  bool notHidden(CollectionFilter filter) => !hiddenFilters.contains(filter);

                  final visibleTypeFilters = typeFilters.where(notHidden).toList();
                  if (hiddenFilters.contains(MimeFilter.video)) {
                    [MimeFilter.image, TypeFilter.sphericalVideo].forEach(visibleTypeFilters.remove);
                  }

                  final history = settings.searchHistory.where(notHidden).toList();

                  return ListView(
                    padding: const EdgeInsets.only(top: 8),
                    children: [
                      _buildFilterRow(
                        context: context,
                        filters: [
                          queryFilter,
                          ...visibleTypeFilters,
                        ].whereNotNull().where((f) => containQuery(f.getLabel(context))).toList(),
                        // usually perform hero animation only on tapped chips,
                        // but we also need to animate the query chip when it is selected by submitting the search query
                        heroTypeBuilder: (filter) => filter == queryFilter ? HeroType.always : HeroType.onTap,
                      ),
                      if (upQuery.isEmpty && history.isNotEmpty)
                        _buildFilterRow(
                          context: context,
                          title: context.l10n.searchSectionRecent,
                          filters: history,
                        ),
                      _buildDateFilters(context, containQuery),
                      _buildAlbumFilters(containQuery),
                      _buildCountryFilters(containQuery),
                      _buildPlaceFilters(containQuery),
                      _buildTagFilters(containQuery),
                      _buildRatingFilters(context, containQuery),
                    ],
                  );
                });
          }),
    );
  }

  Widget _buildFilterRow({
    required BuildContext context,
    String? title,
    required List<CollectionFilter> filters,
    HeroType Function(CollectionFilter filter)? heroTypeBuilder,
  }) {
    return ExpandableFilterRow(
      title: title,
      filters: filters,
      expandedNotifier: _expandedSectionNotifier,
      heroTypeBuilder: heroTypeBuilder,
      onTap: (filter) => _select(context, filter is QueryFilter ? QueryFilter(filter.query) : filter),
      onLongPress: AvesFilterChip.showDefaultLongPressMenu,
    );
  }

  Widget _buildDateFilters(BuildContext context, _ContainQuery containQuery) {
    final filters = [
      DateFilter.onThisDay,
      ..._monthFilters,
    ].where((f) => containQuery(f.getLabel(context))).toList();
    return _buildFilterRow(
      context: context,
      title: context.l10n.searchSectionDate,
      filters: filters,
    );
  }

  Widget _buildAlbumFilters(_ContainQuery containQuery) {
    return StreamBuilder(
      stream: source.eventBus.on<AlbumsChangedEvent>(),
      builder: (context, snapshot) {
        final filters = source.rawAlbums
            .map((album) => AlbumFilter(
                  album,
                  source.getAlbumDisplayName(context, album),
                ))
            .where((filter) => containQuery(filter.displayName ?? filter.album))
            .toList()
          ..sort();
        return _buildFilterRow(
          context: context,
          title: context.l10n.searchSectionAlbums,
          filters: filters,
        );
      },
    );
  }

  Widget _buildCountryFilters(_ContainQuery containQuery) {
    return StreamBuilder(
      stream: source.eventBus.on<CountriesChangedEvent>(),
      builder: (context, snapshot) {
        final filters = source.sortedCountries.where(containQuery).map((s) => LocationFilter(LocationLevel.country, s)).toList();
        return _buildFilterRow(
          context: context,
          title: context.l10n.searchSectionCountries,
          filters: filters,
        );
      },
    );
  }

  Widget _buildPlaceFilters(_ContainQuery containQuery) {
    return StreamBuilder(
      stream: source.eventBus.on<PlacesChangedEvent>(),
      builder: (context, snapshot) {
        final filters = source.sortedPlaces.where(containQuery).map((s) => LocationFilter(LocationLevel.place, s));
        final noFilter = LocationFilter(LocationLevel.place, '');
        return _buildFilterRow(
          context: context,
          title: context.l10n.searchSectionPlaces,
          filters: [
            if (containQuery(noFilter.getLabel(context))) noFilter,
            ...filters,
          ],
        );
      },
    );
  }

  Widget _buildTagFilters(_ContainQuery containQuery) {
    return StreamBuilder(
      stream: source.eventBus.on<TagsChangedEvent>(),
      builder: (context, snapshot) {
        final filters = source.sortedTags.where(containQuery).map(TagFilter.new);
        final noFilter = TagFilter('');
        return _buildFilterRow(
          context: context,
          title: context.l10n.searchSectionTags,
          filters: [
            if (containQuery(noFilter.getLabel(context))) noFilter,
            ...filters,
          ],
        );
      },
    );
  }

  Widget _buildRatingFilters(BuildContext context, _ContainQuery containQuery) {
    return _buildFilterRow(
      context: context,
      title: context.l10n.searchSectionRating,
      filters: [0, 5, 4, 3, 2, 1, -1].map(RatingFilter.new).where((f) => containQuery(f.getLabel(context))).toList(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // `buildResults` is called in the build phase,
      // so we post the call that will filter the collection
      // and possibly trigger a rebuild here
      _select(context, _buildQueryFilter(true));
    });
    return const SizedBox();
  }

  QueryFilter? _buildQueryFilter(bool colorful) {
    final cleanQuery = query.trim();
    return cleanQuery.isNotEmpty ? QueryFilter(cleanQuery, colorful: colorful) : null;
  }

  void _select(BuildContext context, CollectionFilter? filter) {
    if (filter == null) {
      goBack(context);
      return;
    }

    if (settings.saveSearchHistory) {
      final history = settings.searchHistory
        ..remove(filter)
        ..insert(0, filter);
      settings.searchHistory = history.take(searchHistoryCount).toList();
    }
    if (parentCollection != null) {
      _applyToParentCollectionPage(context, filter);
    } else {
      _jumpToCollectionPage(context, filter);
    }
  }

  void _applyToParentCollectionPage(BuildContext context, CollectionFilter filter) {
    parentCollection!.addFilter(filter);
    // we post closing the search page after applying the filter selection
    // so that hero animation target is ready in the `FilterBar`,
    // even when the target is a child of an `AnimatedList`
    WidgetsBinding.instance.addPostFrameCallback((_) {
      goBack(context);
    });
  }

  void _jumpToCollectionPage(BuildContext context, CollectionFilter filter) {
    clean();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: source,
          filters: {filter},
        ),
      ),
      (route) => false,
    );
  }
}

typedef _ContainQuery = bool Function(String s);
