import 'dart:io';

import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

import '../aves_dialog.dart';

class CreateAlbumDialog extends StatefulWidget {
  @override
  _CreateAlbumDialogState createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  final TextEditingController _nameController = TextEditingController();
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      title: 'New Album',
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
                  decoration: InputDecoration(
                    helperText: exists ? 'Album already exists' : '',
                    hintText: 'Album name',
                  ),
                  onChanged: (_) => _validate(),
                  onSubmitted: (_) => _submit(context),
                );
              }),
        ),
      ],
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isValidNotifier,
          builder: (context, isValid, child) {
            return FlatButton(
              onPressed: isValid ? () => _submit(context) : null,
              child: Text('Create'.toUpperCase()),
            );
          },
        )
      ],
    );
  }

  String _buildAlbumPath(String name) {
    if (name == null || name.isEmpty) return '';
    return join(_selectedVolume.path, 'Pictures', name);
  }

  Future<void> _validate() async {
    final path = _buildAlbumPath(_nameController.text);
    _existsNotifier.value = path.isEmpty ? false : await Directory(path).exists();
    _isValidNotifier.value = (_nameController.text ?? '').isNotEmpty;
  }

  void _submit(BuildContext context) => Navigator.pop(context, _buildAlbumPath(_nameController.text));
}
