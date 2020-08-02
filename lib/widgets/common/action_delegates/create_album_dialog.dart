import 'dart:io';

import 'package:aves/utils/android_file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

class CreateAlbumDialog extends StatefulWidget {
  @override
  _CreateAlbumDialogState createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<CreateAlbumDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  Set<StorageVolume> _allVolumes;
  StorageVolume _primaryVolume, _selectedVolume;

  static const EdgeInsets hPadding = EdgeInsets.symmetric(horizontal: 24);

  @override
  void initState() {
    super.initState();
    _allVolumes = androidFileUtils.storageVolumes;
    _primaryVolume = _allVolumes.firstWhere((volume) => volume.isPrimary, orElse: () => _allVolumes.first);
    _selectedVolume = _primaryVolume;
    _initAlbumName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Album'),
      content: ListView(
        shrinkWrap: true,
        children: [
          if (_allVolumes.length > 1) ...[
            Padding(
              padding: hPadding,
              child: Text('Storage:'),
            ),
            ..._allVolumes.map((volume) => RadioListTile<StorageVolume>(
                  value: volume,
                  groupValue: _selectedVolume,
                  onChanged: (volume) {
                    _selectedVolume = volume;
                    _checkAlbumExists();
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
            padding: hPadding,
            child: ValueListenableBuilder<bool>(
                valueListenable: _existsNotifier,
                builder: (context, exists, child) {
                  return TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      helperText: exists ? 'Album already exists' : '',
                    ),
                    onChanged: (_) => _checkAlbumExists(),
                    onSubmitted: (_) => _submit(context),
                  );
                }),
          ),
        ],
      ),
      contentPadding: EdgeInsets.only(top: 20),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          onPressed: () => _submit(context),
          child: Text('Create'.toUpperCase()),
        ),
      ],
    );
  }

  String _buildAlbumPath(String name) {
    if (name == null || name.isEmpty) return '';
    return join(_selectedVolume.path, 'Pictures', name);
  }

  Future<void> _initAlbumName() async {
    var count = 1;
    while (true) {
      var name = 'Album $count';
      if (!await Directory(_buildAlbumPath(name)).exists()) {
        _nameController.text = name;
        return;
      }
      count++;
    }
  }

  Future<void> _checkAlbumExists() async {
    final path = _buildAlbumPath(_nameController.text);
    _existsNotifier.value = path.isEmpty ? false : await Directory(path).exists();
  }

  void _submit(BuildContext context) => Navigator.pop(context, _buildAlbumPath(_nameController.text));
}
