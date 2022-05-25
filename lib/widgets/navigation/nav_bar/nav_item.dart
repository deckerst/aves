import 'package:aves/model/filters/filters.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/navigation/drawer/tile.dart';
import 'package:aves/widgets/navigation/nav_display.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AvesBottomNavItem extends Equatable {
  final String route;
  final CollectionFilter? filter;

  @override
  List<Object?> get props => [route, filter];

  const AvesBottomNavItem({
    required this.route,
    this.filter,
  });

  Widget icon(BuildContext context) {
    if (route == CollectionPage.routeName) {
      return DrawerFilterIcon(filter: filter);
    }

    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final iconSize = 24 * textScaleFactor;
    return Icon(NavigationDisplay.getPageIcon(route), size: iconSize);
  }

  String label(BuildContext context) {
    if (route == CollectionPage.routeName) {
      return NavigationDisplay.getFilterTitle(context, filter);
    }
    return NavigationDisplay.getPageTitle(context, route);
  }
}
