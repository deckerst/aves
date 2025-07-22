import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/container/tag_group.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/tag.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/buttons/captioned_button.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/providers/filter_group_provider.dart';
import 'package:aves/widgets/common/providers/query_provider.dart';
import 'package:aves/widgets/common/providers/selection_provider.dart';
import 'package:aves/widgets/dialogs/filter_editors/create_group_dialog.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/tag_set.dart';
import 'package:aves/widgets/filter_grids/common/app_bar.dart';
import 'package:aves/widgets/filter_grids/common/enums.dart';
import 'package:aves/widgets/filter_grids/common/filter_grid_page.dart';
import 'package:aves/widgets/filter_grids/tags_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

Future<TagBaseFilter?> pickTag({
  required BuildContext context,
  required Iterable<ChipType> chipTypes,
  required Uri? initialGroup,
}) async {
  final source = context.read<CollectionSource>();
  if (source.targetScope != CollectionSource.fullScope) {
    await reportService.log('Complete source initialization to pick tag');
    // source may not be fully initialized in view mode
    source.canAnalyze = true;
    await source.init(scope: CollectionSource.fullScope);
  }
  return await Navigator.maybeOf(context)?.push(
    MaterialPageRoute<TagBaseFilter>(
      settings: const RouteSettings(name: _TagPickPage.routeName),
      builder: (context) => _TagPickPage(
        source: source,
        chipTypes: chipTypes,
        initialGroup: initialGroup,
      ),
    ),
  );
}

class _TagPickPage extends StatefulWidget {
  static const routeName = '/tag_pick';

  final CollectionSource source;
  final Iterable<ChipType> chipTypes;
  final Uri? initialGroup;

  const _TagPickPage({
    required this.source,
    required this.chipTypes,
    required this.initialGroup,
  });

  @override
  State<_TagPickPage> createState() => _TagPickPageState();
}

class _TagPickPageState extends State<_TagPickPage> with FeedbackMixin {
  final ValueNotifier<double> _appBarHeightNotifier = ValueNotifier(0);
  final ValueNotifier<AppMode> _appModeNotifier = ValueNotifier(AppMode.pickFilterInternal);

  CollectionSource get source => widget.source;

  Iterable<ChipType> get chipTypes => widget.chipTypes;

  bool get isPickingGroup => chipTypes.length == 1 && chipTypes.contains(ChipType.group);

  String get title {
    final l10n = context.l10n;
    if (isPickingGroup) {
      return l10n.groupPickerTitle;
    } else {
      return l10n.tagPickPageTitle;
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
          ChangeNotifierProvider<FilterGrouping>.value(value: tagGrouping),
          FilterGroupProvider(initialValue: widget.initialGroup),
        ],
        child: Builder(
          // to access filter group provider from subtree context
          builder: (context) {
            return Selector<Settings, ChipSortFactor>(
              selector: (context, s) => s.tagSortFactor,
              builder: (context, s, child) {
                return StreamBuilder(
                  stream: source.eventBus.on<TagsChangedEvent>(),
                  builder: (context, snapshot) {
                    final groupUri = context.watch<FilterGroupNotifier>().value;
                    final gridItems = TagListPage.getGridItems(source, chipTypes, groupUri);
                    final scrollController = PrimaryScrollController.of(context);
                    return SelectionProvider<FilterGridItem<TagBaseFilter>>(
                      child: QueryProvider(
                        startEnabled: settings.getShowTitleQuery(context.currentRouteName!),
                        child: FilterGridPage<TagBaseFilter>(
                          settingsRouteKey: TagListPage.routeName,
                          appBar: FilterGridAppBar(
                            source: source,
                            title: title,
                            actionDelegate: TagChipSetActionDelegate(gridItems),
                            actionsBuilder: _buildActions,
                            isEmpty: false,
                            appBarHeightNotifier: _appBarHeightNotifier,
                            scrollController: scrollController,
                          ),
                          appBarHeightNotifier: _appBarHeightNotifier,
                          scrollController: scrollController,
                          sections: TagListPage.groupToSections(gridItems),
                          newFilters: const {},
                          sortFactor: settings.tagSortFactor,
                          showHeaders: false,
                          selectable: false,
                          emptyBuilder: () => isPickingGroup
                              ? EmptyContent(
                                  icon: AIcons.group,
                                  text: context.l10n.groupEmpty,
                                )
                              : EmptyContent(
                                  icon: AIcons.tag,
                                  text: context.l10n.tagEmpty,
                                ),
                          heroType: HeroType.never,
                          floatingActionButton: _buildFab(context),
                          onTileTap: (gridItem, _) async {
                            final filter = gridItem.filter;
                            switch (filter) {
                              case TagGroupFilter _:
                                context.read<FilterGroupNotifier>().value = filter.uri;
                              case TagFilter _:
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
              final filter = groupUri != null ? tagGrouping.uriToFilter(groupUri) : TagGroupFilter.root;
              if (filter is TagBaseFilter) {
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
    Selection<FilterGridItem<TagBaseFilter>> selection,
    TagChipSetActionDelegate actionDelegate,
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

    final quickActions = [
      if (isPickingGroup) ChipSetAction.createGroup,
    ];

    // `null` items are converted to dividers
    final menuActions = [
      ...ChipSetActions.general,
      null,
      ChipSetAction.toggleTitleSearch,
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
      builder: (context) => CreateGroupDialog(grouping: tagGrouping, parentGroupUri: parentGroupUri),
      routeSettings: const RouteSettings(name: CreateGroupDialog.routeName),
    );
    if (uri == null) return;

    // wait for the dialog to hide
    await Future.delayed(ADurations.dialogTransitionLoose * timeDilation);

    _pickFilter(context, TagGroupFilter.empty(uri));
  }

  void _pickFilter(BuildContext context, TagBaseFilter filter) async {
    Navigator.maybeOf(context)?.pop<TagBaseFilter>(filter);
  }
}
