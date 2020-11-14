import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/common/aves_expansion_tile.dart';
import 'package:aves/widgets/fullscreen/info/common.dart';
import 'package:flutter/material.dart';

class DebugStorageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AvesExpansionTile(
      title: 'Storage Volumes',
      children: [
        ...androidFileUtils.storageVolumes.expand((v) => [
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
                }),
              ),
              Divider(),
            ])
      ],
    );
  }
}
