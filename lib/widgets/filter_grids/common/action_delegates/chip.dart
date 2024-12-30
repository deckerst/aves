import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/filters/rating.dart';
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
      case ChipAction.goToCountryPage:
      case ChipAction.goToPlacePage:
      case ChipAction.goToTagPage:
      case ChipAction.goToExplorerPage:
      case ChipAction.ratingOrGreater:
      case ChipAction.ratingOrLower:
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
        _goTo(context, filter, AlbumListPage.routeName, (context) => const AlbumListPage());
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
        FilterNotification((filter as RatingFilter).copyWith(RatingFilter.opOrGreater)).dispatch(context);
      case ChipAction.ratingOrLower:
        FilterNotification((filter as RatingFilter).copyWith(RatingFilter.opOrLower)).dispatch(context);
      case ChipAction.reverse:
        FilterNotification(filter.reverse()).dispatch(context);
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

@immutable
class FilterNotification extends Notification {
  final CollectionFilter filter;

  const FilterNotification(this.filter);
}
