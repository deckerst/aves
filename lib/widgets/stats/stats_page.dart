import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/basic/tv_edge_focus.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip.dart';
import 'package:aves/widgets/stats/date/histogram.dart';
import 'package:aves/widgets/stats/filter_table.dart';
import 'package:aves/widgets/stats/mime_donut.dart';
import 'package:aves/widgets/stats/percent_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatefulWidget {
  static const routeName = '/collection/stats';

  final Set<AvesEntry> entries;
  final CollectionSource source;
  final CollectionLens? parentCollection;

  const StatsPage({
    super.key,
    required this.entries,
    required this.source,
    this.parentCollection,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with FeedbackMixin, VaultAwareMixin {
  final Map<String, int> _entryCountPerCountry = {}, _entryCountPerState = {}, _entryCountPerPlace = {};
  final Map<String, int> _entryCountPerTag = {}, _entryCountPerAlbum = {};
  final Map<int, int> _entryCountPerRating = Map.fromEntries(List.generate(7, (i) => MapEntry(5 - i, 0)));
  late final ValueNotifier<bool> _isPageAnimatingNotifier;
  int _totalSizeBytes = 0;

  Set<AvesEntry> get entries => widget.entries;

  @override
  void initState() {
    super.initState();

    _isPageAnimatingNotifier = ValueNotifier(true);
    Future.delayed(ADurations.pageTransitionAnimation * timeDilation).then((_) {
      if (!mounted) return;
      _isPageAnimatingNotifier.value = false;
    });

    entries.forEach((entry) {
      _totalSizeBytes += entry.sizeBytes ?? 0;

      if (entry.hasAddress) {
        final address = entry.addressDetails!;
        var country = address.countryName;
        if (country != null && country.isNotEmpty) {
          country += '${LocationFilter.locationSeparator}${address.countryCode}';
          _entryCountPerCountry[country] = (_entryCountPerCountry[country] ?? 0) + 1;
        }
        var state = address.stateName;
        if (state != null && state.isNotEmpty) {
          state += '${LocationFilter.locationSeparator}${address.stateCode}';
          _entryCountPerState[state] = (_entryCountPerState[state] ?? 0) + 1;
        }
        final place = address.place;
        if (place != null && place.isNotEmpty) {
          _entryCountPerPlace[place] = (_entryCountPerPlace[place] ?? 0) + 1;
        }
      }

      entry.tags.forEach((tag) {
        _entryCountPerTag[tag] = (_entryCountPerTag[tag] ?? 0) + 1;
      });

      final album = entry.directory;
      if (album != null) {
        _entryCountPerAlbum[album] = (_entryCountPerAlbum[album] ?? 0) + 1;
      }

      final rating = entry.rating;
      _entryCountPerRating[rating] = (_entryCountPerRating[rating] ?? 0) + 1;
    });
  }

  @override
  void dispose() {
    _isPageAnimatingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useTvLayout = settings.useTvLayout;
    return ValueListenableBuilder<bool>(
      valueListenable: _isPageAnimatingNotifier,
      builder: (context, animating, child) {
        final l10n = context.l10n;

        Widget child = const SizedBox();

        if (!animating) {
          final durations = context.watch<DurationsData>();

          if (entries.isEmpty) {
            child = EmptyContent(
              icon: AIcons.image,
              text: l10n.collectionEmptyImages,
            );
          } else {
            final chartAnimationDuration = context.read<DurationsData>().chartTransition;

            final byMimeTypes = groupBy<AvesEntry, String>(entries, (entry) => entry.mimeType).map<String, int>((k, v) => MapEntry(k, v.length));
            final imagesByMimeTypes = Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('image')));
            final videoByMimeTypes = Map.fromEntries(byMimeTypes.entries.where((kv) => kv.key.startsWith('video')));
            final mimeDonuts = Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                MimeDonut(
                  icon: AIcons.image,
                  byMimeTypes: imagesByMimeTypes,
                  animationDuration: chartAnimationDuration,
                  onFilterSelection: (filter) => _onFilterSelection(context, filter),
                ),
                MimeDonut(
                  icon: AIcons.video,
                  byMimeTypes: videoByMimeTypes,
                  animationDuration: chartAnimationDuration,
                  onFilterSelection: (filter) => _onFilterSelection(context, filter),
                ),
              ],
            );

            final showRatings = _entryCountPerRating.entries.any((kv) => kv.key != 0 && kv.value > 0);
            final source = widget.source;
            final sizeIndicator = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AIcons.size),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(formatFileSize(context.locale, _totalSizeBytes)),
                  ),
                ],
              ),
            );
            child = NotificationListener<FilterNotification>(
              onNotification: (notification) {
                _onFilterSelection(context, notification.filter);
                return true;
              },
              child: AnimationLimiter(
                child: ListView(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: durations.staggeredAnimation,
                    delay: durations.staggeredAnimationDelay * timeDilation,
                    childAnimationBuilder: (child) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: child,
                      ),
                    ),
                    children: [
                      const TvEdgeFocus(),
                      mimeDonuts,
                      Histogram(
                        entries: entries,
                        animationDuration: chartAnimationDuration,
                        onFilterSelection: (filter) => _onFilterSelection(context, filter),
                      ),
                      const SizedBox(height: 16),
                      sizeIndicator,
                      const SizedBox(height: 16),
                      _LocationIndicator(entries: entries),
                      ..._buildFilterSection<String>(context, l10n.statsTopCountriesSectionTitle, _entryCountPerCountry, (v) => LocationFilter(LocationLevel.country, v)),
                      ..._buildFilterSection<String>(context, l10n.statsTopStatesSectionTitle, _entryCountPerState, (v) => LocationFilter(LocationLevel.state, v)),
                      ..._buildFilterSection<String>(context, l10n.statsTopPlacesSectionTitle, _entryCountPerPlace, (v) => LocationFilter(LocationLevel.place, v)),
                      ..._buildFilterSection<String>(context, l10n.statsTopTagsSectionTitle, _entryCountPerTag, TagFilter.new),
                      ..._buildFilterSection<String>(context, l10n.statsTopAlbumsSectionTitle, _entryCountPerAlbum, (v) => AlbumFilter(v, source.getAlbumDisplayName(context, v))),
                      if (showRatings) ..._buildFilterSection<int>(context, l10n.searchRatingSectionTitle, _entryCountPerRating, RatingFilter.new, sortByCount: false, maxRowCount: null),
                    ],
                  ),
                ),
              ),
            );
          }
        }

        return AvesScaffold(
          appBar: AppBar(
            automaticallyImplyLeading: !useTvLayout,
            title: Text(l10n.statsPageTitle),
          ),
          body: GestureAreaProtectorStack(
            child: SafeArea(
              bottom: false,
              child: TooltipTheme(
                data: TooltipTheme.of(context).copyWith(
                  preferBelow: false,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFilterSection<T extends Comparable>(
    BuildContext context,
    String title,
    Map<T, int> entryCountMap,
    CollectionFilter Function(T key) filterBuilder, {
    bool sortByCount = true,
    int? maxRowCount = 3,
  }) {
    if (entryCountMap.isEmpty) return [];

    final totalEntryCount = entries.length;
    final hasMore = maxRowCount != null && entryCountMap.length > maxRowCount;
    final onHeaderPressed = hasMore
        ? () => Navigator.maybeOf(context)?.push(
              MaterialPageRoute(
                settings: const RouteSettings(name: StatsTopPage.routeName),
                builder: (context) => StatsTopPage(
                  title: title,
                  tableBuilder: (context) => FilterTable(
                    totalEntryCount: totalEntryCount,
                    entryCountMap: entryCountMap,
                    filterBuilder: filterBuilder,
                    sortByCount: sortByCount,
                    maxRowCount: null,
                    onFilterSelection: (filter) => _onFilterSelection(context, filter),
                  ),
                  onFilterSelection: (filter) => _onFilterSelection(context, filter),
                ),
              ),
            )
        : null;
    Widget header = Text(
      title,
      style: AStyles.knownTitleText,
    );
    if (settings.useTvLayout) {
      header = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            const SizedBox(width: 16),
            Icon(AIcons.next, color: hasMore ? null : Theme.of(context).disabledColor),
          ],
        ),
      );
      header = Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: AlignmentDirectional.centerStart,
        // prevent ink response when tapping the header does nothing,
        // because otherwise Play Store reviewers think it is broken navigation
        child: onHeaderPressed != null
            ? InkWell(
                onTap: onHeaderPressed,
                borderRadius: const BorderRadius.all(Radius.circular(123)),
                child: header,
              )
            : Focus(child: header),
      );
    } else {
      header = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            header,
            const Spacer(),
            IconButton(
              icon: const Icon(AIcons.next),
              onPressed: onHeaderPressed,
              tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            ),
          ],
        ),
      );
    }

    return [
      header,
      FilterTable(
        totalEntryCount: totalEntryCount,
        entryCountMap: entryCountMap,
        filterBuilder: filterBuilder,
        sortByCount: sortByCount,
        maxRowCount: maxRowCount,
        onFilterSelection: (filter) => _onFilterSelection(context, filter),
      ),
    ];
  }

  Future<void> _onFilterSelection(BuildContext context, CollectionFilter filter) async {
    if (!await unlockFilter(context, filter)) return;

    if (widget.parentCollection != null) {
      _applyToParentCollectionPage(context, filter);
    } else {
      _jumpToCollectionPage(context, filter);
    }
  }

  void _applyToParentCollectionPage(BuildContext context, CollectionFilter filter) {
    widget.parentCollection!.addFilter(filter);
    // We delay closing the current page after applying the filter selection
    // so that hero animation target is ready in the `FilterBar`,
    // even when the target is a child of an `AnimatedList`.
    // Do not use `WidgetsBinding.instance.addPostFrameCallback`,
    // as it may not trigger if there is no subsequent build.
    Future.delayed(const Duration(milliseconds: 100), () => Navigator.maybeOf(context)?.popUntil((route) => route.settings.name == CollectionPage.routeName));
  }

  void _jumpToCollectionPage(BuildContext context, CollectionFilter filter) {
    Navigator.maybeOf(context)?.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: widget.source,
          filters: {filter},
        ),
      ),
      (route) => false,
    );
  }
}

