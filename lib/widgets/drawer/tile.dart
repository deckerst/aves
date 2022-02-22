import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/type.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:flutter/material.dart';

class DrawerFilterIcon extends StatelessWidget {
  final CollectionFilter? filter;

  const DrawerFilterIcon({
    Key? key,
    required this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final iconSize = 24 * textScaleFactor;

    final _filter = filter;
    if (_filter == null) return Icon(AIcons.allCollection, size: iconSize);
    return _filter.iconBuilder(context, iconSize) ?? const SizedBox();
  }
}

class DrawerFilterTitle extends StatelessWidget {
  final CollectionFilter? filter;

  const DrawerFilterTitle({
    Key? key,
    required this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _getString(CollectionFilter? filter) {
      final l10n = context.l10n;
      if (filter == null) return l10n.drawerCollectionAll;
      if (filter == FavouriteFilter.instance) return l10n.drawerCollectionFavourites;
      if (filter == MimeFilter.image) return l10n.drawerCollectionImages;
      if (filter == MimeFilter.video) return l10n.drawerCollectionVideos;
      if (filter == TypeFilter.animated) return l10n.drawerCollectionAnimated;
      if (filter == TypeFilter.motionPhoto) return l10n.drawerCollectionMotionPhotos;
      if (filter == TypeFilter.panorama) return l10n.drawerCollectionPanoramas;
      if (filter == TypeFilter.raw) return l10n.drawerCollectionRaws;
      if (filter == TypeFilter.sphericalVideo) return l10n.drawerCollectionSphericalVideos;
      return filter.getLabel(context);
    }

    return Text(_getString(filter));
  }
}

class DrawerPageIcon extends StatelessWidget {
  final String route;

  const DrawerPageIcon({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (route) {
      case AlbumListPage.routeName:
        return const Icon(AIcons.album);
      case CountryListPage.routeName:
        return const Icon(AIcons.location);
      case TagListPage.routeName:
        return const Icon(AIcons.tag);
      case AppDebugPage.routeName:
        return ShaderMask(
          shaderCallback: AColors.debugGradient.createShader,
          child: const Icon(AIcons.debug),
        );
      default:
        return const SizedBox();
    }
  }
}

class DrawerPageTitle extends StatelessWidget {
  final String route;

  const DrawerPageTitle({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _getString() {
      final l10n = context.l10n;
      switch (route) {
        case AlbumListPage.routeName:
          return l10n.albumPageTitle;
        case CountryListPage.routeName:
          return l10n.countryPageTitle;
        case TagListPage.routeName:
          return l10n.tagPageTitle;
        case AppDebugPage.routeName:
          return 'Debug';
        default:
          return route;
      }
    }

    return Text(_getString());
  }
}
