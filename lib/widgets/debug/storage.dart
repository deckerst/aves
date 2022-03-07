import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';

class DebugStorageSection extends StatefulWidget {
  const DebugStorageSection({Key? key}) : super(key: key);

  @override
  State<DebugStorageSection> createState() => _DebugStorageSectionState();
}

class _DebugStorageSectionState extends State<DebugStorageSection> with AutomaticKeepAliveClientMixin {
  final Map<String, int?> _freeSpaceByVolume = {};

  @override
  void initState() {
    super.initState();
    androidFileUtils.storageVolumes.forEach((volume) async {
      final byteCount = await storageService.getFreeSpace(volume);
      setState(() => _freeSpaceByVolume[volume.path] = byteCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AvesExpansionTile(
      title: 'Storage Volumes',
      children: [
        ...androidFileUtils.storageVolumes.expand((v) {
          final freeSpace = _freeSpaceByVolume[v.path];
          return [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(v.path),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InfoRowGroup(
                info: {
                  'description': v.getDescription(context),
                  'isPrimary': '${v.isPrimary}',
                  'isRemovable': '${v.isRemovable}',
                  'state': v.state,
                  if (freeSpace != null) 'freeSpace': formatFileSize('en_US', freeSpace),
                },
              ),
            ),
            const Divider(),
          ];
        })
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
