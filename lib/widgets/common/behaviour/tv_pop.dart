import 'package:aves/model/device.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/enums/home_page.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// address `TV-DB` requirement from https://developer.android.com/docs/quality-guidelines/tv-app-quality
class TvPopScope extends StatelessWidget {
  final Widget child;

  const TvPopScope({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!device.isTelevision || _isHome(context)) {
          return SynchronousFuture(true);
        }

        Navigator.pushAndRemoveUntil(
          context,
          _getHomeRoute(),
          (route) => false,
        );
        return SynchronousFuture(false);
      },
      child: child,
    );
  }

  bool _isHome(BuildContext context) {
    final homePage = settings.homePage;
    final currentRoute = context.currentRouteName;

    if (currentRoute != homePage.routeName) return false;

    switch (homePage) {
      case HomePageSetting.collection:
        return context.read<CollectionLens>().filters.isEmpty;
      case HomePageSetting.albums:
        return true;
    }
  }

  Route _getHomeRoute() {
    switch (settings.homePage) {
      case HomePageSetting.collection:
        return MaterialPageRoute(
          settings: const RouteSettings(name: CollectionPage.routeName),
          builder: (context) => CollectionPage(
            source: context.read<CollectionSource>(),
            filters: null,
          ),
        );
      case HomePageSetting.albums:
        return MaterialPageRoute(
          settings: const RouteSettings(name: AlbumListPage.routeName),
          builder: (context) => const AlbumListPage(),
        );
    }
  }
}
