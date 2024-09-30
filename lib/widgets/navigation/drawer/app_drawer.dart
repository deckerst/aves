import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/trash.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/location/country.dart';
import 'package:aves/model/source/location/place.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/identity/aves_logo.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/navigation/drawer/collection_nav_tile.dart';
import 'package:aves/widgets/navigation/drawer/page_nav_tile.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  // collection loaded in the `CollectionPage`, if any
  final CollectionLens? currentCollection;

  const AppDrawer({
    super.key,
    this.currentCollection,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();

  static List<String> getDefaultAlbums(BuildContext context) {
    final source = context.read<CollectionSource>();
    final specialAlbums = source.rawAlbums.where((album) {
      final type = androidFileUtils.getAlbumType(album);
      return [AlbumType.camera, AlbumType.screenshots].contains(type);
    }).toList()
      ..sort(source.compareAlbumsByName);
    return specialAlbums;
  }
}

class _AppDrawerState extends State<AppDrawer> with WidgetsBindingObserver {
  // using the default controller conflicts
  // with bottom nav bar primary scroll monitoring
  final ScrollController _scrollController = ScrollController();
  late Future<List<dynamic>> _profileSwitchFuture;
  bool _profileSwitchPermissionRequested = false;

  CollectionLens? get currentCollection => widget.currentCollection;

  @override
  void initState() {
    super.initState();
    _initProfileSwitchFuture();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_profileSwitchPermissionRequested) {
          _profileSwitchPermissionRequested = false;
          _initProfileSwitchFuture();
          setState(() {});
        }
      default:
        break;
    }
  }

  void _initProfileSwitchFuture() {
    _profileSwitchFuture = Future.wait([
      appProfileService.canRequestInteractAcrossProfiles(),
      appProfileService.canInteractAcrossProfiles(),
      appProfileService.getProfileSwitchingLabel(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final drawerItems = <Widget>[
      _buildHeader(context),
      ..._buildTypeLinks(),
      _buildAlbumLinks(context),
      ..._buildPageLinks(context),
      if (settings.enableBin) ...[
        const Divider(),
        binTile(context),
      ],
      if (!kReleaseMode) ...[
        const Divider(),
        debugTile,
      ],
    ];

    return Drawer(
      child: ListTileTheme.merge(
        selectedColor: Theme.of(context).colorScheme.primary,
        horizontalTitleGap: 20,
        visualDensity: VisualDensity.comfortable,
        child: Selector<MediaQueryData, double>(
          selector: (context, mq) => mq.effectiveBottomPadding,
          builder: (context, mqPaddingBottom, child) {
            final textScaler = MediaQuery.textScalerOf(context);
            final iconTheme = IconTheme.of(context);
            return SingleChildScrollView(
              controller: _scrollController,
              // key is expected by test driver
              key: const Key('drawer-scrollview'),
              padding: EdgeInsets.only(bottom: mqPaddingBottom),
              child: IconTheme(
                data: iconTheme.copyWith(
                  size: textScaler.scale(iconTheme.size!),
                ),
                child: Column(
                  children: drawerItems,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;

    Future<void> goTo(String routeName, WidgetBuilder pageBuilder) async {
      Navigator.maybeOf(context)?.pop();
      await Future.delayed(ADurations.drawerTransitionLoose);
      await Navigator.maybeOf(context)?.push(MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: pageBuilder,
      ));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;

    final drawerButtonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(const EdgeInsetsDirectional.only(start: 12, end: 16)),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: colorScheme.primary,
      child: SafeArea(
        bottom: false,
        child: OutlinedButtonTheme(
          data: OutlinedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(onPrimary),
              overlayColor: WidgetStateProperty.all<Color>(onPrimary.withOpacity(.12)),
              side: WidgetStateProperty.all<BorderSide>(BorderSide(width: 1, color: onPrimary.withOpacity(.24))),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const AvesLogo(size: 48),
                    OutlinedText(
                      textSpans: [
                        TextSpan(
                          text: l10n.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w300,
                            letterSpacing: canHaveLetterSpacing(context.locale) ? 1 : 0,
                            fontFeatures: const [FontFeature.enable('smcp')],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    // key is expected by test driver
                    key: const Key('drawer-about-button'),
                    onPressed: () => goTo(AboutPage.routeName, (_) => const AboutPage()),
                    style: drawerButtonStyle,
                    icon: const Icon(AIcons.info),
                    label: Text(l10n.drawerAboutButton),
                  ),
                  OutlinedButton.icon(
                    // key is expected by test driver
                    key: const Key('drawer-settings-button'),
                    onPressed: () => goTo(SettingsPage.routeName, (_) => const SettingsPage()),
                    style: drawerButtonStyle,
                    icon: const Icon(AIcons.settings),
                    label: Text(l10n.drawerSettingsButton),
                  ),
                ],
              ),
              FutureBuilder<List<dynamic>>(
                future: _profileSwitchFuture,
                builder: (context, snapshot) {
                  final flags = snapshot.data;
                  if (flags == null) return const SizedBox();

                  final [
                    bool canRequestInteractAcrossProfiles,
                    bool canSwitchProfile,
                    String profileSwitchingLabel,
                  ] = flags;
                  if ((!canRequestInteractAcrossProfiles && !canSwitchProfile) || profileSwitchingLabel.isEmpty) return const SizedBox();

                  return OutlinedButton(
                    onPressed: () async {
                      if (canSwitchProfile) {
                        await appProfileService.switchProfile();
                      } else {
                        _profileSwitchPermissionRequested = await appProfileService.requestInteractAcrossProfiles();
                      }
                    },
                    child: Text(profileSwitchingLabel),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTypeLinks() {
    final hiddenFilters = settings.hiddenFilters;
    final typeBookmarks = settings.drawerTypeBookmarks;
    final currentFilters = currentCollection?.filters;
    return typeBookmarks
        .where((filter) => !hiddenFilters.contains(filter))
        .map((filter) => CollectionNavTile(
              // key is expected by test driver
              key: Key('drawer-type-${filter?.key}'),
              leading: DrawerFilterIcon(filter: filter),
              title: DrawerFilterTitle(filter: filter),
              filter: filter,
              isSelected: () {
                if (currentFilters == null || currentFilters.length > 1) return false;
                return currentFilters.firstOrNull == filter;
              },
            ))
        .toList();
  }

  Widget _buildAlbumLinks(BuildContext context) {
    final source = context.read<CollectionSource>();
    final currentFilters = currentCollection?.filters;
    return StreamBuilder(
        stream: source.eventBus.on<AlbumsChangedEvent>(),
        builder: (context, snapshot) {
          final albums = settings.drawerAlbumBookmarks ?? AppDrawer.getDefaultAlbums(context);
          if (albums.isEmpty) return const SizedBox();
          return Column(
            children: [
              const Divider(),
              ...albums.map((album) => AlbumNavTile(
                    album: album,
                    isSelected: () {
                      if (currentFilters == null || currentFilters.length > 1) return false;
                      final currentFilter = currentFilters.firstOrNull;
                      return currentFilter is AlbumFilter && currentFilter.album == album;
                    },
                  )),
            ],
          );
        });
  }

  List<Widget> _buildPageLinks(BuildContext context) {
    final pageBookmarks = settings.drawerPageBookmarks;
    if (pageBookmarks.isEmpty) return [];

    final source = context.read<CollectionSource>();
    return [
      const Divider(),
      ...pageBookmarks.map((route) {
        Widget? trailing;
        switch (route) {
          case AlbumListPage.routeName:
            trailing = StreamBuilder(
              stream: source.eventBus.on<AlbumsChangedEvent>(),
              builder: (context, _) => Text('${source.rawAlbums.length}'),
            );
          case CountryListPage.routeName:
            trailing = StreamBuilder(
              stream: source.eventBus.on<CountriesChangedEvent>(),
              builder: (context, _) => Text('${source.sortedCountries.length}'),
            );
          case PlaceListPage.routeName:
            trailing = StreamBuilder(
              stream: source.eventBus.on<PlacesChangedEvent>(),
              builder: (context, _) => Text('${source.sortedPlaces.length}'),
            );
          case TagListPage.routeName:
            trailing = StreamBuilder(
              stream: source.eventBus.on<TagsChangedEvent>(),
              builder: (context, _) => Text('${source.sortedTags.length}'),
            );
        }

        return PageNavTile(
          // key is expected by test driver
          key: Key('drawer-page-$route'),
          trailing: trailing,
          topLevel: route != SearchPage.routeName,
          routeName: route,
        );
      }),
    ];
  }

  Widget binTile(BuildContext context) {
    final source = context.read<CollectionSource>();
    final trashSize = source.trashedEntries.fold<int>(0, (sum, entry) => sum + (entry.sizeBytes ?? 0));

    const filter = TrashFilter.instance;
    return CollectionNavTile(
      leading: const DrawerFilterIcon(filter: filter),
      title: const DrawerFilterTitle(filter: filter),
      trailing: Text(formatFileSize(context.locale, trashSize, round: 0)),
      filter: filter,
      isSelected: () => currentCollection?.filters.contains(filter) ?? false,
    );
  }

  Widget get debugTile => const PageNavTile(
        // key is expected by test driver
        key: Key('drawer-debug'),
        topLevel: false,
        routeName: AppDebugPage.routeName,
      );
}
