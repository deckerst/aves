import 'package:aves/services/android_file_service.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:flutter/material.dart';

class DebugStorageSection extends StatefulWidget {
  @override
  _DebugStorageSectionState createState() => _DebugStorageSectionState();
}

class _DebugStorageSectionState extends State<DebugStorageSection> with AutomaticKeepAliveClientMixin {
  final Map<String, int> _freeSpaceByVolume = {};

  @override
  void initState() {
    super.initState();
    androidFileUtils.storageVolumes.forEach((volume) async {
      final byteCount = await AndroidFileService.getFreeSpace(volume);
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
              padding: EdgeInsets.all(8),
              child: Text(v.path),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: InfoRowGroup({
                'description': '${v.description}',
                'isEmulated': '${v.isEmulated}',
                'isPrimary': '${v.isPrimary}',
                'isRemovable': '${v.isRemovable}',
                'state': '${v.state}',
                if (freeSpace != null) 'freeSpace': formatFilesize(freeSpace),
              }),
            ),
            Divider(),
          ];
        })
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
