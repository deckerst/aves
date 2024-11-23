import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/explorer/explorer_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final TvNavigationPopHandler tvNavigationPopHandler = TvNavigationPopHandler._private();

// address `TV-DB` requirement from https://developer.android.com/docs/quality-guidelines/tv-app-quality
class TvNavigationPopHandler implements PopHandler {
  TvNavigationPopHandler._private();

  @override
  bool canPop(BuildContext context) {
    if (context.select<Settings, bool>((v) => !v.useTvLayout)) return true;
    if (_isHome(context)) return true;
    return false;
  }

  @override
  void onPopBlocked(BuildContext context) {
    Navigator.maybeOf(context)?.pushAndRemoveUntil(
      _getHomeRoute(),
      (route) => false,
    );
  }

  static bool _isHome(BuildContext context) {
    final homePage = settings.homePage;
    final currentRoute = context.currentRouteName;

    if (currentRoute != homePage.routeName) return false;

    return switch (homePage) {
      HomePageSetting.collection => context.read<CollectionLens>().filters.isEmpty,
      HomePageSetting.albums || HomePageSetting.tags || HomePageSetting.explorer => true,
    };
  }

  static Route _getHomeRoute() {
    final homePage = settings.homePage;
    Route buildRoute(WidgetBuilder builder) => MaterialPageRoute(
          settings: RouteSettings(name: homePage.routeName),
          builder: builder,
        );

    return switch (homePage) {
      HomePageSetting.collection => buildRoute((context) => CollectionPage(source: context.read<CollectionSource>(), filters: null)),
      HomePageSetting.albums => buildRoute((context) => const AlbumListPage()),
      HomePageSetting.tags => buildRoute((context) => const TagListPage()),
      HomePageSetting.explorer => buildRoute((context) => const ExplorerPage()),
    };
  }
}
