import 'dart:convert';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/about/about_page.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/search/page.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/debug/app_debug_page.dart';
import 'package:aves/widgets/explorer/explorer_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/home/home_page.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/navigation/nav_display.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvesNavItem extends Equatable {
  final String route;
  final Set<CollectionFilter>? filters;
  final String? path;

  @override
  List<Object?> get props => [route, filters, path];

  const AvesNavItem({
    required this.route,
    this.filters,
    this.path,
  });

  Widget getIcon(BuildContext context) {
    if (route == CollectionPage.routeName) {
      return DrawerFilterIcon(filter: filters?.firstOrNull);
    }

    final textScaler = MediaQuery.textScalerOf(context);
    final iconSize = textScaler.scale(24);
    return Icon(NavigationDisplay.getPageIcon(route), size: iconSize);
  }

  String getText(BuildContext context) {
    if (route == CollectionPage.routeName) {
      return NavigationDisplay.getFilterTitle(context, filters?.firstOrNull);
    }
    return NavigationDisplay.getPageTitle(context, route);
  }

  Future<void> goTo(BuildContext context, {bool? topLevel}) async {
    topLevel ??= _defaultTopLevel;
    final route = routeBuilder(context, topLevel: topLevel);
    if (topLevel) {
      await Navigator.maybeOf(context)?.pushAndRemoveUntil(
        route,
        (route) => false,
      );
    } else {
      await Navigator.maybeOf(context)?.push(route);
    }
  }

  bool get _defaultTopLevel {
    switch (route) {
      case AboutPage.routeName:
      case AppDebugPage.routeName:
      case SearchPage.routeName:
      case SettingsPage.routeName:
        return false;
      default:
        return true;
    }
  }

  Route routeBuilder(BuildContext context, {required bool topLevel}) {
    switch (route) {
      case HomePage.routeName:
        return settings.homeNavItem.routeBuilder(context, topLevel: topLevel);
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
          settings: RouteSettings(name: route),
          builder: _materialPageBuilder(route),
        );
    }
  }

  WidgetBuilder _materialPageBuilder(String route) {
    switch (route) {
      case CollectionPage.routeName:
        return (context) => CollectionPage(
              source: context.read<CollectionSource>(),
              filters: filters,
            );
      case AlbumListPage.routeName:
        return (_) => const AlbumListPage(initialGroup: null);
      case CountryListPage.routeName:
        return (_) => const CountryListPage();
      case PlaceListPage.routeName:
        return (_) => const PlaceListPage();
      case TagListPage.routeName:
        return (_) => const TagListPage(initialGroup: null);
      case AboutPage.routeName:
        return (_) => const AboutPage();
      case AppDebugPage.routeName:
        return (_) => const AppDebugPage();
      case ExplorerPage.routeName:
        return (_) => ExplorerPage(path: path);
      case SettingsPage.routeName:
        return (_) => const SettingsPage();
      default:
        throw Exception('unknown route=$route');
    }
  }

  // serialization

  static AvesNavItem _fromMap(Map<String, dynamic> json) {
    return AvesNavItem(
      route: json['route'],
      filters: (json['filters'] as List?)?.cast<String>().map(CollectionFilter.fromJson).nonNulls.toSet(),
      path: json['path'],
    );
  }

  Map<String, dynamic> _toMap() => {
        'route': route,
        if (filters != null) 'filters': filters?.map((v) => v.toJson()).toList(),
        if (path != null) 'path': path,
      };

  String toJson() => jsonEncode(_toMap());

  static AvesNavItem? fromJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is Map<String, dynamic>) {
        return _fromMap(jsonMap);
      }
      debugPrint('failed to parse navigation item from json=$jsonString');
    } catch (error) {
      // no need for stack
      debugPrint('failed to parse navigation item from json=$jsonString error=$error');
    }
    return null;
  }
}
