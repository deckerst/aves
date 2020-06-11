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
  Set<StorageVolume> allVolumes;
  StorageVolume primaryVolume, selectedVolume;

  @override
  void initState() {
    super.initState();

    // TODO TLAD improve new album default name
    _nameController.text = 'Album 1';

    allVolumes = androidFileUtils.storageVolumes;
    primaryVolume = allVolumes.firstWhere((volume) => volume.isPrimary, orElse: () => allVolumes.first);
    selectedVolume = primaryVolume;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Album'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
//            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Storage:'),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<StorageVolume>(
                  isExpanded: true,
                  items: allVolumes
                      .map((volume) => DropdownMenuItem(
                            value: volume,
                            child: Text(
                              volume.description,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                            ),
                          ))
                      .toList(),
                  value: selectedVolume,
                  onChanged: (volume) => setState(() => selectedVolume = volume),
                ),
              ),
            ],
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.toUpperCase()),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context, _buildAlbumPath()),
          child: Text('Create'.toUpperCase()),
        ),
      ],
    );
  }

  String _buildAlbumPath() {
    final newName = _nameController.text;
    if (newName == null || newName.isEmpty) return null;
    return join(selectedVolume == primaryVolume ? androidFileUtils.dcimPath : selectedVolume.path, newName);
  }
}
