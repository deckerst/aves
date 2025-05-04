import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/explorer/explorer_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef TileRouteBuilder = Route Function(BuildContext context, String routeName, bool topLevel);

class PageNavTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final bool topLevel;
  final String routeName;
  final bool Function()? isSelected;
  final TileRouteBuilder? routeBuilder;

  const PageNavTile({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.topLevel = true,
    required this.routeName,
    this.isSelected,
    this.routeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        // key is expected by test driver
        key: Key('$routeName-tile'),
        leading: leading ?? DrawerPageIcon(route: routeName),
        title: title ?? DrawerPageTitle(route: routeName),
        trailing: trailing != null
            ? Builder(
                builder: (context) => DefaultTextStyle.merge(
                  style: TextStyle(
                    color: IconTheme.of(context).color!.withValues(alpha: .6),
                  ),
                  child: trailing!,
                ),
              )
            : null,
        onTap: () {
          Navigator.maybeOf(context)?.pop();
          final route = (routeBuilder ?? defaultRouteBuilder).call(context, routeName, topLevel);
          if (topLevel) {
            Navigator.maybeOf(context)?.pushAndRemoveUntil(
              route,
              (route) => false,
            );
          } else {
            Navigator.maybeOf(context)?.push(route);
          }
        },
        selected: context.currentRouteName == routeName && (isSelected?.call() ?? true),
      ),
    );
  }

  static Route defaultRouteBuilder(BuildContext context, String routeName, bool topLevel) {
    switch (routeName) {
      case SearchPage.routeName:
        final currentCollection = context.read<CollectionLens?>();
        return SearchPageRoute(
          delegate: CollectionSearchDelegate(
            searchFieldLabel: context.l10n.searchCollectionFieldHint,
            searchFieldStyle: Themes.searchFieldStyle(context),
            source: context.read<CollectionSource>(),
            parentCollection: topLevel ? currentCollection?.copyWith() : currentCollection,
          ),
        );
      default:
        return MaterialPageRoute(
          settings: RouteSettings(name: routeName),
          builder: _materialPageBuilder(routeName),
        );
    }
  }

  static WidgetBuilder _materialPageBuilder(String routeName) {
    switch (routeName) {
      case AlbumListPage.routeName:
        return (_) => const AlbumListPage(initialGroup: null);
      case CountryListPage.routeName:
        return (_) => const CountryListPage();
      case PlaceListPage.routeName:
        return (_) => const PlaceListPage();
      case TagListPage.routeName:
        return (_) => const TagListPage();
      case AboutPage.routeName:
        return (_) => const AboutPage();
      case AppDebugPage.routeName:
        return (_) => const AppDebugPage();
      case ExplorerPage.routeName:
        return (_) => const ExplorerPage();
      case SettingsPage.routeName:
        return (_) => const SettingsPage();
      default:
        throw Exception('unknown route=$routeName');
    }
  }
}
