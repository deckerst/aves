import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SelectStorageDialog extends StatefulWidget {
  static const routeName = '/dialog/select_storage';

  final StorageVolume? initialVolume;

  const SelectStorageDialog({super.key, this.initialVolume});

  @override
  State<SelectStorageDialog> createState() => _SelectStorageDialogState();
}

class _SelectStorageDialogState extends State<SelectStorageDialog> {
  late Set<StorageVolume> _allVolumes;
  late StorageVolume? _primaryVolume, _selectedVolume;

  @override
  void initState() {
    super.initState();
    _allVolumes = androidFileUtils.storageVolumes;
    _primaryVolume = _allVolumes.firstWhereOrNull((volume) => volume.isPrimary) ?? _allVolumes.firstOrNull;
    _selectedVolume = widget.initialVolume ?? _primaryVolume;
  }

  @override
  Widget build(BuildContext context) {
    final byPrimary = groupBy<StorageVolume, bool>(_allVolumes, (volume) => volume.isPrimary);
    int compare(StorageVolume a, StorageVolume b) => compareAsciiUpperCaseNatural(a.path, b.path);
    final primaryVolumes = (byPrimary[true] ?? [])..sort(compare);
    final otherVolumes = (byPrimary[false] ?? [])..sort(compare);

    return AvesDialog(
      title: context.l10n.selectStorageVolumeDialogTitle,
      scrollableContent: [
        ...primaryVolumes.map((volume) => _buildVolumeTile(context, volume)),
        ...otherVolumes.map((volume) => _buildVolumeTile(context, volume)),
      ],
      actions: [
        const CancelButton(),
        TextButton(
          onPressed: () => Navigator.maybeOf(context)?.pop(_selectedVolume),
          child: Text(context.l10n.applyButtonLabel),
        ),
      ],
    );
  }

  Widget _buildVolumeTile(BuildContext context, StorageVolume volume) => RadioListTile<StorageVolume>(
        value: volume,
        groupValue: _selectedVolume,
        onChanged: (volume) {
          _selectedVolume = volume!;
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
}
