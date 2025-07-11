import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/filters/aspect_ratio.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/set_and.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/date.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/missing.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/recent.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/model/filters/weekday.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location/country.dart';
import 'package:aves/model/source/location/place.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/basic/tv_edge_focus.dart';
import 'package:aves/widgets/common/expandable_filter_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/search/delegate.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionSearchDelegate extends AvesSearchDelegate with FeedbackMixin, VaultAwareMixin {
  final CollectionSource source;
  final CollectionLens? parentCollection;
  final ValueNotifier<String?> _expandedSectionNotifier = ValueNotifier(null);
  final FocusNode _suggestionsTopFocusNode = FocusNode();
  final ScrollController _suggestionsScrollController = ScrollController();
  late final List<MimeFilter> _mimeTypeFilters;

  @override
  FocusNode? get suggestionsFocusNode => _suggestionsTopFocusNode;

  @override
  ScrollController get suggestionsScrollController => _suggestionsScrollController;

  static const int searchHistoryCount = 10;
  static final typeFilters = [
    FavouriteFilter.instance,
    MimeFilter.image,
    MimeFilter.video,
    TypeFilter.animated,
    TypeFilter.motionPhoto,
    AspectRatioFilter.portrait,
    AspectRatioFilter.landscape,
    TypeFilter.panorama,
    TypeFilter.sphericalVideo,
    TypeFilter.geotiff,
    TypeFilter.hdr,
    TypeFilter.raw,
  ];

  static final _monthFilters = List.generate(12, (i) => DateFilter(DateLevel.m, DateTime(1, i + 1)));

  CollectionSearchDelegate({
    required super.searchFieldLabel,
    required super.searchFieldStyle,
    required this.source,
    this.parentCollection,
    super.canPop,
    String? initialQuery,
  }) : super(
          routeName: SearchPage.routeName,
        ) {
    query = initialQuery ?? '';
    _mimeTypeFilters = source.visibleEntries.map((entry) => entry.mimeType).toSet().map(MimeFilter.new).toList()..sort();
  }

  @override
  void dispose() {
    _expandedSectionNotifier.dispose();
    _suggestionsTopFocusNode.dispose();
    _suggestionsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final upQuery = query.trim().toUpperCase();
    bool containQuery(CollectionFilter filter) => filter.matchLabel(context, upQuery);
    return SafeArea(
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is SelectFilterNotification) {
            _select(context, {notification.filter});
            return true;
          } else if (notification is DecomposeFilterNotification) {
            final filter = notification.filter;
            if (filter is DynamicAlbumFilter) {
              final innerFilter = filter.filter;
              final newFilters = innerFilter is SetAndFilter ? innerFilter.innerFilters : {innerFilter};
              _select(context, newFilters);
              return true;
            }
          }
          return false;
        },
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
                  controller: _suggestionsScrollController,
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    TvEdgeFocus(
                      focusNode: _suggestionsTopFocusNode,
                    ),
                    _buildFilterRow(
                      context: context,
                      filters: [
                        queryFilter,
                        ...visibleTypeFilters,
                      ].nonNulls.where(containQuery).toList(),
                      // usually perform hero animation only on tapped chips,
                      // but we also need to animate the query chip when it is selected by submitting the search query
                      heroTypeBuilder: (filter) => filter == queryFilter ? HeroType.always : HeroType.onTap,
                    ),
                    if (upQuery.isEmpty && history.isNotEmpty)
                      _buildFilterRow(
                        context: context,
                        title: context.l10n.searchRecentSectionTitle,
                        filters: history,
                      ),
                    _buildDateFilters(context, containQuery),
                    _buildMimeTypeFilters(context, containQuery),
                    _buildAlbumFilters(containQuery),
                    _buildCountryFilters(containQuery),
                    _buildStateFilters(containQuery),
                    _buildPlaceFilters(containQuery),
                    _buildTagFilters(containQuery),
                    _buildRatingFilters(context, containQuery),
                    _buildMetadataFilters(context, containQuery),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterRow({
    required BuildContext context,
    String? title,
    required List<CollectionFilter> filters,
    HeroType Function(CollectionFilter filter)? heroTypeBuilder,
  }) {
    void onTap(filter) => _select(context, {filter is QueryFilter ? QueryFilter(filter.query) : filter});
    const onLongPress = AvesFilterChip.showDefaultLongPressMenu;
    return title != null
        ? TitledExpandableFilterRow(
            title: title,
            filters: filters,
            expandedNotifier: _expandedSectionNotifier,
            heroTypeBuilder: heroTypeBuilder,
            onTap: onTap,
            onLongPress: onLongPress,
          )
        : ExpandableFilterRow(
            filters: filters,
            isExpanded: false,
            heroTypeBuilder: heroTypeBuilder,
            onTap: onTap,
            onLongPress: onLongPress,
          );
  }

  Widget _buildDateFilters(BuildContext context, _ContainQuery containQuery) {
    final firstDayOfWeekIndex = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    const daysPerWeek = DateTime.daysPerWeek;
    final _weekdayFilters = List.generate(daysPerWeek, (i) => WeekDayFilter((i + firstDayOfWeekIndex - 1) % daysPerWeek + 1));

    final filters = [
      DateFilter.onThisDay,
      RecentlyAddedFilter.instance,
      ..._monthFilters,
      ..._weekdayFilters,
    ].where(containQuery).toList();

    return _buildFilterRow(
      context: context,
      title: context.l10n.searchDateSectionTitle,
      filters: filters,
    );
  }

  Widget _buildMimeTypeFilters(BuildContext context, _ContainQuery containQuery) {
    final filters = _mimeTypeFilters.where(containQuery).toList();
    return _buildFilterRow(
      context: context,
      title: context.l10n.searchFormatSectionTitle,
      filters: filters,
    );
  }

  Widget _buildAlbumFilters(_ContainQuery containQuery) {
    return AnimatedBuilder(
      animation: dynamicAlbums,
      builder: (context, child) => StreamBuilder(
        stream: source.eventBus.on<AlbumsChangedEvent>(),
        builder: (context, snapshot) {
          final filters = [
            ...albumGrouping.getGroups().map(albumGrouping.uriToFilter),
            ...source.rawAlbums.map((album) => StoredAlbumFilter(
                  album,
                  source.getStoredAlbumDisplayName(context, album),
                )),
            ...dynamicAlbums.all,
          ].nonNulls.where(containQuery).toList()
            ..sort();
          return _buildFilterRow(
            context: context,
            title: context.l10n.searchAlbumsSectionTitle,
            filters: filters,
          );
        },
      ),
    );
  }

  Widget _buildCountryFilters(_ContainQuery containQuery) {
    return StreamBuilder(
      stream: source.eventBus.on<CountriesChangedEvent>(),
      builder: (context, snapshot) {
        return _buildFilterRow(
          context: context,
          title: context.l10n.searchCountriesSectionTitle,
          filters: source.sortedCountries.map((s) => LocationFilter(LocationLevel.country, s)).where(containQuery).toList(),
        );
      },
    );
  }

  Widget _buildStateFilters(_ContainQuery containQuery) {
    return StreamBuilder(
      stream: source.eventBus.on<PlacesChangedEvent>(),
      builder: (context, snapshot) {
        return _buildFilterRow(
          context: context,
          title: context.l10n.searchStatesSectionTitle,
          filters: source.sortedStates.map((s) => LocationFilter(LocationLevel.state, s)).where(containQuery).toList(),
        );
      },
    );
  }

  Widget _buildPlaceFilters(_ContainQuery containQuery) {
    return StreamBuilder(
      stream: source.eventBus.on<PlacesChangedEvent>(),
      builder: (context, snapshot) {
        return _buildFilterRow(
          context: context,
          title: context.l10n.searchPlacesSectionTitle,
          filters: source.sortedPlaces.map((s) => LocationFilter(LocationLevel.place, s)).where(containQuery).toList(),
        );
      },
    );
  }

  Widget _buildTagFilters(_ContainQuery containQuery) {
    return StreamBuilder(
      stream: source.eventBus.on<TagsChangedEvent>(),
      builder: (context, snapshot) {
        return _buildFilterRow(
          context: context,
          title: context.l10n.searchTagsSectionTitle,
          filters: source.sortedTags.map(TagFilter.new).where(containQuery).toList(),
        );
      },
    );
  }

  Widget _buildRatingFilters(BuildContext context, _ContainQuery containQuery) {
    return _buildFilterRow(
      context: context,
      title: context.l10n.searchRatingSectionTitle,
      filters: [5, 4, 3, 2, 1, -1].map(RatingFilter.new).where(containQuery).toList(),
    );
  }

  Widget _buildMetadataFilters(BuildContext context, _ContainQuery containQuery) {
    return _buildFilterRow(
      context: context,
      title: context.l10n.searchMetadataSectionTitle,
      filters: [
        MissingFilter.date,
        LocationFilter.unlocated,
        MissingFilter.fineAddress,
        TagFilter(''),
        RatingFilter(0),
        MissingFilter.title,
      ].where(containQuery).toList(),
    );
  }

  var _selectingFromQuery = false;

  @override
  Widget buildResults(BuildContext context) {
    // guard against multiple build calls
    if (!_selectingFromQuery) {
      _selectingFromQuery = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // `buildResults` is called in the build phase,
        // so we post the call that will filter the collection
        // and possibly trigger a rebuild here
        _select(context, {_buildQueryFilter(true)});
      });
    }
    return const SizedBox();
  }

  QueryFilter? _buildQueryFilter(bool colorful) {
    final cleanQuery = query.trim();
    return cleanQuery.isNotEmpty ? QueryFilter(cleanQuery, colorful: colorful) : null;
  }

  Future<void> _select(BuildContext context, Set<CollectionFilter?> filters) async {
    final newFilters = filters.nonNulls.toSet();
    if (newFilters.isEmpty) {
      goBack(context);
      return;
    }

    for (final filter in newFilters) {
      if (!await unlockFilter(context, filter)) return;

      if (settings.saveSearchHistory) {
        final history = settings.searchHistory
          ..remove(filter)
          ..insert(0, filter);
        settings.searchHistory = history.take(searchHistoryCount).toList();
      }
    }

    if (parentCollection != null) {
      _applyToParentCollectionPage(context, newFilters);
    } else {
      _jumpToCollectionPage(context, newFilters);
    }
  }

  void _applyToParentCollectionPage(BuildContext context, Set<CollectionFilter> filters) {
    parentCollection!.addFilters(filters);
    if (Navigator.canPop(context)) {
      // We delay closing the current page after applying the filter selection
      // so that hero animation target is ready in the `FilterBar`,
      // even when the target is a child of an `AnimatedList`.
      // Do not use `WidgetsBinding.instance.addPostFrameCallback`,
      // as it may not trigger if there is no subsequent build.
      Future.delayed(const Duration(milliseconds: 100), () => goBack(context));
    } else {
      _jumpToCollectionPage(context, parentCollection!.filters);
    }
  }

  void _jumpToCollectionPage(BuildContext context, Set<CollectionFilter> filters) {
    clean();
    Navigator.maybeOf(context)?.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: source,
          filters: filters,
        ),
      ),
      (route) => false,
    );
  }
}

typedef _ContainQuery = bool Function(CollectionFilter filter);
