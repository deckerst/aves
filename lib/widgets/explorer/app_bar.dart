import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/app_bar/app_bar_subtitle.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_app_bar.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/dialogs/select_storage_dialog.dart';
import 'package:aves/widgets/explorer/crumb_line.dart';
import 'package:aves/widgets/explorer/explorer_action_delegate.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ExplorerAppBar extends StatefulWidget {
  final ValueNotifier<VolumeRelativeDirectory?> directoryNotifier;
  final void Function(String path) goTo;

  const ExplorerAppBar({
    super.key,
    required this.directoryNotifier,
    required this.goTo,
  });

  @override
  State<ExplorerAppBar> createState() => _ExplorerAppBarState();
}

class _ExplorerAppBarState extends State<ExplorerAppBar> with WidgetsBindingObserver {
  Set<StorageVolume> get _volumes => androidFileUtils.storageVolumes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesAppBar(
      contentHeight: appBarContentHeight,
      pinned: true,
      leading: const DrawerButton(),
      title: _buildAppBarTitle(context),
      actions: _buildActions,
      bottom: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: CrumbLine.getPreferredHeight(MediaQuery.textScalerOf(context)),
            child: ValueListenableBuilder<VolumeRelativeDirectory?>(
              valueListenable: widget.directoryNotifier,
              builder: (context, directory, child) {
                return CrumbLine(
                  key: const Key('crumbs'),
                  directory: directory,
                  onTap: widget.goTo,
                );
              },
            ),
          );
        },
      ),
    );
  }

  InteractiveAppBarTitle _buildAppBarTitle(BuildContext context) {
    final appMode = context.watch<ValueNotifier<AppMode>>().value;
    Widget title = Text(
      context.l10n.explorerPageTitle,
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
    );
    if (appMode == AppMode.main) {
      title = SourceStateAwareAppBarTitle(
        title: title,
        source: context.read<CollectionSource>(),
      );
    }
    return InteractiveAppBarTitle(
      onTap: () => _goToSearch(context),
      child: title,
    );
  }

  List<Widget> _buildActions(BuildContext context, double maxWidth) {
    final animations = context.select<Settings, AccessibilityAnimations>((v) => v.accessibilityAnimations);
    return [
      IconButton(
        icon: const Icon(AIcons.search),
        onPressed: () => _goToSearch(context),
        tooltip: MaterialLocalizations.of(context).searchFieldLabel,
      ),
      if (_volumes.length > 1) _buildVolumeSelector(context),
      PopupMenuButton<ExplorerAction>(
        itemBuilder: (context) {
          return [
            ExplorerAction.addShortcut,
            ExplorerAction.setHome,
            ExplorerAction.hide,
            null,
            ExplorerAction.stats,
          ].map<PopupMenuEntry<ExplorerAction>>((v) {
            if (v == null) return const PopupMenuDivider();
            return PopupMenuItem(
              value: v,
              child: MenuRow(text: v.getText(context), icon: v.getIcon()),
            );
          }).toList();
        },
        onSelected: (action) async {
          // wait for the popup menu to hide before proceeding with the action
          await Future.delayed(animations.popUpAnimationDelay * timeDilation);
          final directory = widget.directoryNotifier.value;
          if (directory != null) {
            ExplorerActionDelegate(directory: directory).onActionSelected(context, action);
          }
        },
        popUpAnimationStyle: animations.popUpAnimationStyle,
      ),
    ].map((v) => FontSizeIconTheme(child: v)).toList();
  }

  Widget _buildVolumeSelector(BuildContext context) {
    if (_volumes.length == 2) {
      return ValueListenableBuilder<VolumeRelativeDirectory?>(
        valueListenable: widget.directoryNotifier,
        builder: (context, directory, child) {
          final currentVolume = directory?.volumePath;
          final otherVolume = _volumes.firstWhere((volume) => volume.path != currentVolume);
          final icon = otherVolume.isRemovable ? AIcons.storageCard : AIcons.storageMain;
          return IconButton(
            icon: Icon(icon),
            onPressed: () => widget.goTo(otherVolume.path),
            tooltip: otherVolume.getDescription(context),
          );
        },
      );
    } else {
      return IconButton(
        icon: const Icon(AIcons.storageCard),
        onPressed: () async {
          _volumes.map((v) {
            final selected = widget.directoryNotifier.value?.volumePath == v.path;
            final icon = v.isRemovable ? AIcons.storageCard : AIcons.storageMain;
            return PopupMenuItem(
              value: v,
              enabled: !selected,
              child: MenuRow(
                text: v.getDescription(context),
                icon: Icon(icon),
              ),
            );
          }).toList();
          final volumePath = widget.directoryNotifier.value?.volumePath;
          final initialVolume = _volumes.firstWhereOrNull((v) => v.path == volumePath);
          final volume = await showDialog<StorageVolume?>(
            context: context,
            builder: (context) => SelectStorageDialog(initialVolume: initialVolume),
            routeSettings: const RouteSettings(name: SelectStorageDialog.routeName),
          );
          if (volume != null) {
            widget.goTo(volume.path);
          }
        },
        tooltip: context.l10n.explorerActionSelectStorageVolume,
      );
    }
  }

  double get appBarContentHeight {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(kToolbarHeight) + CrumbLine.getPreferredHeight(textScaler);
  }

  void _goToSearch(BuildContext context) {
    Navigator.maybeOf(context)?.push(
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
          searchFieldStyle: Themes.searchFieldStyle(context),
          source: context.read<CollectionSource>(),
        ),
      ),
    );
  }
}
