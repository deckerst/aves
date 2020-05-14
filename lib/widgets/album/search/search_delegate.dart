import 'package:aves/model/collection_source.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/mime_types.dart';
import 'package:aves/widgets/album/search/expandable_filter_row.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';

class ImageSearchDelegate extends SearchDelegate<CollectionFilter> {
  final CollectionSource source;
  final ValueNotifier<String> expandedSectionNotifier = ValueNotifier(null);

  ImageSearchDelegate(this.source);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
      tooltip: 'Back',
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(AIcons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: 'Clear',
        ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final upQuery = query.trim().toUpperCase();
    final containQuery = (String s) => s.toUpperCase().contains(upQuery);
    return SafeArea(
      child: ValueListenableBuilder<String>(
          valueListenable: expandedSectionNotifier,
          builder: (context, expandedSection, child) {
            return ListView(
              children: [
                _buildFilterRow(
                  context: context,
                  filters: [
                    _buildQueryFilter(false),
                    FavouriteFilter(),
                    MimeFilter(MimeTypes.ANY_IMAGE),
                    MimeFilter(MimeTypes.ANY_VIDEO),
                    MimeFilter(MimeFilter.animated),
                    MimeFilter(MimeTypes.SVG),
                  ].where((f) => f != null && containQuery(f.label)),
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

  Widget _buildFilterRow({@required BuildContext context, String title, @required Iterable<CollectionFilter> filters}) {
    return ExpandableFilterRow(
      title: title,
      filters: filters,
      expandedNotifier: expandedSectionNotifier,
      onPressed: (filter) => close(context, filter is QueryFilter ? QueryFilter(filter.query) : filter),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // `buildResults` is called in the build phase,
      // so we post the call that will filter the collection
      // and possibly trigger a rebuild here
      close(context, _buildQueryFilter(true));
    });
    return const SizedBox.shrink();
  }

  QueryFilter _buildQueryFilter(bool colorful) {
    final cleanQuery = query.trim();
    return cleanQuery.isNotEmpty ? QueryFilter(cleanQuery, colorful: colorful) : null;
  }
}
