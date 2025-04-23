import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/covered/album_base.dart';
import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/vaults/details.dart';
import 'package:aves/model/vaults/vaults.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/vault_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/create_stored_album_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/edit_vault_dialog.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/album_set.dart';
import 'package:aves/widgets/filter_grids/common/app_bar.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

Future<AlbumBaseFilter?> pickAlbum({
  required BuildContext context,
  required MoveType? moveType,
  required Iterable<AlbumChipType> albumTypes,
}) async {
  final source = context.read<CollectionSource>();
  if (source.targetScope != CollectionSource.fullScope) {
    await reportService.log('Complete source initialization to pick album');
    // source may not be fully initialized in view mode
    source.canAnalyze = true;
    await source.init(scope: CollectionSource.fullScope);
  }
  return await Navigator.maybeOf(context)?.push(
    MaterialPageRoute<AlbumBaseFilter>(
      settings: const RouteSettings(name: _AlbumPickPage.routeName),
      builder: (context) => _AlbumPickPage(source: source, moveType: moveType, albumTypes: albumTypes),
    ),
  );
}

class _AlbumPickPage extends StatefulWidget {
  static const routeName = '/album_pick';

  final CollectionSource source;
  final MoveType? moveType;
  final Iterable<AlbumChipType> albumTypes;

  const _AlbumPickPage({
    required this.source,
    required this.moveType,
    required this.albumTypes,
  });

  @override
  State<_AlbumPickPage> createState() => _AlbumPickPageState();
}

class _AlbumPickPageState extends State<_AlbumPickPage> with FeedbackMixin, VaultAwareMixin {
  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<AppMode> _appModeNotifier = ValueNotifier(AppMode.pickFilterInternal);
  final ValueNotifier<Uri?> _groupUriNotifier = ValueNotifier(null);

  CollectionSource get source => widget.source;

  String get title {
    final l10n = context.l10n;
    return switch (widget.moveType) {
      MoveType.copy => l10n.albumPickPageTitleCopy,
      MoveType.move => l10n.albumPickPageTitleMove,
      MoveType.export => l10n.albumPickPageTitleExport,
      MoveType.toBin || MoveType.fromBin || null => l10n.albumPickPageTitlePick,
    };
  }

  static const _quickActions = [
    ChipSetAction.createAlbum,
  ];

  // `null` items are converted to dividers
  static const _menuActions = [
    ...ChipSetActions.general,
    null,
    ChipSetAction.toggleTitleSearch,
    null,
    ChipSetAction.createVault,
  ];

