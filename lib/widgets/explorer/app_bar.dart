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
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/settings/privacy/file_picker/crumb_line.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ExplorerAppBar extends StatefulWidget {
  final ValueNotifier<VolumeRelativeDirectory> directoryNotifier;
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
    final animations = context.select<Settings, AccessibilityAnimations>((s) => s.accessibilityAnimations);
    return AvesAppBar(
      contentHeight: appBarContentHeight,
      pinned: true,
      leading: const DrawerButton(),
      title: _buildAppBarTitle(context),
      actions: [
        IconButton(
          icon: const Icon(AIcons.search),
          onPressed: () => _goToSearch(context),
          tooltip: MaterialLocalizations.of(context).searchFieldLabel,
        ),
        if (_volumes.length > 1)
          FontSizeIconTheme(
            child: PopupMenuButton<StorageVolume>(
              itemBuilder: (context) {
                return _volumes.map((v) {
                  final selected = widget.directoryNotifier.value.volumePath == v.path;
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
              },
              onSelected: (volume) async {
                // wait for the popup menu to hide before proceeding with the action
                await Future.delayed(animations.popUpAnimationDelay * timeDilation);
                widget.goTo(volume.path);
              },
              popUpAnimationStyle: animations.popUpAnimationStyle,
            ),
          ),
      ],
      bottom: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: CrumbLine.getPreferredHeight(MediaQuery.textScalerOf(context)),
            child: ValueListenableBuilder<VolumeRelativeDirectory>(
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
