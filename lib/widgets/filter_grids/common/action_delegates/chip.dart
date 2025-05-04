import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/covered/location.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/rating.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/highlight.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/explorer/explorer_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/countries_page.dart';
import 'package:aves/widgets/filter_grids/places_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChipActionDelegate with FeedbackMixin, VaultAwareMixin {
  bool isVisible(
    ChipAction action, {
    required CollectionFilter filter,
  }) {
    switch (action) {
      case ChipAction.goToAlbumPage:
        return filter is AlbumBaseFilter;
      case ChipAction.goToCountryPage:
        return filter is LocationFilter && filter.level == LocationLevel.country;
      case ChipAction.goToPlacePage:
        return filter is LocationFilter && filter.level == LocationLevel.place;
      case ChipAction.goToTagPage:
        return filter is TagFilter;
      case ChipAction.goToExplorerPage:
        return filter is StoredAlbumFilter || filter is PathFilter;
      case ChipAction.ratingOrGreater:
        return filter is RatingFilter && 1 < filter.rating && filter.rating < 5 && filter.op != RatingFilter.opOrGreater;
      case ChipAction.ratingOrLower:
        return filter is RatingFilter && 1 < filter.rating && filter.rating < 5 && filter.op != RatingFilter.opOrLower;
      case ChipAction.decompose:
        return filter is DynamicAlbumFilter;
      case ChipAction.reverse:
        return true;
      case ChipAction.hide:
        return !(filter is StoredAlbumFilter && vaults.isVault(filter.album));
      case ChipAction.lockVault:
        return (filter is StoredAlbumFilter && vaults.isVault(filter.album) && !vaults.isLocked(filter.album));
    }
  }

  void onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      case ChipAction.goToAlbumPage:
        final initialGroup = albumGrouping.getFilterParent(filter);
        _goTo(context, filter, AlbumListPage.routeName, (context) => AlbumListPage(initialGroup: initialGroup));
      case ChipAction.goToCountryPage:
        _goTo(context, filter, CountryListPage.routeName, (context) => const CountryListPage());
      case ChipAction.goToPlacePage:
        _goTo(context, filter, PlaceListPage.routeName, (context) => const PlaceListPage());
      case ChipAction.goToTagPage:
        _goTo(context, filter, TagListPage.routeName, (context) => const TagListPage());
      case ChipAction.goToExplorerPage:
        String? path;
        if (filter is StoredAlbumFilter) {
          path = filter.album;
        } else if (filter is PathFilter) {
          path = filter.path;
        }
        if (path != null) {
          Navigator.maybeOf(context)?.pushAndRemoveUntil(
            MaterialPageRoute(
              settings: const RouteSettings(name: ExplorerPage.routeName),
              builder: (context) => ExplorerPage(path: path),
            ),
            (route) => false,
          );
        }
      case ChipAction.ratingOrGreater:
        SelectFilterNotification((filter as RatingFilter).copyWith(RatingFilter.opOrGreater)).dispatch(context);
      case ChipAction.ratingOrLower:
        SelectFilterNotification((filter as RatingFilter).copyWith(RatingFilter.opOrLower)).dispatch(context);
      case ChipAction.decompose:
        DecomposeFilterNotification(filter).dispatch(context);
      case ChipAction.reverse:
        SelectFilterNotification(filter.reverse()).dispatch(context);
      case ChipAction.hide:
        _hide(context, filter);
      case ChipAction.lockVault:
        if (filter is StoredAlbumFilter) {
          lockFilters({filter});
        }
    }
  }

  void _goTo(
    BuildContext context,
    CollectionFilter filter,
    String routeName,
    WidgetBuilder pageBuilder,
  ) {
    context.read<HighlightInfo>().set(filter);
    Navigator.maybeOf(context)?.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: pageBuilder,
      ),
      (route) => false,
    );
  }

  Future<void> _hide(BuildContext context, CollectionFilter filter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AvesDialog(
        content: Text(context.l10n.hideFilterConfirmationDialogMessage),
        actions: [
          const CancelButton(),
          TextButton(
            onPressed: () => Navigator.maybeOf(context)?.pop(true),
            child: Text(context.l10n.hideButtonLabel),
          ),
        ],
      ),
      routeSettings: const RouteSettings(name: AvesDialog.confirmationRouteName),
    );
    if (confirmed == null || !confirmed) return;

    settings.changeFilterVisibility({filter}, false);
  }
}
