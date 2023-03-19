import 'dart:io';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/settings/privacy/file_picker/crumb_line.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
    return WillPopScope(
      onWillPop: () {
        if (_directory.relativeDir.isEmpty) {
          return SynchronousFuture(true);
        }
        final parent = pContext.dirname(currentDirectoryPath);
        _goTo(parent);
        setState(() {});
        return SynchronousFuture(false);
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
                  await Future.delayed(Durations.popupMenuAnimation * timeDilation);
                  switch (action) {
                    case _PickerAction.toggleHiddenView:
                      settings.filePickerShowHiddenFiles = !showHidden;
                      setState(() {});
                      break;
                  }
                },
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: kMinInteractiveDimension,
                child: CrumbLine(
                  directory: _directory,
                  onTap: (path) {
                    _goTo(path);
                    setState(() {});
                  },
                ),
              ),
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
            final icon = v.isRemovable ? AIcons.removableStorage : AIcons.mainStorage;
            return ListTile(
              leading: Icon(icon),
              title: Text(v.getDescription(context)),
              onTap: () async {
                Navigator.maybeOf(context)?.pop();
                await Future.delayed(Durations.drawerTransitionAnimation);
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
      title: Text('${Constants.fsi}${pContext.split(content.path).last}${Constants.pdi}'),
      onTap: () {
        _goTo(content.path);
        setState(() {});
      },
    );
  }

  void _goTo(String path) {
    _directory = VolumeRelativeDirectory.fromPath(path)!;
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
