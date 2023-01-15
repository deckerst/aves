import 'dart:io';

import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../aves_dialog.dart';

class CreateAlbumDialog extends StatefulWidget {
  const CreateAlbumDialog({super.key});

  @override
  State<CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFieldFocusNode = FocusNode();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
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
    _nameController.dispose();
    _nameFieldFocusNode.removeListener(_onFocus);
    _nameFieldFocusNode.dispose();
    _existsNotifier.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Text(context.l10n.newAlbumDialogStorageLabel),
        ),
        ...primaryVolumes.map((volume) => _buildVolumeTile(context, volume)),
        ...otherVolumes.map((volume) => _buildVolumeTile(context, volume)),
        const SizedBox(height: 8),
      ]);
    }

    return AvesDialog(
      title: context.l10n.newAlbumDialogTitle,
      scrollController: _scrollController,
      scrollableContent: [
        ...volumeTiles,
        Padding(
          padding: contentHorizontalPadding + const EdgeInsets.only(bottom: 8),
          child: ValueListenableBuilder<bool>(
              valueListenable: _existsNotifier,
              builder: (context, exists, child) {
                return TextField(
                  controller: _nameController,
                  focusNode: _nameFieldFocusNode,
                  decoration: InputDecoration(
                    labelText: context.l10n.newAlbumDialogNameLabel,
                    helperText: exists ? context.l10n.newAlbumDialogNameLabelAlreadyExistsHelper : '',
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
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text(context.l10n.createAlbumButtonLabel),
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
      await Future.delayed(Durations.softKeyboardDisplayDelay + const Duration(milliseconds: 500));
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Durations.dialogFieldReachAnimation,
      curve: Curves.easeInOut,
    );
  }

  String _buildAlbumPath(String name) {
    final selectedVolume = _selectedVolume;
    if (selectedVolume == null || name.isEmpty) return '';
    return pContext.join(selectedVolume.path, 'Pictures', name);
  }

  Future<void> _validate() async {
    final newName = _nameController.text;
    final path = _buildAlbumPath(newName);
    final exists = newName.isNotEmpty && await Directory(path).exists();
    _existsNotifier.value = exists;
    _isValidNotifier.value = newName.isNotEmpty && !exists;
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.pop(context, _buildAlbumPath(_nameController.text));
    }
  }
}