  @override
  void dispose() {
    _appBarHeightNotifier.dispose();
    _appModeNotifier.dispose();
    _groupUriNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ValueNotifier<AppMode>>.value(
      value: _appModeNotifier,
      child: Selector<Settings, (AlbumChipGroupFactor, ChipSortFactor)>(
        selector: (context, s) => (s.albumGroupFactor, s.albumSortFactor),
        builder: (context, s, child) {
          return StreamBuilder(
            stream: source.eventBus.on<AlbumsChangedEvent>(),
            builder: (context, snapshot) {
              return ValueListenableBuilder<Uri?>(
                valueListenable: _groupUriNotifier,
                builder: (context, groupUri, child) {
                  final gridItems = AlbumListPage.getAlbumGridItems(context, source, widget.albumTypes, groupUri);
                  return SelectionProvider<FilterGridItem<AlbumBaseFilter>>(
                    child: QueryProvider(
                      startEnabled: settings.getShowTitleQuery(context.currentRouteName!),
                      child: FilterGridPage<AlbumBaseFilter>(
                        settingsRouteKey: AlbumListPage.routeName,
                        appBar: FilterGridAppBar(
                          source: source,
                          title: title,
                          actionDelegate: AlbumChipSetActionDelegate(gridItems),
                          actionsBuilder: _buildActions,
                          isEmpty: false,
                          appBarHeightNotifier: _appBarHeightNotifier,
                        ),
                        appBarHeightNotifier: _appBarHeightNotifier,
                        sections: AlbumListPage.groupToSections(context, source, gridItems),
                        newFilters: source.getNewAlbumFilters(context),
                        sortFactor: settings.albumSortFactor,
                        showHeaders: settings.albumGroupFactor != AlbumChipGroupFactor.none,
                        selectable: false,
                        applyQuery: AlbumListPage.applyQuery,
                        emptyBuilder: () => EmptyContent(
                          icon: AIcons.album,
                          text: context.l10n.albumEmpty,
                        ),
                        heroType: HeroType.never,
                        onTileTap: (gridItem, _) async {
                          final filter = gridItem.filter;
                          if (!await unlockFilter(context, filter)) return;
                          _pickFilter(filter);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    AppMode appMode,
    Selection<FilterGridItem<AlbumBaseFilter>> selection,
    AlbumChipSetActionDelegate actionDelegate,
  ) {
    final itemCount = actionDelegate.allItems.length;
    final isSelecting = selection.isSelecting;
    final selectedItems = selection.selectedItems;
    final selectedFilters = selectedItems.map((v) => v.filter).toSet();

    bool isVisible(ChipSetAction action) => actionDelegate.isVisible(
          action,
          appMode: appMode,
          isSelecting: isSelecting,
          itemCount: itemCount,
          selectedFilters: selectedFilters,
        );

    void onActionSelected(ChipSetAction action) {
      switch (action) {
        case ChipSetAction.createAlbum:
          _createAlbum();
        case ChipSetAction.createVault:
          _createVault();
        default:
          actionDelegate.onActionSelected(context, action);
      }
    }

    return settings.useTvLayout
        ? _buildTelevisionActions(
            context: context,
            isVisible: isVisible,
            onActionSelected: onActionSelected,
          )
        : _buildMobileActions(
            context: context,
            isVisible: isVisible,
            onActionSelected: onActionSelected,
          );
  }

  List<Widget> _buildTelevisionActions({
    required BuildContext context,
    required bool Function(ChipSetAction action) isVisible,
    required void Function(ChipSetAction action) onActionSelected,
  }) {
    return [
      ...ChipSetActions.general,
    ].where(isVisible).map((action) {
      return CaptionedButton(
        icon: action.getIcon(),
        caption: action.getText(context),
        onPressed: () => onActionSelected(action),
      );
    }).toList();
  }

  List<Widget> _buildMobileActions({
    required BuildContext context,
    required bool Function(ChipSetAction action) isVisible,
    required void Function(ChipSetAction action) onActionSelected,
  }) {
    final animations = context.select<Settings, AccessibilityAnimations>((v) => v.accessibilityAnimations);
    return [
      if (widget.moveType != null)
        ..._quickActions.where(isVisible).map(
              (action) => IconButton(
                icon: action.getIcon(),
                onPressed: () => onActionSelected(action),
                tooltip: action.getText(context),
              ),
            ),
      PopupMenuButton<ChipSetAction>(
        itemBuilder: (context) {
          return _menuActions.where((v) => v == null || isVisible(v)).map((action) {
            if (action == null) return const PopupMenuDivider();
            return FilterGridAppBar.toMenuItem(context, action, enabled: true);
          }).toList();
        },
        onSelected: (action) async {
          // remove focus, if any, to prevent the keyboard from showing up
          // after the user is done with the popup menu
          FocusManager.instance.primaryFocus?.unfocus();

          // wait for the popup menu to hide before proceeding with the action
          await Future.delayed(animations.popUpAnimationDelay * timeDilation);
          onActionSelected(action);
        },
        popUpAnimationStyle: animations.popUpAnimationStyle,
      ),
    ];
  }

  Future<void> _createAlbum() async {
    final directory = await showDialog<String>(
      context: context,
      builder: (context) => const CreateStoredAlbumDialog(),
      routeSettings: const RouteSettings(name: CreateStoredAlbumDialog.routeName),
    );
    if (directory == null) return;

    // wait for the dialog to hide
    await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);

    _pickAlbum(directory);
  }

  Future<void> _createVault() async {
    final l10n = context.l10n;
    if (!await showSkippableConfirmationDialog(
      context: context,
      type: ConfirmationDialog.createVault,
      message: l10n.newVaultWarningDialogMessage,
      confirmationButtonLabel: l10n.continueButtonLabel,
    )) {
      return;
    }

    final details = await showDialog<VaultDetails>(
      context: context,
      builder: (context) => const EditVaultDialog(),
      routeSettings: const RouteSettings(name: EditVaultDialog.routeName),
    );
    if (details == null) return;

    // wait for the dialog to hide
    await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);

    await vaults.create(details);
    _pickAlbum(details.path);
  }

  void _pickAlbum(String directory) {
    source.createStoredAlbum(directory);
    _pickFilter(StoredAlbumFilter(directory, source.getStoredAlbumDisplayName(context, directory)));
  }

  void _pickFilter(AlbumBaseFilter filter) async {
    switch (filter) {
      case AlbumGroupFilter():
        _groupUriNotifier.value = filter.uri;
      case StoredAlbumFilter():
      case DynamicAlbumFilter():
        Navigator.maybeOf(context)?.pop<AlbumBaseFilter>(filter);
        break;
    }
  }
}
