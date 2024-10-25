import 'dart:io';

import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/settings/privacy/file_picker/crumb_line.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class FilePickerPage extends StatefulWidget {
  static const routeName = '/file_picker';

  const FilePickerPage({super.key});

  @override
  State<FilePickerPage> createState() => _FilePickerPageState();
}

class _FilePickerPageState extends State<FilePickerPage> {
  late VolumeRelativeDirectory _directory;
  List<Directory>? _contents;

  Set<StorageVolume> get volumes => androidFileUtils.storageVolumes;

  String get currentDirectoryPath => pContext.join(_directory.volumePath, _directory.relativeDir);

  @override
  void initState() {
    super.initState();
    final primaryVolume = volumes.firstWhereOrNull((v) => v.isPrimary);
    if (primaryVolume != null) {
      _goTo(primaryVolume.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showHidden = settings.filePickerShowHiddenFiles;
    final visibleContents = _contents?.where((v) {
      if (showHidden) {
        return true;
      } else {
        final isHidden = pContext.split(v.path).last.startsWith('.');
        return !isHidden;
      }
    }).toList();
    final animations = context.select<Settings, AccessibilityAnimations>((s) => s.accessibilityAnimations);
    return PopScope(
      canPop: _directory.relativeDir.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final parent = pContext.dirname(currentDirectoryPath);
        _goTo(parent);
        setState(() {});
      },
      child: AvesScaffold(
        appBar: AppBar(
          title: Text(_getTitle(context)),
          actions: [
            FontSizeIconTheme(
              child: PopupMenuButton<_PickerAction>(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: _PickerAction.toggleHiddenView,
                      child: MenuRow(text: showHidden ? l10n.filePickerDoNotShowHiddenFiles : l10n.filePickerShowHiddenFiles),
                    ),
                  ];
                },
                onSelected: (action) async {
                  // wait for the popup menu to hide before proceeding with the action
                  await Future.delayed(animations.popUpAnimationDelay * timeDilation);
                  switch (action) {
                    case _PickerAction.toggleHiddenView:
                      settings.filePickerShowHiddenFiles = !showHidden;
                      setState(() {});
                  }
                },
                popUpAnimationStyle: animations.popUpAnimationStyle,
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: SafeArea(
          child: Column(
            children: [
              _buildCrumbLine(context),
              const Divider(height: 0),
              Expanded(
                child: visibleContents == null
                    ? const SizedBox()
                    : visibleContents.isEmpty
                        ? Center(
                            child: EmptyContent(
                              icon: AIcons.folder,
                              text: l10n.filePickerNoItems,
                            ),
                          )
                        : ListView.builder(
                            itemCount: visibleContents.length,
                            itemBuilder: (context, index) {
                              return index < visibleContents.length ? _buildContentLine(context, visibleContents[index]) : const SizedBox();
                            },
                          ),
              ),
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.all(8),
                child: AvesOutlinedButton(
                  label: l10n.filePickerUseThisFolder,
                  onPressed: () => Navigator.maybeOf(context)?.pop(currentDirectoryPath),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrumbLine(BuildContext context) {
    final crumbStyle = Theme.of(context).textTheme.bodyMedium!;
    return SizedBox(
      height: kMinInteractiveDimension,
      child: DefaultTextStyle(
        style: crumbStyle.copyWith(
          color: crumbStyle.color!.withAlpha((255.0 * .4).round()),
          fontWeight: FontWeight.w500,
        ),
        child: CrumbLine(
          directory: _directory,
          onTap: (path) {
            _goTo(path);
            setState(() {});
          },
        ),
      ),
    );
  }

  String _getTitle(BuildContext context) {
    if (_directory.relativeDir.isEmpty) {
      return _directory.getVolumeDescription(context);
    }
    return pContext.split(_directory.relativeDir).last;
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.l10n.filePickerOpenFrom,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          ...volumes.map((v) {
            final icon = v.isRemovable ? AIcons.storageCard : AIcons.storageMain;
            return ListTile(
              leading: Icon(icon),
              title: Text(v.getDescription(context)),
              onTap: () async {
                Navigator.maybeOf(context)?.pop();
                await Future.delayed(ADurations.drawerTransitionLoose);
                _goTo(v.path);
                setState(() {});
              },
              selected: _directory.volumePath == v.path,
            );
          })
        ],
      ),
    );
  }

  Widget _buildContentLine(BuildContext context, FileSystemEntity content) {
    return ListTile(
      leading: const Icon(AIcons.folder),
      title: Text('${Unicode.FSI}${pContext.split(content.path).last}${Unicode.PDI}'),
      onTap: () {
        _goTo(content.path);
        setState(() {});
      },
    );
  }

  void _goTo(String path) {
    _directory = androidFileUtils.relativeDirectoryFromPath(path)!;
    _contents = null;
    final contents = <Directory>[];
    Directory(currentDirectoryPath).list().listen((event) {
      final entity = event.absolute;
      if (entity is Directory) {
        contents.add(entity);
      }
    }, onDone: () {
      _contents = contents..sort((a, b) => compareAsciiUpperCaseNatural(pContext.split(a.path).last, pContext.split(b.path).last));
      setState(() {});
    });
  }
}

enum _PickerAction { toggleHiddenView }
