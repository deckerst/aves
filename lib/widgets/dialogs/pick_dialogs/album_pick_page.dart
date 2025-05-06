import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
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
import 'package:aves/widgets/common/providers/filter_group_provider.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/dialogs/aves_confirmation_dialog.dart';
import 'package:aves/widgets/dialogs/filter_editors/create_group_dialog.dart';
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
  required Uri? initialGroup,
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
      builder: (context) => _AlbumPickPage(
        source: source,
        moveType: moveType,
        albumChipTypes: albumTypes,
        initialGroup: initialGroup,
      ),
    ),
  );
}

class _AlbumPickPage extends StatefulWidget {
  static const routeName = '/album_pick';

  final CollectionSource source;
  final MoveType? moveType;
  final Iterable<AlbumChipType> albumChipTypes;
  final Uri? initialGroup;

  const _AlbumPickPage({
    required this.source,
    required this.moveType,
    required this.albumChipTypes,
    required this.initialGroup,
  });

  @override
  State<_AlbumPickPage> createState() => _AlbumPickPageState();
}

class _AlbumPickPageState extends State<_AlbumPickPage> with FeedbackMixin, VaultAwareMixin {
  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<AppMode> _appModeNotifier = ValueNotifier(AppMode.pickFilterInternal);

  CollectionSource get source => widget.source;

  Iterable<AlbumChipType> get albumChipTypes => widget.albumChipTypes;

  bool get isPickingGroup => albumChipTypes.length == 1 && albumChipTypes.contains(AlbumChipType.group);

  String get title {
    final l10n = context.l10n;
    if (isPickingGroup) {
      return l10n.groupPickerTitle;
    } else {
      return switch (widget.moveType) {
        MoveType.copy => l10n.albumPickPageTitleCopy,
        MoveType.move => l10n.albumPickPageTitleMove,
        MoveType.export => l10n.albumPickPageTitleExport,
        MoveType.toBin || MoveType.fromBin || null => l10n.albumPickPageTitlePick,
      };
    }
  }

  @override
  void dispose() {
    _appBarHeightNotifier.dispose();
    _appModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ValueNotifier<AppMode>>.value(
      value: _appModeNotifier,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<FilterGrouping>.value(value: albumGrouping),
          FilterGroupProvider(initialValue: widget.initialGroup),
        ],
        child: Builder(
          // to access filter group provider from subtree context
          builder: (context) {
            return Selector<Settings, (AlbumChipSectionFactor, ChipSortFactor)>(
              selector: (context, s) => (s.albumSectionFactor, s.albumSortFactor),
              builder: (context, s, child) {
                return StreamBuilder(
                  stream: source.eventBus.on<AlbumsChangedEvent>(),
                  builder: (context, snapshot) {
                    final groupUri = context.watch<FilterGroupNotifier>().value;
                    final gridItems = AlbumListPage.getAlbumGridItems(context, source, albumChipTypes, groupUri);
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
                          showHeaders: settings.albumSectionFactor != AlbumChipSectionFactor.none,
                          selectable: false,
                          emptyBuilder: () => isPickingGroup
                              ? EmptyContent(
                                  icon: AIcons.group,
                                  text: context.l10n.groupEmpty,
                                )
                              : EmptyContent(
                                  icon: AIcons.album,
                                  text: context.l10n.albumEmpty,
                                ),
                          heroType: HeroType.never,
                          floatingActionButton: _buildFab(context),
                          onTileTap: (gridItem, _) async {
                            final filter = gridItem.filter;
                            if (!await unlockFilter(context, filter)) return;
                            switch (filter) {
                              case AlbumGroupFilter _:
                                context.read<FilterGroupNotifier>().value = filter.uri;
                              case StoredAlbumFilter _:
                              case DynamicAlbumFilter _:
                                _pickFilter(context, filter);
                            }
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
      ),
    );
  }

  Widget? _buildFab(BuildContext context) {
    return isPickingGroup
        ? FloatingActionButton.extended(
            onPressed: () {
              final groupUri = context.read<FilterGroupNotifier>().value;
              final filter = groupUri != null ? albumGrouping.uriToFilter(groupUri) : AlbumGroupFilter.root;
              if (filter is AlbumBaseFilter) {
                _pickFilter(context, filter);
              }
            },
            icon: const Icon(AIcons.apply),
            label: Text(context.l10n.groupPickerUseThisGroupButton),
          )
        : null;
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
        case ChipSetAction.createGroup:
          final parentGroupUri = context.read<FilterGroupNotifier>().value;
          _createGroup(parentGroupUri);
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

    final canCreateStoredAlbums = widget.moveType != null;
    final quickActions = [
      if (isPickingGroup) ChipSetAction.createGroup,
      if (canCreateStoredAlbums) ChipSetAction.createAlbum,
    ];

    // `null` items are converted to dividers
    final menuActions = [
      ...ChipSetActions.general,
      null,
      ChipSetAction.toggleTitleSearch,
      if (canCreateStoredAlbums) ...[
        null,
        ChipSetAction.createVault,
      ]
    ];

    return [
      ...quickActions.where(isVisible).map(
            (action) => IconButton(
              icon: action.getIcon(),
              onPressed: () => onActionSelected(action),
              tooltip: action.getText(context),
            ),
          ),
      PopupMenuButton<ChipSetAction>(
        itemBuilder: (context) {
          return menuActions.where((v) => v == null || isVisible(v)).map((action) {
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

  Future<void> _createGroup(Uri? parentGroupUri) async {
    final uri = await showDialog<Uri>(
      context: context,
      builder: (context) => CreateGroupDialog(grouping: albumGrouping, parentGroupUri: parentGroupUri),
      routeSettings: const RouteSettings(name: CreateGroupDialog.routeName),
    );
    if (uri == null) return;

    // wait for the dialog to hide
    await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);

    _pickFilter(context, AlbumGroupFilter.empty(uri));
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

    _pickStoredAlbum(context, directory);
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
    _pickStoredAlbum(context, details.path);
  }

  void _pickStoredAlbum(BuildContext context, String directory) {
    source.createStoredAlbum(directory);
    final displayName = source.getStoredAlbumDisplayName(context, directory);
    _pickFilter(context, StoredAlbumFilter(directory, displayName));
  }

  void _pickFilter(BuildContext context, AlbumBaseFilter filter) async {
    Navigator.maybeOf(context)?.pop<AlbumBaseFilter>(filter);
  }
}
