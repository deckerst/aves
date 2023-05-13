import 'package:aves/model/covers.dart';
import 'package:aves/model/favourites.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

enum AppExportItem { covers, favourites, settings }

extension ExtraAppExportItem on AppExportItem {
  String getText(BuildContext context) {
    switch (this) {
      case AppExportItem.covers:
        return context.l10n.appExportCovers;
      case AppExportItem.favourites:
        return context.l10n.appExportFavourites;
      case AppExportItem.settings:
        return context.l10n.appExportSettings;
    }
  }

  dynamic export(CollectionSource source) {
    switch (this) {
      case AppExportItem.covers:
        return covers.export(source);
      case AppExportItem.favourites:
        return favourites.export(source);
      case AppExportItem.settings:
        return settings.export();
    }
  }

  Future<void> import(dynamic jsonMap, CollectionSource source) async {
    switch (this) {
      case AppExportItem.covers:
        covers.import(jsonMap, source);
      case AppExportItem.favourites:
        favourites.import(jsonMap, source);
      case AppExportItem.settings:
        await settings.import(jsonMap);
    }
  }
}
