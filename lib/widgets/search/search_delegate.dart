import 'package:aves/model/filters/album.dart';
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
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/expandable_filter_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/search/search_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CollectionSearchDelegate {
  final CollectionSource source;
  final CollectionLens? parentCollection;
  final ValueNotifier<String?> _expandedSectionNotifier = ValueNotifier(null);
  final bool canPop;

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

  CollectionSearchDelegate({
    required this.source,
    this.parentCollection,
    this.canPop = true,
    String? initialQuery,
  }) {
    query = initialQuery ?? '';
  }

  Widget buildLeading(BuildContext context) {
    // use a property instead of checking `Navigator.canPop(context)`
    // because the navigator state changes as soon as we press back
    // so the leading may mistakenly switch to the close button
    return canPop
        ? IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_arrow,
              progress: transitionAnimation,
            ),
            onPressed: () => _goBack(context),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          )
        : const CloseButton(
            onPressed: SystemNavigator.pop,
          );
  }

  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(AIcons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: context.l10n.clearTooltip,
        ),
    ];
  }

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
                      StreamBuilder(
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
                          }),
                      StreamBuilder(
                          stream: source.eventBus.on<CountriesChangedEvent>(),
                          builder: (context, snapshot) {
                            final filters = source.sortedCountries.where(containQuery).map((s) => LocationFilter(LocationLevel.country, s)).toList();
                            return _buildFilterRow(
                              context: context,
                              title: context.l10n.searchSectionCountries,
                              filters: filters,
                            );
                          }),
                      StreamBuilder(
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
                          }),
                      StreamBuilder(
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
                          }),
                      _buildFilterRow(
                        context: context,
                        title: context.l10n.searchSectionRating,
                        filters: [0, 5, 4, 3, 2, 1, -1].map(RatingFilter.new).where((f) => containQuery(f.getLabel(context))).toList(),
                      ),
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

  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // `buildResults` is called in the build phase,
      // so we post the call that will filter the collection
      // and possibly trigger a rebuild here
      _select(context, _buildQueryFilter(true));
    });
    return const SizedBox.shrink();
  }

  QueryFilter? _buildQueryFilter(bool colorful) {
    final cleanQuery = query.trim();
    return cleanQuery.isNotEmpty ? QueryFilter(cleanQuery, colorful: colorful) : null;
  }

  void _select(BuildContext context, CollectionFilter? filter) {
    if (filter == null) {
      _goBack(context);
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
      _goBack(context);
    });
  }

  void _goBack(BuildContext context) {
    _clean();
    Navigator.pop(context);
  }

  void _jumpToCollectionPage(BuildContext context, CollectionFilter filter) {
    _clean();
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

  void _clean() {
    currentBody = null;
    focusNode?.unfocus();
  }

  // adapted from Flutter `SearchDelegate` in `/material/search.dart`

  void showResults(BuildContext context) {
    focusNode?.unfocus();
    currentBody = SearchBody.results;
  }

  void showSuggestions(BuildContext context) {
    assert(focusNode != null, '_focusNode must be set by route before showSuggestions is called.');
    focusNode!.requestFocus();
    currentBody = SearchBody.suggestions;
  }

  Animation<double> get transitionAnimation => proxyAnimation;

  FocusNode? focusNode;

  final TextEditingController queryTextController = TextEditingController();

  final ProxyAnimation proxyAnimation = ProxyAnimation(kAlwaysDismissedAnimation);

  String get query => queryTextController.text;

  set query(String value) {
    queryTextController.text = value;
  }

  final ValueNotifier<SearchBody?> currentBodyNotifier = ValueNotifier(null);

  SearchBody? get currentBody => currentBodyNotifier.value;

  set currentBody(SearchBody? value) {
    currentBodyNotifier.value = value;
  }

  SearchPageRoute? route;
}

// adapted from Flutter `_SearchBody` in `/material/search.dart`
enum SearchBody { suggestions, results }

// adapted from Flutter `_SearchPageRoute` in `/material/search.dart`
class SearchPageRoute<T> extends PageRoute<T> {
  SearchPageRoute({
    required this.delegate,
  }) : super(settings: const RouteSettings(name: SearchPage.routeName)) {
    assert(
      delegate.route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before openening another search with the same delegate instance.',
    );
    delegate.route = this;
  }

  final CollectionSearchDelegate delegate;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => false;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Animation<double> createAnimation() {
    final animation = super.createAnimation();
    delegate.proxyAnimation.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SearchPage(
      delegate: delegate,
      animation: animation,
    );
  }

  @override
  void didComplete(T? result) {
    super.didComplete(result);
    assert(delegate.route == this);
    delegate.route = null;
    delegate.currentBody = null;
  }
}
