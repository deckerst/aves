import 'dart:io';

import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/durations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

import '../aves_dialog.dart';

class CreateAlbumDialog extends StatefulWidget {
  @override
  _CreateAlbumDialogState createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFieldFocusNode = FocusNode();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);
  Set<StorageVolume> _allVolumes;
  StorageVolume _primaryVolume, _selectedVolume;

  @override
  void initState() {
    super.initState();
    _allVolumes = androidFileUtils.storageVolumes;
    _primaryVolume = _allVolumes.firstWhere((volume) => volume.isPrimary, orElse: () => _allVolumes.first);
    _selectedVolume = _primaryVolume;
    _nameFieldFocusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFieldFocusNode.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      context: context,
      title: 'New Album',
      scrollController: _scrollController,
      scrollableContent: [
        if (_allVolumes.length > 1) ...[
          Padding(
            padding: AvesDialog.contentHorizontalPadding + EdgeInsets.only(top: 20),
            child: Text('Storage:'),
          ),
          ..._allVolumes.map((volume) => RadioListTile<StorageVolume>(
                value: volume,
                groupValue: _selectedVolume,
                onChanged: (volume) {
                  _selectedVolume = volume;
                  _validate();
                  setState(() {});
                },
                title: Text(
                  volume.description,
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
              )),
          SizedBox(height: 8),
        ],
        Padding(
          padding: AvesDialog.contentHorizontalPadding + EdgeInsets.only(bottom: 8),
          child: ValueListenableBuilder<bool>(
              valueListenable: _existsNotifier,
              builder: (context, exists, child) {
                return TextField(
                  controller: _nameController,
                  focusNode: _nameFieldFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Album name',
                    helperText: exists ? 'Album already exists' : '',
                  ),
                  autofocus: _allVolumes.length == 1,
                  onChanged: (_) => _validate(),
                  onSubmitted: (_) => _submit(context),
                );
              }),
        ),
      ],
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return TextButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text('Create'.toUpperCase()),
            );
          },
        ),
      ],
    );
  }

  void _onFocus() async {
    // when the field gets focus, we wait for the soft keyboard to appear
    // then scroll to the bottom to make sure the field is in view
    if (_nameFieldFocusNode.hasFocus) {
      await Future.delayed(Durations.softKeyboardDisplayDelay);
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
    if (name == null || name.isEmpty) return '';
    return join(_selectedVolume.path, 'Pictures', name);
  }

  Future<void> _validate() async {
    final newName = _nameController.text ?? '';
    final path = _buildAlbumPath(newName);
    final exists = newName.isNotEmpty && await Directory(path).exists();
    _existsNotifier.value = exists;
    _isValidNotifier.value = newName.isNotEmpty;
  }

  void _submit(BuildContext context) => Navigator.pop(context, _buildAlbumPath(_nameController.text));
}
