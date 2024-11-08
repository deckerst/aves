import 'dart:io';

import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateAlbumDialog extends StatefulWidget {
  static const routeName = '/dialog/create_album';

  const CreateAlbumDialog({super.key});

  @override
  State<CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFieldFocusNode = FocusNode();
  final ValueNotifier<bool> _directoryExistsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _albumExistsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);
  late Set<StorageVolume> _allVolumes;
  late StorageVolume? _primaryVolume, _selectedVolume;

  @override
  void initState() {
    super.initState();
    _allVolumes = androidFileUtils.storageVolumes;
    _primaryVolume = _allVolumes.firstWhereOrNull((volume) => volume.isPrimary) ?? _allVolumes.firstOrNull;
    _selectedVolume = _primaryVolume;
    _nameFieldFocusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _nameFieldFocusNode.removeListener(_onFocus);
    _nameFieldFocusNode.dispose();
    _directoryExistsNotifier.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const contentHorizontalPadding = EdgeInsets.symmetric(horizontal: AvesDialog.defaultHorizontalContentPadding);

    final volumeTiles = <Widget>[];
    if (_allVolumes.length > 1) {
      final byPrimary = groupBy<StorageVolume, bool>(_allVolumes, (volume) => volume.isPrimary);
      int compare(StorageVolume a, StorageVolume b) => compareAsciiUpperCaseNatural(a.path, b.path);
      final primaryVolumes = (byPrimary[true] ?? [])..sort(compare);
      final otherVolumes = (byPrimary[false] ?? [])..sort(compare);
      volumeTiles.addAll([
        Padding(
          padding: contentHorizontalPadding + const EdgeInsets.only(top: 20),
          child: Text(l10n.newAlbumDialogStorageLabel),
        ),
        ...primaryVolumes.map((volume) => _buildVolumeTile(context, volume)),
        ...otherVolumes.map((volume) => _buildVolumeTile(context, volume)),
        const SizedBox(height: 8),
      ]);
    }

    return AvesDialog(
      title: l10n.newAlbumDialogTitle,
      scrollController: _scrollController,
      scrollableContent: [
        ...volumeTiles,
        Padding(
          padding: contentHorizontalPadding + const EdgeInsets.only(bottom: 8),
          child: AnimatedBuilder(
              animation: Listenable.merge([_albumExistsNotifier, _directoryExistsNotifier]),
              builder: (context, child) {
                var helperText = '';
                if (_albumExistsNotifier.value) {
                  helperText = l10n.newAlbumDialogAlbumAlreadyExistsHelper;
                } else if (_directoryExistsNotifier.value) {
                  helperText = l10n.newAlbumDialogNameLabelAlreadyExistsHelper;
                }
                return TextField(
                  controller: _nameController,
                  focusNode: _nameFieldFocusNode,
                  decoration: InputDecoration(
                    labelText: l10n.newAlbumDialogNameLabel,
                    helperText: helperText,
                  ),
                  autofocus: _allVolumes.length == 1,
                  onChanged: (_) => _validate(),
                  onSubmitted: (_) => _submit(context),
                );
              }),
        ),
      ],
      actions: [
        const CancelButton(),
        ValueListenableBuilder<bool>(
          valueListenable: _albumExistsNotifier,
          builder: (context, albumExists, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: _isValidNotifier,
              builder: (context, isValid, child) {
                return TextButton(
                  onPressed: isValid ? () => _submit(context) : null,
                  child: Text(albumExists ? l10n.showButtonLabel : l10n.createAlbumButtonLabel),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildVolumeTile(BuildContext context, StorageVolume volume) => RadioListTile<StorageVolume>(
        value: volume,
        groupValue: _selectedVolume,
        onChanged: (volume) {
          _selectedVolume = volume!;
          _validate();
          setState(() {});
        },
        title: Text(
          volume.getDescription(context),
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
        subtitle: Text(
          volume.path,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      );

  void _onFocus() async {
    // when the field gets focus, we wait for the soft keyboard to appear
    // then scroll to the bottom to make sure the field is in view
    if (_nameFieldFocusNode.hasFocus) {
      await Future.delayed(ADurations.softKeyboardDisplayDelay + const Duration(milliseconds: 500));
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: ADurations.dialogFieldReachAnimation,
      curve: Curves.easeInOut,
    );
  }

  Future<String?> _buildAlbumPath() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;

    final volumePath = _selectedVolume?.path;
    if (volumePath == null) return null;

    final candidatePath = pContext.join(volumePath, AndroidFileUtils.standardDirPictures, name);

    // uses resolved directory name case if it exists
    var resolvedPath = volumePath;
    final relativePathSegments = pContext.split(pContext.relative(candidatePath, from: volumePath));
    for (final targetSegment in relativePathSegments) {
      String? resolvedSegment;
      final directory = Directory(resolvedPath);
      if (await directory.exists()) {
        final lowerTargetSegment = targetSegment.toLowerCase();
        resolvedSegment = directory.listSync().map((v) => pContext.basename(v.path)).firstWhereOrNull((v) => v.toLowerCase() == lowerTargetSegment);
      }
      resolvedPath = pContext.join(resolvedPath, resolvedSegment ?? targetSegment);
    }

    return resolvedPath;
  }

  Future<void> _validate() async {
    final path = await _buildAlbumPath();
    final isValid = path != null;
    _isValidNotifier.value = isValid;
    _directoryExistsNotifier.value = isValid && await Directory(path).exists();
    _albumExistsNotifier.value = isValid && context.read<CollectionSource>().rawAlbums.contains(path);
  }

  Future<void> _submit(BuildContext context) async {
    final path = await _buildAlbumPath();
    if (path == null) return;

    Navigator.maybeOf(context)?.pop(path);
  }
}
