import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/collection/search/expandable_filter_row.dart';
import 'package:aves/widgets/collection/search_page.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageSearchDelegate {
  final CollectionSource source;
  final ValueNotifier<String> expandedSectionNotifier = ValueNotifier(null);
  final CollectionLens parentCollection;

  ImageSearchDelegate({@required this.source, this.parentCollection});

  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  Widget buildLeading(BuildContext context) {
    return Navigator.canPop(context)
        ? IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_arrow,
              progress: transitionAnimation,
            ),
            onPressed: () => _goBack(context),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          )
        : CloseButton(
            onPressed: SystemNavigator.pop,
          );
  }

  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(AIcons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: 'Clear',
        ),
    ];
  }

  Widget buildSuggestions(BuildContext context) {
    final upQuery = query.trim().toUpperCase();
    bool containQuery(String s) => s.toUpperCase().contains(upQuery);
    return SafeArea(
      child: ValueListenableBuilder<String>(
          valueListenable: expandedSectionNotifier,
          builder: (context, expandedSection, child) {
            var queryFilter = _buildQueryFilter(false);
            return ListView(
              padding: EdgeInsets.only(top: 8),
              children: [
                _buildFilterRow(
                  context: context,
                  filters: [
                    queryFilter,
                    FavouriteFilter(),
                    MimeFilter(MimeTypes.anyImage),
                    MimeFilter(MimeTypes.anyVideo),
                    MimeFilter(MimeFilter.animated),
                    MimeFilter(MimeTypes.svg),
                  ].where((f) => f != null && containQuery(f.label)),
                  // usually perform hero animation only on tapped chips,
                  // but we also need to animate the query chip when it is selected by submitting the search query
                  heroTypeBuilder: (filter) => filter == queryFilter ? HeroType.always : HeroType.onTap,
                ),
                StreamBuilder(
                    stream: source.eventBus.on<AlbumsChangedEvent>(),
                    builder: (context, snapshot) {
                      return _buildFilterRow(
                        context: context,
                        title: 'Albums',
                        filters: source.sortedAlbums.where(containQuery).map((s) => AlbumFilter(s, source.getUniqueAlbumName(s))).where((f) => containQuery(f.uniqueName)),
                      );
                    }),
                StreamBuilder(
                    stream: source.eventBus.on<LocationsChangedEvent>(),
                    builder: (context, snapshot) {
                      return _buildFilterRow(
                        context: context,
                        title: 'Countries',
                        filters: source.sortedCountries.where(containQuery).map((s) => LocationFilter(LocationLevel.country, s)),
                      );
                    }),
                StreamBuilder(
                    stream: source.eventBus.on<LocationsChangedEvent>(),
                    builder: (context, snapshot) {
                      return _buildFilterRow(
                        context: context,
                        title: 'Places',
                        filters: source.sortedPlaces.where(containQuery).map((s) => LocationFilter(LocationLevel.place, s)),
                      );
                    }),
                StreamBuilder(
                    stream: source.eventBus.on<TagsChangedEvent>(),
                    builder: (context, snapshot) {
                      return _buildFilterRow(
                        context: context,
                        title: 'Tags',
                        filters: source.sortedTags.where(containQuery).map((s) => TagFilter(s)),
                      );
                    }),
              ],
            );
          }),
    );
  }

  Widget _buildFilterRow({
    @required BuildContext context,
    String title,
    @required Iterable<CollectionFilter> filters,
    HeroType Function(CollectionFilter filter) heroTypeBuilder,
  }) {
    return ExpandableFilterRow(
      title: title,
      filters: filters,
      expandedNotifier: expandedSectionNotifier,
      heroTypeBuilder: heroTypeBuilder,
      onTap: (filter) => _select(context, filter is QueryFilter ? QueryFilter(filter.query) : filter),
    );
  }

  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // `buildResults` is called in the build phase,
      // so we post the call that will filter the collection
      // and possibly trigger a rebuild here
      _select(context, _buildQueryFilter(true));
    });
    return SizedBox.shrink();
  }

  QueryFilter _buildQueryFilter(bool colorful) {
    final cleanQuery = query.trim();
    return cleanQuery.isNotEmpty ? QueryFilter(cleanQuery, colorful: colorful) : null;
  }

  void _select(BuildContext context, CollectionFilter filter) {
    if (parentCollection != null) {
      _applyToParentCollectionPage(context, filter);
    } else {
      _goToCollectionPage(context, filter);
    }
  }

  void _applyToParentCollectionPage(BuildContext context, CollectionFilter filter) {
    if (filter != null) {
      parentCollection.addFilter(filter);
    }
    // we post closing the search page after applying the filter selection
    // so that hero animation target is ready in the `FilterBar`,
    // even when the target is a child of an `AnimatedList`
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goBack(context);
    });
  }

  void _goBack(BuildContext context) {
    _clean();
    Navigator.of(context).pop();
  }

  void _goToCollectionPage(BuildContext context, CollectionFilter filter) {
    _clean();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(CollectionLens(
          source: source,
          filters: [filter],
          groupFactor: settings.collectionGroupFactor,
          sortFactor: settings.collectionSortFactor,
        )),
      ),
      settings.navRemoveRoutePredicate(CollectionPage.routeName),
    );
  }

  void _clean() {
    currentBody = null;
    focusNode?.unfocus();
  }

  // adapted from `SearchDelegate`

  void showResults(BuildContext context) {
    focusNode?.unfocus();
    currentBody = SearchBody.results;
  }

  void showSuggestions(BuildContext context) {
    assert(focusNode != null, '_focusNode must be set by route before showSuggestions is called.');
    focusNode.requestFocus();
    currentBody = SearchBody.suggestions;
  }

  Animation<double> get transitionAnimation => proxyAnimation;

  FocusNode focusNode;

  final TextEditingController queryTextController = TextEditingController();

  final ProxyAnimation proxyAnimation = ProxyAnimation(kAlwaysDismissedAnimation);

  String get query => queryTextController.text;

  set query(String value) {
    assert(query != null);
    queryTextController.text = value;
  }

  final ValueNotifier<SearchBody> currentBodyNotifier = ValueNotifier<SearchBody>(null);

  SearchBody get currentBody => currentBodyNotifier.value;

  set currentBody(SearchBody value) {
    currentBodyNotifier.value = value;
  }

  SearchPageRoute route;
}

// adapted from `SearchDelegate`
enum SearchBody { suggestions, results }

// adapted from `SearchDelegate`
class SearchPageRoute<T> extends PageRoute<T> {
  SearchPageRoute({
    @required this.delegate,
  })  : assert(delegate != null),
        super(settings: RouteSettings(name: SearchPage.routeName)) {
    assert(
      delegate.route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before openening another search with the same delegate instance.',
    );
    delegate.route = this;
  }

  final ImageSearchDelegate delegate;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

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
  void didComplete(T result) {
    super.didComplete(result);
    assert(delegate.route == this);
    delegate.route = null;
    delegate.currentBody = null;
  }
}