class StatsTopPage extends StatelessWidget {
  static const routeName = '/collection/stats/top';

  final String title;
  final WidgetBuilder tableBuilder;
  final FilterCallback onFilterSelection;

  const StatsTopPage({
    super.key,
    required this.title,
    required this.tableBuilder,
    required this.onFilterSelection,
  });

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
        title: Text(title),
      ),
      body: GestureAreaProtectorStack(
        child: SafeArea(
          bottom: false,
          child: Builder(builder: (context) {
            return NotificationListener<FilterNotification>(
              onNotification: (notification) {
                onFilterSelection(notification.filter);
                return true;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8) +
                    EdgeInsets.only(
                      bottom: context.select<MediaQueryData, double>((mq) => mq.effectiveBottomPadding),
                    ),
                child: tableBuilder(context),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _LocationIndicator extends StatelessWidget {
  final Set<AvesEntry> entries;

  const _LocationIndicator({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalogued = entries.where((entry) => entry.isCatalogued);
    final withGps = catalogued.where((entry) => entry.hasGps);
    final withGpsCount = withGps.length;
    final withGpsPercent = withGpsCount / entries.length;
    final textScaler = MediaQuery.textScalerOf(context);
    final lineHeight = textScaler.scale(16);
    final barRadius = Radius.circular(lineHeight / 2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AIcons.location),
              Expanded(
                child: Stack(
                  // use a stack instead of `center` field, so that the widgets
                  // are centered even when the center child has larger height
                  alignment: Alignment.center,
                  children: [
                    LinearPercentIndicator(
                      percent: withGpsPercent,
                      lineHeight: lineHeight,
                      backgroundColor: Themes.secondLayerColor(context),
                      progressColor: theme.colorScheme.primary,
                      animation: context.select<Settings, bool>((v) => v.accessibilityAnimations.animate),
                      isRTL: context.isRtl,
                      barRadius: barRadius,
                      padding: EdgeInsets.symmetric(horizontal: lineHeight),
                    ),
                    LinearPercentIndicatorText(percent: withGpsPercent),
                  ],
                ),
              ),
              // end padding to match leading, so that inside label is aligned with outside label below
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.statsWithGps(withGpsCount),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
