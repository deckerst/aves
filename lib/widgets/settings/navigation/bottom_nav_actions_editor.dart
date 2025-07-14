import 'dart:async';

import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/album_pick_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:aves/widgets/home/home_page.dart';
import 'package:aves/widgets/navigation/nav_item.dart';
import 'package:aves/widgets/settings/common/quick_actions/editor_page.dart';
import 'package:aves/widgets/settings/navigation/drawer.dart';
import 'package:aves/widgets/settings/settings_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class BottomNavigationActionEditorPage extends StatefulWidget {
  static const routeName = '/settings/navigation/bottom_actions';

  const BottomNavigationActionEditorPage({super.key});

  @override
  State<BottomNavigationActionEditorPage> createState() => _BottomNavigationActionEditorPageState();
}

class _BottomNavigationActionEditorPageState extends State<BottomNavigationActionEditorPage> {
  late final QuickActionEditorController<AvesNavItem> _controller;

  static final allAvailableActions = [
    NavigationDrawerEditorPage.collectionFilterOptions.map((filter) {
      return AvesNavItem(
        route: CollectionPage.routeName,
        filters: filter != null ? {filter} : null,
      );
    }).toList(),
    [
      HomePage.routeName,
      SettingsPage.routeName,
      ...NavigationDrawerEditorPage.pageOptions,
    ].map((v) {
      return AvesNavItem(
        route: v,
      );
    }).toList(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = QuickActionEditorController(
      load: () => settings.bottomNavigationActions,
      save: (actions) => settings.bottomNavigationActions = actions,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuickActionEditorPage<AvesNavItem>(
      title: context.l10n.settingsNavigationBottomActionEditorPageTitle,
      appBarActions: _buildActions(context),
      bannerText: context.l10n.settingsNavigationBottomActionEditorBanner,
      allAvailableActions: allAvailableActions,
      actionIcon: (context, action) => action.getIcon(context),
      actionText: (context, action) => action.getText(context),
      controller: _controller,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final animations = context.select<Settings, AccessibilityAnimations>((v) => v.accessibilityAnimations);
    return [
      PopupMenuButton<_EditorAction>(
        itemBuilder: (context) {
          return [
            _EditorAction.addAlbum,
            _EditorAction.addTag,
          ].map<PopupMenuEntry<_EditorAction>>((v) {
            return PopupMenuItem(
              value: v,
              child: MenuRow(text: v.getText(context), icon: v.getIcon()),
            );
          }).toList();
        },
        onSelected: (action) async {
          // wait for the popup menu to hide before proceeding with the action
          await Future.delayed(animations.popUpAnimationDelay * timeDilation);
          await _onActionSelected(context, action);
        },
        popUpAnimationStyle: animations.popUpAnimationStyle,
      ),
    ].map((v) => FontSizeIconTheme(child: v)).toList();
  }

  Future<void> _onActionSelected(BuildContext context, _EditorAction action) async {
    switch (action) {
      case _EditorAction.addAlbum:
        final albumFilter = await pickAlbum(
          context: context,
          moveType: null,
          albumChipTypes: AlbumChipType.values,
          initialGroup: null,
        );
        if (albumFilter == null) return;
        _controller.add(AvesNavItem(route: CollectionPage.routeName, filters: {albumFilter}));
      case _EditorAction.addTag:
        // TODO TLAD tag picker
        break;
    }
  }
}

enum _EditorAction {
  addAlbum,
  addTag,
}

extension _ExtraEditorActionView on _EditorAction {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      _EditorAction.addAlbum => l10n.settingsNavigationDrawerAddAlbum,
      _EditorAction.addTag => l10n.tagEditorPageAddTagTooltip,
    };
  }

  Widget getIcon() => Icon(_getIconData());

  IconData _getIconData() {
    return switch (this) {
      _EditorAction.addAlbum => AIcons.album,
      _EditorAction.addTag => AIcons.tag,
    };
  }
}
