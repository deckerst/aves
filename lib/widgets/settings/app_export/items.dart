import 'package:aves/model/covers.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum AppExportItem { covers, dynamicAlbums, favourites, settings }

extension ExtraAppExportItem on AppExportItem {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      AppExportItem.covers => l10n.appExportCovers,
      AppExportItem.dynamicAlbums => l10n.appExportDynamicAlbums,
      AppExportItem.favourites => l10n.appExportFavourites,
      AppExportItem.settings => l10n.appExportSettings,
    };
  }

  dynamic export(CollectionSource source) {
    return switch (this) {
      AppExportItem.covers => covers.export(source),
      AppExportItem.dynamicAlbums => dynamicAlbums.export(),
      AppExportItem.favourites => favourites.export(source),
      AppExportItem.settings => settings.export(),
    };
  }

  Future<void> import(dynamic jsonMap, CollectionSource source) async {
    switch (this) {
      case AppExportItem.covers:
        covers.import(jsonMap, source);
      case AppExportItem.dynamicAlbums:
        dynamicAlbums.import(jsonMap);
      case AppExportItem.favourites:
        favourites.import(jsonMap, source);
      case AppExportItem.settings:
        await settings.import(jsonMap);
        albumGrouping.setGroups(settings.albumGroups);
    }
  }
}
