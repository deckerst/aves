import 'package:aves/locale/aves_locale.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/viewer/info/common.dart';
import 'package:material_ui/material_ui.dart';

class DebugOSStorageSection extends StatefulWidget {
  const new({super.key});

  @override
  State<DebugOSStorageSection> createState() => _DebugOSStorageSectionState();
}

class _DebugOSStorageSectionState extends State<DebugOSStorageSection> with AutomaticKeepAliveClientMixin {
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
      title: 'OS Storage',
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
                  'mediaStoreVolumeName': '${v.mediaStoreVolumeName}',
                  'description': v.getDescription(context),
                  'isPrimary': '${v.isPrimary}',
                  'isRemovable': '${v.isRemovable}',
                  'state': v.state,
                  if (freeSpace != null) 'freeSpace': formatFileSize(AvesLocale.ascii, freeSpace),
                },
              ),
            ),
            const Divider(),
          ];
        }),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
