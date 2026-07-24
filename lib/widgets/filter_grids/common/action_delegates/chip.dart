import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
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
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
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
      case .goToAlbumPage:
        return filter is AlbumBaseFilter;
      case .goToCountryPage:
        return filter is LocationFilter && filter.level == LocationLevel.country;
      case .goToPlacePage:
        return filter is LocationFilter && filter.level == LocationLevel.place;
      case .goToTagPage:
        return filter is TagFilter;
      case .goToExplorerPage:
        return (filter is StoredAlbumFilter && !vaults.isVault(filter.album)) || filter is PathFilter;
      case .ratingOrGreater:
        return filter is RatingFilter && 1 <= filter.rating && filter.rating < 5 && filter.op != RatingFilter.opOrGreater;
      case .ratingOrLower:
        return filter is RatingFilter && 1 < filter.rating && filter.rating <= 5 && filter.op != RatingFilter.opOrLower;
      case .decompose:
        return filter is DynamicAlbumFilter;
      case .reverse:
      case .hide:
        return !settings.hiddenFilters.contains(filter);
      case .show:
        return settings.hiddenFilters.contains(filter);
      case .lockVault:
        return (filter is StoredAlbumFilter && vaults.isVault(filter.album) && !vaults.isLocked(filter.album));
    }
  }

  void onActionSelected(BuildContext context, CollectionFilter filter, ChipAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      case .goToAlbumPage:
        final initialGroup = albumGrouping.getFilterParent(filter);
        _goTo(context, filter, AlbumListPage.routeName, (context) => AlbumListPage(initialGroup: initialGroup));
      case .goToCountryPage:
        _goTo(context, filter, CountryListPage.routeName, (context) => const CountryListPage());
      case .goToPlacePage:
        _goTo(context, filter, PlaceListPage.routeName, (context) => const PlaceListPage());
      case .goToTagPage:
        final initialGroup = tagGrouping.getFilterParent(filter);
        _goTo(context, filter, TagListPage.routeName, (context) => TagListPage(initialGroup: initialGroup));
      case .goToExplorerPage:
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
      case .ratingOrGreater:
        SelectFilterNotification((filter as RatingFilter).copyWith(RatingFilter.opOrGreater)).dispatch(context);
      case .ratingOrLower:
        SelectFilterNotification((filter as RatingFilter).copyWith(RatingFilter.opOrLower)).dispatch(context);
      case .decompose:
        DecomposeFilterNotification(filter).dispatch(context);
      case .reverse:
        SelectFilterNotification(filter.reverse()).dispatch(context);
      case .hide:
        _hide(context, filter);
      case .show:
        _show(context, filter);
      case .lockVault:
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
    final l10n = context.l10n;

    if (!await showConfirmationDialog(
      context: context,
      message: l10n.hideFilterConfirmationDialogMessage,
      ok: l10n.hideButtonLabel,
    )) {
      return;
    }

    final filters = {filter};
    if (!await unlockFilters(context, filters)) return;

    settings.changeFilterVisibility(filters, false);
    lockFilters(filters);
  }

  Future<void> _show(BuildContext context, CollectionFilter filter) async {
    final filters = {filter};
    if (!await unlockFilters(context, filters)) return;

    settings.changeFilterVisibility(filters, true);
  }
}
